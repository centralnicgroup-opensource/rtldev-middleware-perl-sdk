# perl-sdk / WebService::Hexonet::Connector

[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![build](https://travis-ci.com/hexonet/perl-sdk.svg?branch=master)](https://travis-ci.com/hexonet/perl-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/hexonet/perl-sdk/blob/master/CONTRIBUTING.md)

This module is a connector library for the insanely fast HEXONET Backend API. For further informations visit our [homepage](http://hexonet.net) and do not hesitate to [contact us](https://www.hexonet.net/contact).

## Resources

* [Usage Guide](https://github.com/hexonet/perl-sdk/blob/master/README.md#how-to-use-this-module-in-your-project)
* [SDK Documenation](https://rawgit.com/hexonet/perl-sdk/master/docs/hexonet.html)
* [HEXONET Backend API Documentation](https://github.com/hexonet/hexonet-api-documentation/tree/master/API)
* [Release Notes](https://github.com/hexonet/perl-sdk/releases)
* [Development Guide](https://github.com/hexonet/perl-sdk/wiki/Development-Guide)

## Features

* Automatic IDN Domain name conversion to punycode (our API accepts only punycode format in commands)
* Allow nested associative arrays in API commands to improve for bulk parameters
* Connecting and communication with our API
* Several ways to access and deal with response data
* Getting the command again returned together with the response
* sessionless communication
* session-based communication
* possibility to save API session identifier in session

## How to use this module in your project

We have also a demo app available showing how to integrate and use our SDK. See [here](https://github.com/hexonet/perl-sdk-demo).

### Requirements

* Installed most current version of perl 5
* Installed cpanm (App::cpanminus) as suggested alternative for cpan command

### Install from CPAN

```bash
# by Module ID (suggested!)
cpanm WebService::Hexonet::Connector~2.0000

# or by filename
cpanm HEXONET/WebSservice-Hexonet-Connector-v2.0.0.tar.gz
```

NOTE: I got this only working by sudo'ing these commands.
In case you install by filename, please check the [release overview](https://github.com/hexonet/perl-sdk/releases) for the most current release and use that version instead.

### Usage Examples

Please have an eye on our [HEXONET Backend API documentation](https://github.com/hexonet/hexonet-api-documentation/tree/master/API). Here you can find information on available Commands and their response data.

#### Session based API Communication

```perl
use 5.026_000;
use strict;
use warnings;
use WebService::Hexonet::Connector;

my $cl = WebService::Hexonet::Connector::APIClient->new();
$cl->useOTESystem();
$cl->setCredentials('test.user', 'test.passw0rd');
$cl->setRemoteIPAddress('1.2.3.4');

my $response = $cl->login();
# in case of 2FA use:
# my $response = $cl->login("12345678");

if ($response->isSuccess()) {
    # now the session will be used for communication in background
    # instead of the provided credentials
    # if you need something to rebuild connection on next page visit,
    # so in a frontend-session based environment, please consider
    # saveSession and reuseSession methods

    # Call a command
    my $response = $cl->request(
        {
            COMMAND => 'QueryDomainList',
            LIMIT => 5
        }
    );

    # get the result in the format you want
    my $res;
    $res = $response->getListHash();
    $res = $response->getHash();
    $res = $response->getPlain();

    # get the response code and the response description
    my $code = $response->getCode();
    my $description = $response->getDescription();

    print "$code $description";

    # close Backend API Session
    # you may verify the result of the logout procedure
    # like for the login procedure above
    $cl->logout();
}
```

#### Sessionless API Communication

```perl
use 5.026_000;
use strict;
use warnings;
use WebService::Hexonet::Connector;

my $cl = WebService::Hexonet::Connector::APIClient->new();
$cl->useOTESystem();
$cl->setCredentials('test.user', 'test.passw0rd');
$cl->setRemoteIPAddress('1.2.3.4');
# in case of 2FA use:
# $cl->setOTP("12345678")

# Call a command
my $response = $cl->request(
    {
        COMMAND => 'QueryDomainList',
        LIMIT => 5
    }
);

# get the result in the format you want
my $res;
$res = $response->getListHash();
$res = $response->getHash();
$res = $response->getPlain();

# get the response code and the response description
my $code = $response->getCode();
my $description = $response->getDescription();

print "$code $description";
```

#### Using bulk parameters [SINCE 2.3.0]

Using the below is supported to improve using commands. It will automatically be converted to parameters `DOMAIN0` and `DOMAIN1` accordingly.
This of course works for all commands and all such parameters.

```perl
use 5.026_000;
use strict;
use warnings;
use WebService::Hexonet::Connector;

my $cl = WebService::Hexonet::Connector::APIClient->new();
$cl->useOTESystem();
$cl->setCredentials('test.user', 'test.passw0rd');
$cl->setRemoteIPAddress('1.2.3.4');
# in case of 2FA use:
# $cl->setOTP("12345678")

# Call a command
my $response = $cl->request(
    {
        COMMAND => 'QueryDomainOptions',
        DOMAIN => ['example1.com', 'example2.com']
    }
);

# get the response code and the response description
my $code = $response->getCode();
my $description = $response->getDescription();

print "$code $description";
```

## Contributing

Please read [our development guide](https://github.com/hexonet/perl-sdk/wiki/Development-Guide) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Anthony Schneider** - *development* - [AnthonySchn](https://github.com/anthonyschn)
* **Kai Schwarz** - *development* - [PapaKai](https://github.com/papakai)

See also the list of [contributors](https://github.com/hexonet/perl-sdk/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
