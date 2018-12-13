package WebService::Hexonet::Connector::APIClient;

use 5.014_004;
use strict;
use warnings;
use utf8;
use WebService::Hexonet::Connector::SocketConfig;
use Readonly;
use WebService::Hexonet::Connector::Response;
use WebService::Hexonet::Connector::ResponseTemplateManager;
use LWP::UserAgent;
use Carp;
use Data::Dumper;
Readonly my $SOCKETTIMEOUT => 300; # 300s or 5 min

our $VERSION = 'v1.12.1';

my $rtm = WebService::Hexonet::Connector::ResponseTemplateManager->getInstance();


sub new {
	my $class = shift;
	my $self  = bless {
		socketURL => 'https://coreapi.1api.net/api/call.cgi',
		debugMode => 0,
		socketConfig => WebService::Hexonet::Connector::SocketConfig->new()
	}, $class;
	$self->setURL('https://coreapi.1api.net/api/call.cgi');
	$self->useLIVESystem();
	return $self;
}


sub enableDebugMode {
	my $self = shift;
	$self->{debugMode} = 1;
	return $self;
}


sub disableDebugMode {
	my $self = shift;
	$self->{debugMode} = 0;
	return $self;
}


sub getPOSTData {
	my ($self, $cmd) = @_;
	my $post = $self->{socketConfig}->getPOSTData();
	my $tmp = q{};
	if ( ( ref $cmd ) eq 'HASH' ) {
		foreach my $key ( sort keys %{$cmd}) {
			if (defined $cmd->{$key}) {
				my $val = $cmd->{$key};
				$val =~ s/[\r\n]//gmsx;
				$tmp .= "${key}=${val}\n";
			}
		}
	}
	$tmp =~ s/\n$//msx;
	if (utf8::is_utf8($tmp)) {
		utf8::encode($tmp);
	}
	$post->{'s_command'} = $tmp;
	return $post;
}


sub getSession {
	my $self = shift;
	my $sessid = $self->{socketConfig}->getSession();
	if (length $sessid) {
		return $sessid;
	}
	return;
}


sub getURL {
	my $self = shift;
	return $self->{socketURL};
}


sub getVersion {
	my $self = shift;
	return $VERSION;
}


sub saveSession {
	my ($self, $session) = @_;
	$session->{socketcfg} = {
		entity => $self->{socketConfig}->getSystemEntity(),
		session => $self->{socketConfig}->getSession()
	};
	return $self;
}


sub reuseSession {
	my ($self, $session) = @_;
	$self->{socketConfig}->setSystemEntity($session->{socketcfg}->{entity});
	$self->setSession($session->{socketcfg}->{session});
	return $self;
}


sub setURL {
	my ($self, $value) = @_;
	$self->{socketURL} = $value;
	return $self;
}


sub setOTP {
	my ($self, $value) = @_;
	$self->{socketConfig}->setOTP($value);
	return $self;
}


sub setSession {
	my ($self, $value) = @_;
	$self->{socketConfig}->setSession($value);
	return $self;
}


sub setRemoteIPAddress {
	my ($self, $value) = @_;
	$self->{socketConfig}->setRemoteAddress($value);
	return $self;
}


sub setCredentials {
	my ($self, $uid, $pw) = @_;
	$self->{socketConfig}->setLogin($uid);
	$self->{socketConfig}->setPassword($pw);
	return $self;
}


sub setRoleCredentials {
	my ($self, $uid, $role, $pw) = @_;
	my $myuid = "${uid}!${role}";
	$myuid =~ s/^\!$//msx;
	return $self->setCredentials($myuid, $pw);
}


sub login {
	my $self = shift;
	my $otp = shift;
	$self->setOTP($otp || q{});
	my $rr = $self->request({COMMAND => 'StartSession'});
	if ($rr->isSuccess()) {
		my $col = $rr->getColumn('SESSION');
		my $sessid = q{};
		if (defined $col) {
			my @d = $col->getData();
			$sessid = $d[0];
		}
		$self->setSession($sessid);
	}
	return $rr;
}


sub loginExtended {
	my $self = shift;
	my $params = shift;
	my $otpc = shift;
	if (!defined $otpc){
		$otpc = q{};
	}
	$self->setOTP($otpc);
	my $cmd = { COMMAND => 'StartSession' };
	foreach my $key (keys %{$params}) {
		$cmd->{$key} = $params->{$key};
	}
	my $rr = $self->request($cmd);
	if ($rr->isSuccess()) {
		my $col = $rr->getColumn('SESSION');
		my $sessid = q{};
		if (defined $col) {
			my @d = $col->getData();
			$sessid = $d[0];
		}
		$self->setSession($sessid);
	}
	return $rr;
}


