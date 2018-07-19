package HEXONET::apiconnector;

use 5.026000;
use strict;
use warnings;
use HEXONET::apiconnector::Connection;

our $VERSION = '1.10';

sub connect {
    return new HEXONET::apiconnector::Connection(@_);
}

1;

__END__

=head1 NAME

HEXONET::apiconnector Perl Module - Connector library for the insanely fast HEXONET Backend API

=head1 SYNOPSIS

	###############################
	# How to use this Library?
	###############################

	# Copy the "lib" directory in your project and setup the new "lib" directory
	use FindBin;
	use lib "$FindBin::Bin/lib";

	# Import the HEXONET package
	use HEXONET::apiconnector;

	# Create a connection with the URL, entity, login and password
	# Use "1234" as entity for the OT&E, and "54cd" for productive use
	# Don't have a HEXONET Account yet? Get one here: www.hexonet.net/sign-up
	my $api = HEXONET::apiconnector::connect(
		url => 'https://coreapi.1api.net/api/call.cgi',
		entity => '1234',
		login => 'test.user',
		password => 'test.passw0rd',
	);
	
	# Call a command
	my $response = $api->call({
		COMMAND => "querydomainlist",
		LIMIT => 5
	});

	# Display the result in the format you want
	my $res = $response->as_list();
	my $res = $response->as_list_hash();
	my $res = $response->as_hash();

	# Get the response code and the response description
	my $code = $response->code();
	my $description = $response->description();


=head1 DESCRIPTION

This module allows the customer to query the API and get different type of response back (list, list_hash, hash)

A helper util module is also included for tasks like date handling and string encoding.

=head1 METHODS HEXONET

=over 4

=item C<connect(url, entity, login, password, user, role)>

Function connect Returns a Connection object connected to the API Server (URL, ENTITY, LOGIN, PASSWORD are mandatory to connect the server, ROLE ans USER are optional)

=back

=head1 METHODS HEXONET::apiconnector::Connection

=over 4

=item C<call(command, config)>

Make a curl API call and returns the response as a response object

=item C<call_raw(command,config)>

Make a curl API call and returns the response as a string

=item C<call_raw_http(command, config)>

Make a curl API call over HTTP(S) and returns the response as a string

=back

=head1 METHODS HEXONET::apiconnector::Response

=over 4

=item C<as_string()>

Returns the response as a string

=item C<as_hash()>

Returns the response as a hash

=item C<as_list_hash()>

Returns the response as a list hash

=item C<as_list()>

Returns the response as a list

=item C<code()>

Returns the response code

=item C<description()>

Returns the response description

=item C<properties()>

Returns the response properties

=item C<runtime()>

Returns the response runtime

=item C<queuetime()>

Returns the response queutime

=item C<property(index)>

Returns the property for a given index If no index given, the complete property list is returned

=item C<is_success()>

Returns true if the results is a success Success = response code starting with 2

=item C<is_tmp_error()>

Returns true if the results is a tmp error tmp error = response code starting with 4

=item C<columns()>

Returns the columns

=item C<first()>

Returns the index of the first element

=item C<last()>

Returns the index of the last element

=item C<count()>

Returns the number of list elements returned (= last - first + 1)

=item C<limit()>

Returns the limit of the response

=item C<total()>

Returns the total number of elements found (!= count)

=item C<pages()>

Returns the number of pages

=item C<page()>

Returns the number of the current page (starts with 1)

=item C<prevpage()>

Returns the number of the previous page

=item C<prevpagefirst()>

Returns the first index for the previous page

=item C<nextpage()>

Returns the number of the next page

=item C<nextpagefirst()>

Returns the first index for the next page

=item C<lastpagefirst()>

Returns the first index for the last page

=back

=head1 METHODS HEXONET::apiconnector::Util

=over 4

=item C<timesql(sqldatetime)>

Convert the SQL datetime to Unix-Timestamp

=item C<sqltime(timestamp)>

Convert the Unix-Timestamp to a SQL datetime If no timestamp given, returns the current datetime

=item C<url_encode(string)>

URL-encodes string This function is convenient when encoding a string to be used in a query part of a URL

=item C<url_decode(string)>

Decodes URL-encoded string Decodes any %## encoding in the given string.

=item C<base64_encode(string)>

Encodes data with MIME base64 This encoding is designed to make binary data survive transport through transport layers that are not 8-bit clean, such as mail bodies.

=item C<base64_decode(string)>

Decodes data encoded with MIME base64

=item C<command_encode(command)>

Encode the command array in a command-string

=item C<response_to_hash(response)>

Convert the response string as a hash

=item C<response_to_list_hash(response)>

Convert the response string as a list hash

=back

=head1 AUTHOR

HEXONET GmbH

L<https://www.hexonet.net>

=head1 LICENSE

MIT

=cut
