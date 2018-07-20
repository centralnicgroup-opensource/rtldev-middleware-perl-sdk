use strict;
use warnings;

use Test::More tests => 5;

our $VERSION = '1.00';

# T1-3: test import modules
use_ok( "lib",                   qw(./lib) );
use_ok( "Scalar::Util",          qw(blessed) );
use_ok( "HEXONET::Apiconnector", $VERSION );

# T4: instantiate API Client
our $api = HEXONET::Apiconnector::connect(
    url      => 'https://coreapi.1api.net/api/call.cgi',
    entity   => '1234',
    login    => 'test.user',
    password => 'test.passw0rd'
);
our $cl = blessed($api);
is( $cl, "HEXONET::Apiconnector::Connection",
    "API Client Instance type check" );

# T5: make API call and test Response instance
our $r = $api->call(
    {
        COMMAND => "QueryDomainList",
        LIMIT   => 5,
        FIRST   => 0
    }
);

$cl = blessed($r);
is( $cl, "HEXONET::Apiconnector::Response",
    "API Response Instance type check" );
