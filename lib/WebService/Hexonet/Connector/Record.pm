package WebService::Hexonet::Connector::Record;

use 5.014_004;
use strict;
use warnings;

our $VERSION = 'v1.12.1';


sub new {
	my ( $class, $data ) = @_;
	return bless {data => $data}, $class;
}


sub getData {
	my $self = shift;
	return $self->{data};
}


sub getDataByKey {
	my $self = shift;
	my $key  = shift;
	return $self->{data}->{$key}
	  if $self->hasData($key);
	return;
}


sub hasData {
	my $self = shift;
	my $key  = shift;
	return defined $self->{data}->{$key};
}

1;
