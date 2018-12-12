package WebService::Hexonet::Connector;

use 5.014_004;
use strict;
use warnings;
use WebService::Hexonet::Connector::APIClient;
use WebService::Hexonet::Connector::Column;
use WebService::Hexonet::Connector::Record;
use WebService::Hexonet::Connector::Response;
use WebService::Hexonet::Connector::ResponseParser;
use WebService::Hexonet::Connector::ResponseTemplate;
use WebService::Hexonet::Connector::ResponseTemplateManager;
use WebService::Hexonet::Connector::SocketConfig;

our $VERSION = 'v1.12.1';

1;

__END__

=head1 NAME

WebService::Hexonet::Connector - Connector library for the insanely fast L<HEXONET Backend API|https://www.hexonet.net/>.

=head1 SYNOPSIS

	###############################
	# How to use this Library?
	###############################

	# Install our module by
	cpan WebService::Hexonet::Connector
	# or
	cpanm WebService::Hexonet::Connector
	# NOTE: We suggest to use cpanm (App::cpanminus) for several reasons.

	use 5.014_004;
	use strict;
	use warnings;
	use WebService::Hexonet::Connector::APIClient;

	# Create a connection with the URL, entity, login and password
	# Use "1234" as entity for the OT&E, and "54cd" for productive use
	# Don't have a Hexonet Account yet? Get one here: www.hexonet.net/sign-up
	my $cl = APIClient->new();
	$cl->useOTESystem();
	$cl->setCredentials("test.user", "test.passw0rd");
	$cl->setRemoteIPAddress("1.2.3.4");

	# Call a command
	my $response = $cl->request({
		command => "querydomainlist",
		limit => 5
	});

	# Display the result in the format you want
	my $res = $response->getListHash());
	$res = $response->getHash();
	$res = $response->getPlain();

	# Get the response code and the response description
	my $code = $response->getCode();
	my $description = $response->getDescription();

	print "$code $description";

=head1 DESCRIPTION

This module allows to query the API and to deal with different response formats (list, list_hash, hash).
It provides a short hand method (WebService::Hexonet::Connector::connect) to instantiate API clients.

A helper utility module is also included for tasks like date handling and string encoding.

=head1 AVAILABLE SUBMODULES

We've split our functionality into submodules to give this module a better structure.

=over 4

=item L<WebService::Hexonet::Connector::APIClient|WebService::Hexonet::Connector::APIClient> - API Client functionality.

=item L<WebService::Hexonet::Connector::Column|WebService::Hexonet::Connector::Column> - API Response Data handling as "Column".

=item L<WebService::Hexonet::Connector::Record|WebService::Hexonet::Connector::Record> - API Response Data handling as "Record".

=item L<WebService::Hexonet::Connector::Response|WebService::Hexonet::Connector::Response> - API Response functionality.

=item L<WebService::Hexonet::Connector::ResponseParser|WebService::Hexonet::Connector::ResponseParser> - API Response Parser functionality.

=item L<WebService::Hexonet::Connector::ResponseTemplate|WebService::Hexonet::Connector::ResponseTemplate> - API Response Template functionality.

=item L<WebService::Hexonet::Connector::ResponseTemplateManager|WebService::Hexonet::Connector::ResponseTemplateManager> - API Response Template Manager functionality.

=item L<WebService::Hexonet::Connector::SocketConfig|WebService::Hexonet::Connector::SocketConfig> - API Communication Configuration functionality.

=back

=head1 LICENSE AND COPYRIGHT

This program is licensed under the L<MIT License|https://raw.githubusercontent.com/hexonet/perl-sdk/master/LICENSE>.

=head1 AUTHOR

L<HEXONET GmbH|https://www.hexonet.net>

=cut