sub logout {
	my $self = shift;
	my $rr = $self->request({COMMAND => 'EndSession'});
	if ($rr->isSuccess()) {
		$self->setSession(q{});
	}
	return $rr;
}


sub request {
	my ($self, $cmd) = @_;
	my $data = $self->getPOSTData($cmd);

	my $ua = LWP::UserAgent->new();
	$ua->agent('PERL-SDK::' . $self->getVersion());
	$ua->default_header( 'Expect', q{} );
	$ua->timeout($SOCKETTIMEOUT);

	my $post = $self->getPOSTData($cmd);
	my $r = $ua->post( $self->{socketURL}, $post );
	if ( $r->is_success ) {
		$r = $r->decoded_content;
		if ( $self->{debugMode} ) {
			print {*STDOUT} Dumper($cmd);
			print {*STDOUT} Dumper($post);
			print {*STDOUT} Dumper($r);
		}
	} else {
		my $err = $r->status_line;
		$r = $rtm->getTemplate('httperror')->getPlain();
		if ( $self->{debugMode} ) {
			print {*STDERR} Dumper($cmd);
			print {*STDERR} Dumper($post);
			print {*STDERR} Dumper($r);
		}
	}
	return WebService::Hexonet::Connector::Response->new($r, $cmd);
}


sub requestNextResponsePage {
	my ($self, $rr) = @_;
	my $mycmd = $self->_toUpperCaseKeys($rr->getCommand());
	if (defined $mycmd->{LAST}){
		croak 'Parameter LAST in use! Please remove it to avoid issues in requestNextPage.';
	}
	my $first = 0;
	if (defined $mycmd->{FIRST}) {
		$first = $mycmd->{FIRST};
	}
	my $total = $rr->getRecordsTotalCount();
	my $limit = $rr->getRecordsLimitation();
	$first += $limit;
	if ($first < $total) {
		$mycmd->{FIRST} = $first;
		$mycmd->{LIMIT} = $limit;
		return $self->request($mycmd);
	}
	return;
}


sub requestAllResponsePages {
	my ($self, $cmd) = @_;
	my @responses = ();
	my $command = {};
	foreach my $key (keys %{$cmd}) {
		$command->{$key} = $cmd->{$key};
	}
	$command->{FIRST} = 0;
	my $rr = $self->request($command);
	my $tmp = $rr;
	my $idx = 0;
	while (defined $tmp) {
		push @responses, $tmp;
		$tmp = $self->requestNextResponsePage($tmp);
	}
	return \@responses;
}


sub setUserView {
	my ($self, $uid) = @_;
	$self->{socketConfig}->setUser($uid);
	return $self;
}


sub resetUserView {
	my $self = shift;
	$self->{socketConfig}->setUser(q{});
	return $self;
}


sub useOTESystem {
	my $self = shift;
	$self->{socketConfig}->setSystemEntity('1234');
	return $self;
}


sub useLIVESystem {
	my $self = shift;
	$self->{socketConfig}->setSystemEntity('54cd');
	return $self;
}


sub _toUpperCaseKeys {
	my ($self, $cmd) = @_;
	for my $key ( keys %{$cmd} ) {
		my $newkey = uc $key;
		if ($newkey ne $key) {
			$cmd->{$newkey} = delete $cmd->{$key};
		}
	}
	return $cmd;
}

1;

__END__

=head1 NAME

WebService::Hexonet::Connector::APIClient - Library to communicate with the insanely fast HEXONET Backend System.

=head1 SYNOPSIS

This module helps to integrate the communication with the HEXONET Backend System.
To be used in the way:

    # create a new instance
    $cl = WebService::Hexonet::Connector::APIClient->new();

	# set credentials
	$cl->setCredentials('test.user', 'test.passw0rd');

	# or instead set role credentials
    # $cl->setRoleCredentials('test.user', 'testrole', 'test.passw0rd');

	# set your outgoing ip address (to be used in case ip filter settings is active)
	$cl->setRemoteIPAdress('1.2.3.4');

	# specify the HEXONET Backend System to use
	# LIVE System
	$cl->useLIVESystem();
	# or OT&E System
	$cl->useOTESystem();

    # ---------------------------
	# SESSION-based communication
	# ---------------------------
	$r = $cl->login();
	# or if 2FA is active, provide your otp code by
	# $cl->login("12345678");
	if ($r->isSuccess()) {
		# use saveSession/reuseSession for your needs
		# to apply the API session to your frontend session
		# for later reuse (no need to specify credentials and otp code)
		# within every request.

		$r = $cl->request({ COMMAND: 'StatusAccount' });
		# further logic, further commands

		# perform logout, you may check the result as shown with the login method
		$cl->logout();
	}

	# -------------------------
	# SESSIONless communication
	# -------------------------
	$r = $cl->request({ COMMAND: 'StatusAccount' });

