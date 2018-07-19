package HEXONET::apiconnector::Response;

use strict;
use warnings;
use HEXONET::apiconnector::Util;
use overload
  '%{}' => \&_as_hash_op,
  '@{}' => \&as_list,
  ;

our $VERSION = '1.10';

sub new {
	my $class = shift;
	my $response = shift;
	my $self = {};

	if ( (ref $response) eq "HASH" ) {
		$self->{_response_hash} = $response;
	}elsif ( !ref $response ) {
		$self->{_response_string} = $response;
	}else {
		die "Unsupported Class: ".(ref $response);
	}

	bless $self, $class;
	$self->{test} = 1;

	return bless $self, $class;
}


sub as_string {
	my $self = shift;

	return $self->{_response_string};
}


sub _as_hash_op {
	my $self = shift;

	# Don't hide the $self hash if called from within class
	my ($pkg) = caller 0;
	return $self if $pkg->isa('HEXONET::apiconnector::Response');
	return $self->as_hash();
}


sub as_hash {
	my $self = shift;

	return $self->{_response_hash} if defined $self->{_response_hash};
	$self->{_response_hash} = HEXONET::apiconnector::Util::response_to_hash($self->{_response_string});
	return $self->{_response_hash};
}


sub as_list_hash {
	my $self = shift;

	return $self->{_response_list_hash} if defined $self->{_response_list_hash};
	$self->{_response_list_hash} = HEXONET::apiconnector::Util::response_to_list_hash($self->as_hash());
	return $self->{_response_list_hash};
}


sub as_list {
	my $self = shift;
	my $list_hash = $self->as_list_hash();
	if (wantarray) {
		return @{$list_hash->{ITEMS}};
	}
	return $list_hash->{ITEMS};
}


sub code {
	my $self = shift;
	return $self->as_hash()->{CODE};
}


sub description {
	my $self = shift;
	return $self->as_hash()->{DESCRIPTION};
}


sub properties {
	my $self = shift;
	return $self->as_hash()->{PROPERTY};
}


sub runtime {
	my $self = shift;
	return $self->as_hash()->{RUNTIME};
}


sub queuetime {
	my $self = shift;
	return $self->as_hash()->{QUEUETIME};
}


sub property {
	my $self = shift;
	my $property = shift;
	my $index = shift;
	my $p = $self->as_hash()->{PROPERTY};
	if ( defined $index ) {
		return (LIST { undef }SCALAR { undef }) unless exists $p->{$property};
		return $p->{$property}[$index];
	}
	if (wantarray) {
		return () unless exists $p->{$property};
		return @{$p->{$property}};
	}
	return (LIST { undef }SCALAR { undef }) unless exists $p->{$property};
	return $p->{$property};
}


sub is_success {
	my $self = shift;
	return $self->as_hash()->{CODE} =~ /^2/;
}


sub is_tmp_error {
	my $self = shift;
	return $self->as_hash()->{CODE} =~ /^4/;
}

sub columns { my $self = shift; return $self->as_list_hash()->{COLUMNS}; }
sub first { my $self = shift; return $self->as_list_hash()->{FIRST}; }
sub last { my $self = shift; return $self->as_list_hash()->{LAST}; }
sub count { my $self = shift; return $self->as_list_hash()->{COUNT}; }
sub limit { my $self = shift; return $self->as_list_hash()->{LIMIT}; }
sub total { my $self = shift; return $self->as_list_hash()->{TOTAL}; }
sub pages { my $self = shift; return $self->as_list_hash()->{PAGES}; }
sub page { my $self = shift; return $self->as_list_hash()->{PAGE}; }
sub prevpage { my $self = shift; return $self->as_list_hash()->{PREVPAGE}; }
sub prevpagefirst { my $self = shift; return $self->as_list_hash()->{PREVPAGEFIRST}; }
sub nextpage { my $self = shift; return $self->as_list_hash()->{NEXTPAGE}; }
sub nextpagefirst { my $self = shift; return $self->as_list_hash()->{NEXTPAGEFIRST}; }
sub lastpagefirst { my $self = shift; return $self->as_list_hash()->{LASTPAGEFIRST}; }

1;