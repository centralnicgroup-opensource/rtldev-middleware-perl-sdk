package WebService::Hexonet::Connector::APIClient;

use 5.026_000;
use strict;
use warnings;
use utf8;
use WebService::Hexonet::Connector::Response;
use WebService::Hexonet::Connector::ResponseTemplateManager;
use WebService::Hexonet::Connector::SocketConfig;
use LWP::UserAgent;
use Carp;
use Readonly;
use Data::Dumper;
use Config;
use POSIX;

Readonly my $SOCKETTIMEOUT                => 300;                                      # 300s or 5 min
Readonly my $IDX4                         => 4;                                        # Index 4 constant
Readonly our $ISPAPI_CONNECTION_URL       => 'https://api.ispapi.net/api/call.cgi';    # Default Connection Setup URL
Readonly our $ISPAPI_CONNECTION_URL_PROXY => 'http://127.0.0.1/api/call.cgi';          # High Speed Connection Setup URL

use version 0.9917; our $VERSION = version->declare('v2.7.0');

my $rtm = WebService::Hexonet::Connector::ResponseTemplateManager->getInstance();


sub new {
    my $class = shift;
    my $self  = bless {
        socketURL    => $ISPAPI_CONNECTION_URL,
        debugMode    => 0,
        socketConfig => WebService::Hexonet::Connector::SocketConfig->new(),
        ua           => q{},
        curlopts     => {}
    }, $class;
    $self->setURL($ISPAPI_CONNECTION_URL);
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
    my ( $self, $cmd, $secured ) = @_;
    my $post = $self->{socketConfig}->getPOSTData();
    if ( defined($secured) && $secured == 1 ) {
        $post->{s_pw} = '***';
    }
    my $tmp = q{};
    if ( ( ref $cmd ) eq 'HASH' ) {
        foreach my $key ( sort keys %{$cmd} ) {
            if ( defined $cmd->{$key} ) {
                my $val = $cmd->{$key};
                $val =~ s/[\r\n]//msx;
                $tmp .= "${key}=${val}\n";
            }
        }
    } else {
        $tmp = $cmd;
    }
    if ( defined($secured) && $secured == 1 ) {
        $tmp =~ s/PASSWORD\=[^\n]+/PASSWORD=***/gmsx;
    }
    $tmp =~ s/\n$//msx;
    if ( utf8::is_utf8($tmp) ) {
        utf8::encode($tmp);
    }
    $post->{'s_command'} = $tmp;
    return $post;
}


sub getSession {
    my $self   = shift;
    my $sessid = $self->{socketConfig}->getSession();
    if ( length $sessid ) {
        return $sessid;
    }
    return;
}


sub getURL {
    my $self = shift;
    return $self->{socketURL};
}


sub getUserAgent {
    my $self = shift;
    if ( !( length $self->{ua} ) ) {
        my $arch = (POSIX::uname)[ $IDX4 ];
        my $os   = (POSIX::uname)[ 0 ];
        my $rv   = $self->getVersion();
        $self->{ua} = "PERL-SDK ($os; $arch; rv:$rv) perl/$Config{version}";
    }
    return $self->{ua};
}


sub setUserAgent {
    my ( $self, $str, $rv ) = @_;
    my $arch = (POSIX::uname)[ $IDX4 ];
    my $os   = (POSIX::uname)[ 0 ];
    my $rv2  = $self->getVersion();
    $self->{ua} = "$str ($os; $arch; rv:$rv) perl-sdk/$rv2 perl/$Config{version}";
    return $self;
}


sub getProxy {
    my ($self) = @_;
    if ( exists $self->{curlopts}->{'PROXY'} ) {
        return $self->{curlopts}->{'PROXY'};
    }
    return;
}


sub setProxy {
    my ( $self, $proxy ) = @_;
    if ( length($proxy) == 0 ) {
        delete $self->{curlopts}->{'PROXY'};
    } else {
        $self->{curlopts}->{'PROXY'} = $proxy;
    }
    return $self;
}


sub getReferer {
    my ($self) = @_;
    if ( exists $self->{curlopts}->{'REFERER'} ) {
        return $self->{curlopts}->{'REFERER'};
    }
    return;
}


sub setReferer {
    my ( $self, $referer ) = @_;
    if ( length($referer) == 0 ) {
        delete $self->{curlopts}->{'REFERER'};
    } else {
        $self->{curlopts}->{'REFERER'} = $referer;
    }
    return $self;
}


sub getVersion {
    my $self = shift;
    return $VERSION;
}


sub saveSession {
    my ( $self, $session ) = @_;
    $session->{socketcfg} = {
        entity  => $self->{socketConfig}->getSystemEntity(),
        session => $self->{socketConfig}->getSession()
    };
    return $self;
}