See the documented methods for deeper information.

=head1 DESCRIPTION

This library is used to provide all functionality to be able to communicate with the HEXONET Backend System.


=head2 Methods

=over

=item C<new>

Returns a new WebService::Hexonet::Connector::APIClient object.

=item C<enableDebugMode>

Activates the debug mode. Details of the API communication are put to STDOUT.
Like API command, POST data, API plain-text response.
Debug mode is inactive by default.

=item C<disableDebugMode>

Deactivates the debug mode. Debug mode is inactive by default.

=item C<getPOSTData( $command )>

Get POST data fields ready to use for HTTP communication based on LWP::UserAgent.
Specify the API command for the request by $command.
This method is internally used by the request method.

=item C<getSession>

Returns the API session in use.

=item C<getURL>

Returns the url in use pointing to the Backend System to communicate with.

=item C<getVersion>

Returns the SDK version currently in use.

=item C<saveSession( $sessionhash )>

Save the current API session data into a given session hash object.
This might help you to add the backend system session into your frontend session.
Use reuseSession method to set a new instance of this module to that session.

=item C<reuseSession( $sessionhash )>

Reuse API session data that got previously saved into the given session hash object
by method saveSession.

=item C<setURL( $url )>

Set a different backend system url to be used for communication.

=item C<setOTP( $otpcode )>

Set your otp code. To be used in case of active 2FA.

=item C<setSession( $sessionid )>

Set the API session id to use. Automatically handled after successful session login
based on method login or loginExtended.

=item C<setRemoteIPAddress( $ip )>

Set the outgoing ip address to be used in API communication.
Use this in case of an active IP filter setting for your account.

=item C<setCredentials( $user, $pw )>

Set the credentials to use in API communication.

=item C<setRoleCredentials( $user, $role, $pw)>

Set the role user credentials to use in API communication.
NOTE: the role user specified by $role has to be directly assigned to the
specified account specified by $user.
The specified password $pw belongs to the role user, not to the account.

=item C<login( $otpcode )>

Perform a session login. Entry point for the session-based communication.
You may specify your OTP code by $otpcode.

=item C<loginExtended( $params, $otpcode )>

Perform a session login. Entry point for the session-based communication.
You may specify your OTP code by $otpcode.
Specify additional command parameter for API command "StartSession" in
Hash $params.
Possible parameters can be found in the L<API Documentation for StartSession|https://github.com/hexonet/hexonet-api-documentation/blob/master/API/USER/SESSION/STARTSESSION.md>.

=item C<logout>

Perfom a session logout. This destroys the API session.

=item C<request( $command )>

Requests the given API Command $command to the Backend System.

=item C<requestNextResponsePage( $lastresponse )>

Requests the next response page for the provided api response $lastresponse.

=item C<requestAllResponsePages( $command )>

Requests all response pages for the specified command.
NOTE: this might take some time. Requests are not made in parallel!

=item C<setUserView( $subuser )>

Activate read/write Data View on the specified subuser account.

=item C<resetUserView>

Reset the data view activated by setUserView.

=item C<useOTESystem>

Use the OT&E Backend System as communication endpoint.
No costs - free of charge. To get in touch with our systems.
This is NOT the default!

=item C<useLIVESystem>

Use the LIVE Backend System as communication endpoint.
Usage may lead to costs. BUT - are system is a prepaid system.
As long as you don't have charged your account, you cannot order.
This is the default!
 
=item C<_toUpperCaseKeys( $hash )>

Private method. Converts all keys of the given hash into upper case letters.

=head1 LICENSE AND COPYRIGHT

This program is licensed under the L<MIT License|https://raw.githubusercontent.com/hexonet/perl-sdk/master/LICENSE>.

=head1 AUTHOR

L<HEXONET GmbH|https://www.hexonet.net>

=cut