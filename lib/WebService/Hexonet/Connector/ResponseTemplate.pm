package WebService::Hexonet::Connector::ResponseTemplate;

use 5.014_004;
use strict;
use warnings;
use WebService::Hexonet::Connector::ResponseParser;

our $VERSION = 'v1.12.1';


sub new {
	my ( $class, $raw ) = @_;
	my $self = {};
	if ( !defined $raw || length $raw == 0) {
		$raw = "[RESPONSE]\r\nCODE=423\r\nDESCRIPTION=Empty API response\r\nEOF\r\n";
	}
	$self->{raw}  = $raw;
	$self->{hash} = WebService::Hexonet::Connector::ResponseParser::parse($raw);
	return bless $self, $class;
}


sub getCode {
	my $self = shift;
	return ( $self->{hash}->{CODE} + 0 );
}


sub getDescription {
	my $self = shift;
	return $self->{hash}->{DESCRIPTION};
}


sub getPlain {
	my $self = shift;
	return $self->{raw};
}


sub getQueuetime {
	my $self = shift;
	if ( defined $self->{hash}->{QUEUETIME} ) {
		return ( $self->{hash}->{QUEUETIME} + 0.00 );
	}
	return 0.00;
}


sub getHash {
	my $self = shift;
	return $self->{hash};
}


sub getRuntime {
	my $self = shift;
	if ( defined $self->{hash}->{RUNTIME} ) {
		return ( $self->{hash}->{RUNTIME} + 0.00 );
	}
	return 0.00;
}


sub isError {
	my $self = shift;
	my $first = substr $self->{hash}->{CODE}, 0, 1;
	return ( $first eq '5' );
}


sub isSuccess {
	my $self = shift;
	my $first = substr $self->{hash}->{CODE}, 0, 1;
	return ( $first eq '2' );
}


sub isTmpError {
	my $self = shift;
	my $first = substr $self->{hash}->{CODE}, 0, 1;
	return ( $first eq '4' );
}

1;

__END__

=head1 NAME

WebService::Hexonet::Connector::ResponseTemplate - Library that provides basic functionality
to access API response data.

=head1 SYNOPSIS

This module is internally used by the WebService::Hexonet::Connector::Response module as described below.
To be used in the way:

    # specify the API plain-text response (this is just an example that won't fit to the command above)
    $plain = "[RESPONSE]\r\nCODE=200\r\nDESCRIPTION=Command completed successfully\r\nEOF\r\n";
  
    # create a new instance
    $r = WebService::Hexonet::Connector::ResponseTemplate->new($plain);

The difference of this library and the Response library is simply that this library

=over
=item *
does not provide further data access possibilities based on Column and Record library
=item *
does not require an API command to be specified in constructor
=back

=head1 DESCRIPTION

HEXONET Backend API always responds in plain-text format that needs to get parsed into a useful
data structure. This module manages all this: parsing data into hash format.
It provides different methods to access the data to fit your needs.
It is used as base class for WebService::Hexonet::Connector::Response.
We internally use this module also in our automated tests to play with hardcoded API responses.

=head2 Methods

=over

=item C<new( $plain )>

Returns a new WebService::Hexonet::Connector::ResponseTemplate object.
Specify the plain-text API response as $plain.

=item C<getCode>

Returns the API response code as int. 

=item C<getDescription>

Returns the API response description. 

=item C<getPlain>

Returns the plain-text API response.

=item C<getQueuetime>

Returns the Queuetime of the API response decimal. 

=item C<getHash>

Returns the API response as Hash. 

=item C<getRuntime>

Returns the Runtime of the API response code as decimal. 

=item C<isError>

Checks if the API response code represents an error case.
500 <= Code <= 599

=item C<isSuccess>

Checks if the API response code represents a success case.
200 <= Code <= 299

=item C<isTmpError>

Checks if the API response code represents a temporary error case.
400 <= Code <= 499

=back

=head1 LICENSE AND COPYRIGHT

This program is licensed under the L<MIT License|https://raw.githubusercontent.com/hexonet/perl-sdk/master/LICENSE>.

=head1 AUTHOR

L<HEXONET GmbH|https://www.hexonet.net>

=cut