sub reuseSession {
    my ( $self, $session ) = @_;
    $self->{socketConfig}->setSystemEntity( $session->{socketcfg}->{entity} );
    $self->setSession( $session->{socketcfg}->{session} );
    return $self;
}


sub setURL {
    my ( $self, $value ) = @_;
    $self->{socketURL} = $value;
    return $self;
}


sub setOTP {
    my ( $self, $value ) = @_;
    $self->{socketConfig}->setOTP($value);
    return $self;
}


sub setSession {
    my ( $self, $value ) = @_;
    $self->{socketConfig}->setSession($value);
    return $self;
}


sub setRemoteIPAddress {
    my ( $self, $value ) = @_;
    $self->{socketConfig}->setRemoteAddress($value);
    return $self;
}


sub setCredentials {
    my ( $self, $uid, $pw ) = @_;
    $self->{socketConfig}->setLogin($uid);
    $self->{socketConfig}->setPassword($pw);
    return $self;
}


sub setRoleCredentials {
    my ( $self, $uid, $role, $pw ) = @_;
    my $myuid = "${uid}!${role}";
    $myuid =~ s/^\!$//msx;
    return $self->setCredentials( $myuid, $pw );
}


sub login {
    my $self = shift;
    my $otp  = shift;
    $self->setOTP( $otp || q{} );
    my $rr = $self->request( { COMMAND => 'StartSession' } );
    if ( $rr->isSuccess() ) {
        my $col    = $rr->getColumn('SESSION');
        my $sessid = q{};
        if ( defined $col ) {
            my @d = $col->getData();
            $sessid = $d[ 0 ];
        }
        $self->setSession($sessid);
    }
    return $rr;
}


sub loginExtended {
    my $self   = shift;
    my $params = shift;
    my $otpc   = shift;
    if ( !defined $otpc ) {
        $otpc = q{};
    }
    $self->setOTP($otpc);
    my $cmd = { COMMAND => 'StartSession' };
    foreach my $key ( keys %{$params} ) {
        $cmd->{$key} = $params->{$key};
    }
    my $rr = $self->request($cmd);
    if ( $rr->isSuccess() ) {
        my $col    = $rr->getColumn('SESSION');
        my $sessid = q{};
        if ( defined $col ) {
            my @d = $col->getData();
            $sessid = $d[ 0 ];
        }
        $self->setSession($sessid);
    }
    return $rr;
}


sub logout {
    my $self = shift;
    my $rr = $self->request( { COMMAND => 'EndSession' } );
    if ( $rr->isSuccess() ) {
        $self->setSession(q{});
    }
    return $rr;
}


sub request {
    my ( $self, $cmd ) = @_;
    # flatten nested api command bulk parameters
    my $newcmd = $self->_flattenCommand($cmd);
    # auto convert umlaut names to punycode
    $newcmd = $self->_autoIDNConvert($newcmd);

    # request command to API
    my $cfg     = { CONNECTION_URL => $self->{socketURL} };
    my $post    = $self->getPOSTData($newcmd);
    my $secured = $self->getPOSTData( $newcmd, 1 );

    my $ua = LWP::UserAgent->new();
    $ua->agent( $self->getUserAgent() );
    $ua->default_header( 'Expect', q{} );
    $ua->timeout($SOCKETTIMEOUT);
    my $referer = $self->getReferer();
    if ($referer) {
        $ua->default_header( 'Referer', $referer );
    }
    my $proxy = $self->getProxy();
    if ($proxy) {
        $ua->proxy( [ 'http', 'https' ], $proxy );
    }

    my $r = $ua->post( $cfg->{CONNECTION_URL}, $post );
    if ( $r->is_success ) {
        $r = $r->decoded_content;
        if ( $self->{debugMode} ) {
            print {*STDOUT} Dumper($newcmd);
            print {*STDOUT} Dumper($secured);
            print {*STDOUT} Dumper($r);
        }
    } else {
        my $err = $r->status_line;
        $r = $rtm->getTemplate('httperror')->getPlain();
        if ( $self->{debugMode} ) {
            print {*STDERR} Dumper($newcmd);
            print {*STDERR} Dumper($secured);
            print {*STDERR} Dumper($r);
        }
    }
    return WebService::Hexonet::Connector::Response->new( $r, $newcmd, $cfg );
}


sub requestNextResponsePage {
    my ( $self, $rr ) = @_;
    my $mycmd = $rr->getCommand();
    if ( defined $mycmd->{LAST} ) {
        croak 'Parameter LAST in use! Please remove it to avoid issues in requestNextPage.';
    }
    my $first = 0;
    if ( defined $mycmd->{FIRST} ) {
        $first = $mycmd->{FIRST};
    }
    my $total = $rr->getRecordsTotalCount();
    my $limit = $rr->getRecordsLimitation();
    $first += $limit;
    if ( $first < $total ) {
        $mycmd->{FIRST} = $first;
        $mycmd->{LIMIT} = $limit;
        return $self->request($mycmd);
    }
    return;
}


