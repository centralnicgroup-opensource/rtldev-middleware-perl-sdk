=head1 NAME

ISPAPI Library - Perl module for querying the API

=head1 SYNOPSIS

	###############################
	# How to use this Library?
	###############################

	# Copy the "lib" directory in your project and setup the new "lib" directory
	use FindBin;
	use lib "$FindBin::Bin/lib";

	# Import the ISPAPI package
	use ISPAPI;

	# Create a connection with the URL, entity, login and password
	# Use "1234" as entity for the OT&E, and "54cd" for productive use
	# Don't have a HEXONET Account yet? Get one here: www.hexonet.net/sign-up
	my $api = ISPAPI::connect(
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

=head1 METHODS ISPAPI

=over 4

=item C<connect(url, entity, login, password, user, role)>

Function connect Returns a Connection object connected to the API Server (URL, ENTITY, LOGIN, PASSWORD are mandatory to connect the server, ROLE ans USER are optional)

=back

=head1 METHODS ISPAPI::Connection

=over 4

=item C<call(command, config)>

Make a curl API call and returns the response as a response object

=item C<call_raw(command,config)>

Make a curl API call and returns the response as a string

=item C<call_raw_http(command, config)>

Make a curl API call over HTTP(S) and returns the response as a string

=back

=head1 METHODS ISPAPI::Response

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

=head1 METHODS ISPAPI::Util

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

Hexonet GmbH

L<http://www.hexonet.net>

=cut




package ISPAPI;

use strict;
use vars qw($VERSION);


$VERSION = '1.0';

sub connect {
	return new ISPAPI::Connection(@_);
}


package ISPAPI::Connection;

use LWP::UserAgent;

sub new {
	my $class = shift;
	my $self = { @_ };
	foreach my $key ( %$self ) {
		my $value = $self->{$key};
		delete $self->{$key};
		$self->{lc $key} = $value;
	}
	return bless $self, $class;
}



sub call {
	my $self = shift;
	my $command = shift;
	my $config = shift;
	return ISPAPI::Response->new($self->call_raw($command, $config));
}


sub call_raw {
	my $self = shift;
	my $command = shift;
	my $config = shift;

	$config = {} if !defined $config;
	$config = { User => $config } if (defined $config) && (!ref $config);

	return $self->call_raw_http($command, $config);
}


sub call_raw_http {
	my $self = shift;
	my $command = shift;
	my $config = shift;

	my $ua = $self->_get_useragent();

	my $url = $self->{url};
	my $post = {
		s_command => (scalar ISPAPI::Util::command_encode($command))
	};
	$post->{s_entity} = $self->{entity} if exists $self->{entity};
	$post->{s_login} = $self->{login} if exists $self->{login};
	$post->{s_pw} = $self->{password} if exists $self->{password};
	$post->{s_user} = $self->{user} if exists $self->{user};
	$post->{s_login} = $self->{login} . "!" . $self->{role} if exists $self->{role};

	if ( exists $config->{user} ) {
		if ( exists $post->{s_user} ) {
			$post->{s_user} .= " ".$config->{user};
		}
		else {
			$post->{s_user} = $config->{user};
		}
	}

	my $response = $self->{_useragent}->post($url, $post );
	return $response->content();	
	
}


sub _get_useragent {
	my $self = shift;
	return $self->{_useragent} if exists $self->{_useragent};
	$self->{_useragent} = new LWP::UserAgent(
		agent => "ISPAPI-perl/$ISPAPI::VERSION",
		keep_alive => 4
	);
	return $self->{_useragent};
}



package ISPAPI::Response;

use overload
	'%{}' => \&_as_hash_op,
	'@{}' => \&as_list,
;

sub new {
	my $class = shift;
	my $response = shift;
	my $self = {};

	if ( (ref $response) eq "HASH" ) {
		$self->{_response_hash} = $response;
	}
	elsif ( !ref $response ) {
		$self->{_response_string} = $response;
	}
	else {
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
	return $self if $pkg->isa('ISPAPI::Response');
	return $self->as_hash();
}


sub as_hash {
	my $self = shift;
	
	return $self->{_response_hash} if defined $self->{_response_hash};
	$self->{_response_hash} = ISPAPI::Util::response_to_hash($self->{_response_string});
	return $self->{_response_hash};
}



sub as_list_hash {
	my $self = shift;

	return $self->{_response_list_hash} if defined $self->{_response_list_hash};
	$self->{_response_list_hash} = ISPAPI::Util::response_to_list_hash($self->as_hash());
	return $self->{_response_list_hash};
}



sub as_list {
	my $self = shift;
	my $list_hash = $self->as_list_hash();
	if ( wantarray ) {
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
		return undef unless exists $p->{$property};
		return $p->{$property}[$index];
	}
	if ( wantarray ) {
		return () unless exists $p->{$property};
		return @{$p->{$property}};
	}
	return undef unless exists $p->{$property};
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



package ISPAPI::Util;

use strict;
use utf8;
use base 'Exporter';

use Time::Local;
use MIME::Base64;

our @EXPORT    = qw();
our @EXPORT_OK = qw(sqltime timesql);


sub timesql {
	my $sqltime = shift;
	return undef
		if !defined $sqltime || $sqltime !~ /(\d\d+)-(\d+)-(\d+)/;
	my $year = $1;
	my $mon = $2;
	my $mday = $3;
	my $rest = $';
	my $hour = "0";
	my $min = "0";
	my $sec = "0";
	my $diff = 0;
	if ( $rest =~ /(\d+):(\d+):(\d+)/ ) {
		$rest = $';
		$hour = $1;
		$min = $2;
		$sec = $3;
		if ( $rest =~ /\+(\d\d?)/ ) {
			$diff -= $1 * 3600;
		}
		if ( $rest =~ /\-(\d\d?)/ ) {
			$diff += $1 * 3600;
		}
	}
	$mon--;
	$year -= 1900;
	my $value = eval{ timegm($sec, $min, $hour, $mday, $mon, $year) };
	if (!defined $value) {
		if ( ($mon == 1) && ($mday == 29) ) {
			$value = eval{ timegm($sec, $min, $hour, 1, 2, $year) };
		}
	}
	$value += $diff;
	return $value;
}


sub sqltime {
	my $time = shift;
	$time = time()
		if !defined $time;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
	$mon++;
	$year += 1900;
	$mday = "0".int($mday) if $mday < 10;
	$mon =  "0".int($mon)  if $mon < 10;
	$hour = "0".int($hour) if $hour < 10;
	$min =  "0".int($min)  if $min < 10;
	$sec =  "0".int($sec)  if $sec < 10;
	return "$year-$mon-$mday $hour:$min:$sec";
}


sub url_encode {
	my $s = shift;
	return undef unless defined $s;
	utf8::encode($s) if utf8::is_utf8($s);
	$s =~ s/([^A-Za-z0-9\-\._~])/sprintf("%%%02X", ord($1))/seg;
	return $s;
}

sub url_decode {
	my $s = shift;
	return undef unless defined $s;
#	$s =~ s/\+/ /og;
	$s =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
	return $s;
}

sub base64_decode {
	my $s = shift;
	return undef unless defined $s;
	return decode_base64($s);
}

sub base64_encode {
	my $s = shift;
	return undef unless defined $s;
	utf8::encode($s) if utf8::is_utf8($s);
	return encode_base64($s, "");
}


sub command_encode {
	return scalar _command_encode(@_);
}

sub _command_encode {
	my $in = shift;

	if ( (ref $in) eq "HASH" ) {
		my @lines = ();
		foreach my $k ( keys %$in ) {
			my @values = _command_encode($in->{$k});
			foreach my $v ( @values ) {
				push @lines, uc($k).$v;
			}
		}
		return join "\n", @lines unless wantarray;
		return @lines;
	}
	elsif ( (ref $in) eq "ARRAY" ) {
		my $i = 0;
		my @lines = ();
		foreach my $v ( @$in ) {
			my @values = _command_encode($v);
			foreach my $v ( @values ) {
				push @lines, "$i$v";
			}
			$i++;
		}
		return join "\n", @lines unless wantarray;
		return @lines;
	}
	elsif ( !ref $in ) {
		my $out = $in;
		utf8::encode($out) if utf8::is_utf8($out);
		if ( wantarray ) {
			$out =~ s/\s/ /og;
			return ("=$out");
		}
		return $out;
	}
	else {
		die "Unsupported Class: ".(ref $in);
	}
}


sub response_to_hash {
    my $response = shift;

    my %hash = ( PROPERTY => {} );

    return \%hash if !defined $response;

    foreach ( split /\n/, $response ) {
        if ( /^([^\=]*[^\t\= ])[\t ]*=[\t ]*/ ) {
            my $attr = $1;
            my $value = $';
            $value =~ s/[\t ]*$//;
            if ( $attr =~ /^property\[([^\]]*)\]/i ) {
                my $prop = uc $1;
                $prop =~ s/\s//og;
                if ( exists $hash{"PROPERTY"}->{$prop} ) {
                    push @{$hash{"PROPERTY"}->{$prop}}, $value;
                }
                else {
                     $hash{"PROPERTY"}->{$prop} = [$value];
                }
            }
            else {
                $hash{uc $attr} = $value;
            }
        }
    }
    return \%hash;
	
}

sub response_to_list_hash {
	my $response = shift;

	my $list = {
		CODE => $response->{CODE},
		DESCRIPTION => $response->{DESCRIPTION},
		RUNTIME => $response->{RUNTIME},
		QUEUETIME => $response->{QUEUETIME},
		ITEMS => []
	};

	my $count = 0;

	if ( exists $response->{PROPERTY} ) {
		my $columns = undef;
		if ( exists $response->{PROPERTY}{COLUMN} ) {
			$columns = {map { $_ => 1 } @{$response->{PROPERTY}{COLUMN}}};
			$list->{COLUMNS} = $response->{PROPERTY}{COLUMN};
		}
		else {
			$list->{COLUMNS} = [];
		}
		foreach my $property ( keys %{$response->{PROPERTY}} ) {
			if ( $property =~ /^(COLUMN)$/i ) {
			}
			elsif ( $property =~ /^(FIRST|LAST|COUNT|LIMIT|TOTAL)$/i ) {
				$list->{$property} = $response->{PROPERTY}{$property}[0];
			}
			else {
				next if $columns && !$columns->{$property};
				push @{$list->{COLUMNS}}, $property;
				my $index = 0;
				foreach my $value ( @{$response->{PROPERTY}{$property}} ) {
					$list->{ITEMS}[$index]{$property} = $value;
					$index++;
				}
				$count = $index if $index > $count;
			}
		}
	}

	$list->{FIRST} = 0 unless defined $list->{FIRST};
	$list->{COUNT} = $count unless defined $list->{COUNT};
	$list->{TOTAL} = $list->{COUNT} unless defined $list->{TOTAL};
	$list->{LAST} = $list->{FIRST}+$list->{COUNT}-1 unless defined $list->{LAST};
	$list->{LIMIT} = $list->{COUNT} || 1 unless defined $list->{LIMIT};

	$list->{LIMIT} = $list->{COUNT} if $list->{COUNT} > $list->{LIMIT};

	if ( (exists $list->{FIRST}) && ($list->{LIMIT}) ) {
		$list->{PAGE} = int($list->{FIRST} / $list->{LIMIT}) + 1;
		if ( $list->{PAGE} > 1 ) {
			$list->{PREVPAGE} = $list->{PAGE} - 1;
			$list->{PREVPAGEFIRST} = ($list->{PREVPAGE} - 1) * $list->{LIMIT};
		}
		$list->{NEXTPAGE} = $list->{PAGE} + 1;
		$list->{NEXTPAGEFIRST} = ($list->{NEXTPAGE} - 1) * $list->{LIMIT};
	}

	if ( (exists $list->{TOTAL}) && ($list->{LIMIT}) ) {
		$list->{PAGES} = int(($list->{TOTAL} + $list->{LIMIT} - 1) / $list->{LIMIT});
		$list->{LASTPAGEFIRST} = ($list->{PAGES} - 1) * $list->{LIMIT};
		if ( (exists $list->{NEXTPAGE}) && ($list->{NEXTPAGE} > $list->{PAGES}) ) {
			delete $list->{NEXTPAGE};
			delete $list->{NEXTPAGEFIRST};
		}
	}
	
	return $list;
}


1;
