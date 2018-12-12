package WebService::Hexonet::Connector::ResponseParser;

use 5.014_004;
use strict;
use warnings;

our $VERSION = 'v1.12.1';


sub parse {
	my $response = shift;
	my %hash = ();
	$response =~ s/\r\n/\n/gmsx;
	foreach ( split /\n/msx, $response ) {
		if (/^([^\=]*[^\t\= ])[\t ]*=[\t ]*(.+)/msx) {
			my $attr  = $1;
			my $value = $2;
			$value =~ s/[\t ]*$//msx;
			if ( $attr =~ /^property\[([^\]]*)\]/imsx ) {
				if ( !defined $hash{PROPERTY} ) {
					$hash{PROPERTY} = {};
				}
				my $prop = uc $1;
				$prop =~ s/\s//ogmsx;
				if ( defined $hash{PROPERTY}{$prop} ) {
					push @{ $hash{PROPERTY}{$prop} }, $value;
				} else {
					$hash{PROPERTY}{$prop} = [$value];
				}
			} else {
				$hash{ uc $attr } = $value;
			}
		}
	}
	if ( !defined $hash{DESCRIPTION} ) {
		$hash{DESCRIPTION} = q{};
	}
	return \%hash;
}


sub serialize {
	my $h = shift;
	my $plain = '[RESPONSE]';
	if ( defined $h->{PROPERTY} ) {
		my $props = $h->{PROPERTY};
		foreach my $key (sort keys %{$props}){
			my $i = 0;
			foreach my $val (@{$props->{$key}}) {
				$plain .= "\r\nPROPERTY[${key}][${i}]=${val}";
				$i++;
			}
		}
	}
	if ( defined $h->{CODE} ) {
		$plain .= "\r\nCODE=" . $h->{CODE};
	}
	if ( defined $h->{DESCRIPTION} ) {
		$plain .= "\r\nDESCRIPTION=" . $h->{DESCRIPTION};
	}
	if ( defined $h->{QUEUETIME} ) {
		$plain .= "\r\nQUEUETIME=" . $h->{QUEUETIME};
	}
	if ( defined $h->{RUNTIME} ) {
		$plain .= "\r\nRUNTIME=" . $h->{RUNTIME};
	}
	$plain .= "\r\nEOF\r\n";
	return $plain;
}

1;
