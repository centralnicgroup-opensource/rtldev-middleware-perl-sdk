package WebService::Hexonet::Connector::ResponseTemplateManager;

use 5.014_004;
use strict;
use warnings;
use WebService::Hexonet::Connector::ResponseTemplate;
use WebService::Hexonet::Connector::ResponseParser;

our $VERSION = 'v1.12.1';

my $instance = undef;


sub getInstance {
	if ( !defined $instance ) {
		my $self = {templates => {}};
		$instance = bless $self, shift;
		$instance->addTemplate('404', $instance->generateTemplate( '421', 'Page not found' ));
		$instance->addTemplate('500', $instance->generateTemplate( '500', 'Internal server error' ));
		$instance->addTemplate('empty', $instance->generateTemplate( '423', 'Empty API response' ));
		$instance->addTemplate('error', $instance->generateTemplate( '421', 'Command failed due to server error. Client should try again' ));
		$instance->addTemplate('expired', $instance->generateTemplate( '530', 'SESSION NOT FOUND' ));
		$instance->addTemplate('httperror', $instance->generateTemplate( '421', 'Command failed due to HTTP communication error' ));
		$instance->addTemplate('unauthorized', $instance->generateTemplate( '530', 'Unauthorized' ));
	}
	return $instance;
}


sub generateTemplate {
	my ( $self, $code, $description ) = @_;
	return "[RESPONSE]\r\nCODE=${code}\r\nDESCRIPTION=${description}\r\nEOF\r\n";
}


sub addTemplate {
	my ( $self, $id, $plain ) = @_;
	$self->{templates}->{$id} = $plain;
	return $instance;
}


sub getTemplate {
	my ( $self, $id ) = @_;
	my $plain;
	if ( $self->hasTemplate($id) ) {
		$plain = $self->{templates}->{$id};
	} else {
		$plain = $self->generateTemplate( '500', 'Response Template not found' );
	}
	return WebService::Hexonet::Connector::ResponseTemplate->new($plain);
}


sub getTemplates {
	my $self = shift;
	my $tmp = {};
	my $tpls = $self->{templates};
	foreach my $key ( keys %{$tpls} ) {
		$tmp->{$key} = WebService::Hexonet::Connector::ResponseTemplate->new( $tpls->{$key} );
	}
	return $tmp;
}


sub hasTemplate {
	my ( $self, $id ) = @_;
	return defined $self->{templates}->{$id};
}


sub isTemplateMatchHash {
	my ( $self, $tpl2, $id ) = @_;
	my $tpl = $self->getTemplate($id);
	my $h = $tpl->getHash();
	return ( $h->{CODE} eq $tpl2->{CODE} ) && ( $h->{DESCRIPTION} eq $tpl2->{DESCRIPTION} );
}


sub isTemplateMatchPlain {
	my ( $self, $plain, $id ) = @_;
	my $h = WebService::Hexonet::Connector::ResponseParser::parse($plain);
	return $self->isTemplateMatchHash( $h, $id );
}

1;