sub requestAllResponsePages {
    my ( $self, $cmd ) = @_;
    my @responses = ();
    my $command   = {};
    foreach my $key ( keys %{$cmd} ) {
        $command->{$key} = $cmd->{$key};
    }
    $command->{FIRST} = 0;
    my $rr  = $self->request($command);
    my $tmp = $rr;
    my $idx = 0;
    while ( defined $tmp ) {
        push @responses, $tmp;
        $tmp = $self->requestNextResponsePage($tmp);
    }
    return \@responses;
}


sub setUserView {
    my ( $self, $uid ) = @_;
    $self->{socketConfig}->setUser($uid);
    return $self;
}


sub resetUserView {
    my $self = shift;
    $self->{socketConfig}->setUser(q{});
    return $self;
}


sub useDefaultConnectionSetup {
    my $self = shift;
    return $self->setURL($ISPAPI_CONNECTION_URL);
}


sub useHighPerformanceConnectionSetup {
    my $self = shift;
    return $self->setURL($ISPAPI_CONNECTION_URL_PROXY);
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


sub _flattenCommand {
    my ( $self, $cmd ) = @_;
    for my $key ( keys %{$cmd} ) {
        my $newkey = uc $key;
        if ( $newkey ne $key ) {
            $cmd->{$newkey} = delete $cmd->{$key};
        }
        if ( ref( $cmd->{$newkey} ) eq 'ARRAY' ) {
            my @val = @{ $cmd->{$newkey} };
            my $idx = 0;
            for my $str (@val) {
                $str =~ s/[\r\n]//gmsx;
                $cmd->{"${key}${idx}"} = $str;
                $idx++;
            }
            delete $cmd->{$newkey};
        }
    }
    return $cmd;
}


sub _autoIDNConvert {
    my ( $self, $cmd ) = @_;
    if ( $cmd->{'COMMAND'} =~ /^CONVERTIDN$/imsx ) {
        return $cmd;
    }
    my @keys = grep {/^(DOMAIN|NAMESERVER|DNSZONE)(\d*)$/imsx} keys %{$cmd};
    if ( scalar @keys == 0 ) {
        return $cmd;
    }
    my @toconvert = ();
    my @idxs      = ();
    foreach my $key (@keys) {
        my $val = $cmd->{$key};
        if ( $val =~ /[^[:lower:]\d. -]/imsx ) {
            push @toconvert, $val;
            push @idxs,      $key;
        }
    }
    my $r = $self->request(
        {   COMMAND => 'ConvertIDN',
            DOMAIN  => \@toconvert
        }
    );
    if ( $r->isSuccess() ) {
        my $col = $r->getColumn('ACE');
        if ($col) {
            my $data = $col->getData();
            my $idx  = 0;
            foreach my $pc ( @{$data} ) {
                $cmd->{ $idxs[ $idx ] } = $pc;
                $idx++;
            }
        }
    }
    return $cmd;
}

1;

__END__

=pod

=head1 NAME

WebService::Hexonet::Connector::APIClient - Library to communicate with the insanely fast L<HEXONET Backend API|https://www.hexonet.net>.

=head1 SYNOPSIS

This module helps to integrate the communication with the HEXONET Backend System.
To be used in the way:

    use 5.014_004;
    use strict;
    use warnings;
    use WebService::Hexonet::Connector;

    # Create a connection with the URL, entity, login and password
    # Use " 1234 " as entity for the OT&E, and " 54 cd " for productive use
    # Don't have a Hexonet Account yet? Get one here: www.hexonet.net/sign-up

    # create a new instance
    my $cl = WebService::Hexonet::Connector::APIClient->new();

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
    # $cl->login(" 12345678 ");
    if ($r->isSuccess()) {
        # use saveSession for your needs
        # to apply the API session to your frontend session.
        # For later reuse (no need to specify credentials and otp code)
        # within every request to your frontend server,
        # rebuild the session by using reuseSession method accordingly.
        # No need to provide credentials, no need to select a system,
        # nor to provide a otp code further on.

        $r = $cl->request({ COMMAND: 'StatusAccount' });
        # further logic, further commands

        # perform logout, you may check the result as shown with the login method
        $cl->logout();
    }

    # -------------------------
    # SESSIONless communication
    # -------------------------
    $r = $cl->request({ COMMAND: 'StatusAccount' });


	# -------------------------------------
	# Working with returned Response object
	# -------------------------------------
	# Display the result in the format you want
	my $res;
	$res = $r->getListHash());
	$res = $r->getHash();
	$res = $r->getPlain();

	# Get the response code and the response description
	my $code = $r->getCode();
	my $description = $r->getDescription();

	print "$code$description ";

	# There are further useful methods that help to access data
	# like getColumnIndex, getColumn, getRecord, etc.
	# Check the method documentation below.

