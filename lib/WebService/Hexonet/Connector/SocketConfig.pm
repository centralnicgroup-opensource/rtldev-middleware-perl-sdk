package WebService::Hexonet::Connector::SocketConfig;

use 5.014_004;
use strict;
use warnings;
use utf8;

our $VERSION = 'v1.12.1';


sub new {
	my ( $class, $key, $data ) = @_;
	return bless {
		entity => q{},
		login => q{},
		otp => q{},
		pw => q{},
		remoteaddr => q{},
		session => q{},
		user => q{}
	}, $class;
}


sub getPOSTData {
	my $self = shift;
	my $data = {};
	if (length $self->{entity}){
		$data->{'s_entity'} = $self->{entity};
	}
	if (length $self->{login}){
		$data->{'s_login'} = $self->{login};
	}
	if (length $self->{otp}){
		$data->{'s_otp'} = $self->{otp};
	}
	if (length $self->{pw}){
		$data->{'s_pw'} = $self->{pw};
	}
	if (length $self->{remoteaddr}){
		$data->{'s_remoteaddr'} = $self->{remoteaddr};
	}
	if (length $self->{session}){
		$data->{'s_session'} = $self->{session};
	}
	if (length $self->{user}){
		$data->{'s_user'} = $self->{user};
	}
	return $data;
}


sub getSession {
	my $self = shift;
	return $self->{session};
}


sub getSystemEntity {
	my $self = shift;
	return $self->{entity};
}


sub setLogin {
	my ( $self, $value ) = @_;
	$self->{session} = q{};      # Empty string
	$self->{login}   = $value;
	return $self;
}


sub setOTP {
	my ( $self, $value ) = @_;
	$self->{session} = q{};      # Empty string
	$self->{otp}     = $value;
	return $self;
}


sub setPassword {
	my ( $self, $value ) = @_;
	$self->{session} = q{};      # Empty string
	$self->{pw}      = $value;
	return $self;
}


sub setRemoteAddress {
	my ( $self, $value ) = @_;
	$self->{remoteaddr} = $value;
	return $self;
}


sub setSession {
	my ( $self, $value ) = @_;
	$self->{session} = $value;
	$self->{login}   = q{};      # Empty string
	$self->{pw}      = q{};      # Empty string
	$self->{otp}     = q{};      # Empty string
	return $self;
}


sub setSystemEntity {
	my ( $self, $value ) = @_;
	$self->{entity} = $value;
	return $self;
}


sub setUser {
	my ( $self, $value ) = @_;
	$self->{user} = $value;
	return $self;
}

1;
