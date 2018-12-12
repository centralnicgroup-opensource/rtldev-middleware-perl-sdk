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