See the documented methods for deeper information.

=head1 DESCRIPTION

This library is used to provide all functionality to be able to communicate with the HEXONET Backend System.

=head2 Methods

=over

=item C<new>

Returns a new L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance.

=item C<enableDebugMode>

Activates the debug mode. Details of the API communication are put to STDOUT.
Like API command, POST data, API plain-text response.
Debug mode is inactive by default.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<disableDebugMode>

Deactivates the debug mode. Debug mode is inactive by default.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<getPOSTData( $command )>

Get POST data fields ready to use for HTTP communication based on LWP::UserAgent.
Specify the API command for the request by $command.
This method is internally used by the request method.
Returns a hash.

=item C<getProxy>

Returns the configured Proxy URL to use for API communication as string.

=item C<getReferer>

Returns the configured HTTP Header `Referer` value to use for API communication as string.

=item C<getSession>

Returns the API session in use as string.

=item C<getURL>

Returns the url in use pointing to the Backend System to communicate with, as string.

=item C<getUserAgent>

Returns the user-agent string.

=item C<getVersion>

Returns the SDK version currently in use as string.

=item C<saveSession( $sessionhash )>

Save the current API session data into a given session hash object.
This might help you to add the backend system session into your frontend session.
Use reuseSession method to set a new instance of this module to that session.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<reuseSession( $sessionhash )>

Reuse API session data that got previously saved into the given session hash object
by method saveSession.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setURL( $url )>

Set a different backend system url to be used for communication.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setOTP( $otpcode )>

Set your otp code. To be used in case of active 2FA.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setProxy( $proxy )>

Set the Proxy URL to use for API communication.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setReferer( $referer )>

Set the HTTP Header `Referer` value to use for API communication.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setSession( $sessionid )>

Set the API session id to use. Automatically handled after successful session login
based on method login or loginExtended.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setRemoteIPAddress( $ip )>

Set the outgoing ip address to be used in API communication.
Use this in case of an active IP filter setting for your account.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setCredentials( $user, $pw )>

Set the credentials to use in API communication.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setRoleCredentials( $user, $role, $pw)>

Set the role user credentials to use in API communication.
NOTE: the role user specified by $role has to be directly assigned to the
specified account specified by $user.
The specified password $pw belongs to the role user, not to the account.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<setUserAgent( $str, $rv )>

Set a custom user agent header. This is useful for tools that use our SDK.
Specify the client label in $str and the revision number in $rv.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining .

=item C<login( $otpcode )>

Perform a session login. Entry point for the session-based communication.
You may specify your OTP code by $otpcode.
Returns an instance of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<loginExtended( $params, $otpcode )>

Perform a session login. Entry point for the session-based communication.
You may specify your OTP code by $otpcode.
Specify additional command parameter for API command " StartSession " in
Hash $params.
Possible parameters can be found in the L<API Documentation for StartSession|https://github.com/hexonet/hexonet-api-documentation/blob/master/API/USER/SESSION/STARTSESSION.md>.
Returns an instance of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<logout>

Perfom a session logout. This destroys the API session.
Returns an instance of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<request( $command )>

Requests the given API Command $command to the Backend System.
Returns an instance of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<requestNextResponsePage( $lastresponse )>

Requests the next response page for the provided api response $lastresponse.
Returns an instance of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<requestAllResponsePages( $command )>

Requests all response pages for the specified command.
NOTE: this might take some time. Requests are not made in parallel!
Returns an array of instances of L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response>.

=item C<setUserView( $subuser )>

Activate read/write Data View on the specified subuser account.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<resetUserView>

Reset the data view activated by setUserView.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<useDefaultConnectionSetup>

Use the Default Setup to connect to our backend systems. This is the default!
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<useHighPerformanceConnectionSetup>

Use the High Performance Connection Setup to connect to our backend systems. This is not the default! Read README.md for Details.
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<useLIVESystem>

Use the LIVE Backend System as communication endpoint.
Usage may lead to costs. BUT - are system is a prepaid system.
As long as you don't have charged your account, you cannot order.
This is the default!
Returns the current L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> instance in use for method chaining.

=item C<_flattenCommand( $cmd )>

Private method. Converts all keys of the given hash into upper case letters and flattens parameters using nested arrays to string parameters.
Returns the new command.


=item C<_autoIDNConvert( $cmd )>

Private method. Converts all affected parameter values to punycode as our API only works with punycode domain names, not with IDN.
Returns the new command.

=back

=head1 LICENSE AND COPYRIGHT

This program is licensed under the L<MIT License|https://raw.githubusercontent.com/hexonet/perl-sdk/master/LICENSE>.

=head1 AUTHOR

L<HEXONET GmbH|https://www.hexonet.net>

=cut
