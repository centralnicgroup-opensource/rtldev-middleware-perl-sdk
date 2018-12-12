package WebService::Hexonet::Connector::Column;

use 5.014_004;
use strict;
use warnings;

our $VERSION = 'v1.12.1';


sub new {
	my ( $class, $key, @data ) = @_;
	my $self = {};
	$self->{key} = $key;
	@{ $self->{data} } = @data;
	$self->{length} = scalar @data;
	return bless $self, $class;
}


sub getKey {
	my $self = shift;
	return $self->{key};
}


sub getData {
	my $self = shift;
	return $self->{data};
}


sub getDataByIndex {
	my $self = shift;
	my $idx  = shift;
	return $self->{data}[$idx]
	  if $self->hasDataIndex($idx);
	return;
}


sub hasDataIndex {
	my $self = shift;
	my $idx  = shift;
	return $idx < $self->{length};
}

1;
