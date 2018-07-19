package HEXONET::apiconnector::Connection;

use strict;
use warnings;
use HEXONET;
use HEXONET::apiconnector::Response;
use HEXONET::apiconnector::Util;
use LWP::UserAgent;

our $VERSION = '1.10';

sub new {
	my $class = shift;
	my $self = {@_};
	foreach my $key (%$self) {
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
	return HEXONET::apiconnector::Response->new($self->call_raw($command, $config));
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
	my $post = {s_command => (scalar HEXONET::apiconnector::Util::command_encode($command))};
	$post->{s_entity} = $self->{entity} if exists $self->{entity};
	$post->{s_login} = $self->{login} if exists $self->{login};
	$post->{s_pw} = $self->{password} if exists $self->{password};
	$post->{s_user} = $self->{user} if exists $self->{user};
	$post->{s_login} = $self->{login} . "!" . $self->{role} if exists $self->{role};

	if ( exists $config->{user} ) {
		if ( exists $post->{s_user} ) {
			$post->{s_user} .= " ".$config->{user};
		}else {
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
		agent => "HEXONET-perl/$HEXONET::apiconnector::VERSION",
		keep_alive => 4
	);
	return $self->{_useragent};
}

1;