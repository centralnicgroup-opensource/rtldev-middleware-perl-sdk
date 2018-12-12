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
