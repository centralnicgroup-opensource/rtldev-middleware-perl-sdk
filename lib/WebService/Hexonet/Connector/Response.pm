package WebService::Hexonet::Connector::Response;

use 5.014_004;
use strict;
use warnings;
use WebService::Hexonet::Connector::Column;
use WebService::Hexonet::Connector::Record;
use parent qw(WebService::Hexonet::Connector::ResponseTemplate);
use POSIX qw(ceil floor);
use List::MoreUtils qw(first_index);
use Readonly;
Readonly my $INDEX_NOT_FOUND => -1;

our $VERSION = 'v1.12.1';


sub new {
	my ( $class, $raw, $cmd ) = @_;
	my $self = WebService::Hexonet::Connector::ResponseTemplate->new($raw);
	$self = bless $self, $class;
	$self->{command} = $cmd;
	$self->{columnkeys}  = [];
	$self->{columns}  = [];
	$self->{records}  = [];
	$self->{recordIndex} = 0;

	my $h = $self->getHash();
	if ( defined $h->{PROPERTY} ) {
		my @keys  = keys %{ $h->{PROPERTY} };
		my $count = 0;
		foreach my $key (@keys) {
			my @d = @{$h->{PROPERTY}->{$key}};
			$self->addColumn( $key, @d );
			my $len = scalar @d;
			if ( $len > $count ) {
				$count = $len;
			}
		}
		$count--;
		for my $i ( 0 .. $count ) {
			my %d = ();
			foreach my $colkey (@keys) {
				my $col = $self->getColumn($colkey);
				if ( defined $col ) {
					my $v = $col->getDataByIndex($i);
					if ( defined $v ) {
						$d{$colkey} = $v;
					}
				}
			}
			$self->addRecord( \%d );
		}
	}
	return $self;
}


sub addColumn {
	my ( $self, $key, @data ) = @_;
	push @{$self->{columns}}, WebService::Hexonet::Connector::Column->new( $key, @data );
	push @{$self->{columnkeys}}, $key;
	return $self;
}


sub addRecord {
	my ( $self, $h ) = @_;
	push @{$self->{records}},WebService::Hexonet::Connector::Record->new($h);
	return $self;
}


sub getColumn {
	my ( $self, $key ) = @_;
	if ( $self->_hasColumn($key) ) {
		my $idx = first_index { $_ eq $key } @{$self->{columnkeys}};
		return $self->{columns}[$idx];
	}
	return;
}


sub getColumnIndex {
	my ( $self, $key, $idx ) = @_;
	my $col = $self->getColumn($key);
	return $col->getDataByIndex($idx) if defined $col;
	return;
}


sub getColumnKeys {
	my $self = shift;
	return \@{$self->{columnkeys}};
}


sub getColumns {
	my $self = shift;
	return \@{$self->{columns}};
}


sub getCommand {
	my $self = shift;
	return $self->{command};
}


sub getCurrentPageNumber {
	my $self  = shift;
	my $first = $self->getFirstRecordIndex();
	my $limit = $self->getRecordsLimitation();
	if ( defined $first && $limit > 0 ) {
		return floor( $first / $limit ) + 1;
	}
	return;
}


sub getCurrentRecord {
	my $self = shift;
	return $self->{records}[ $self->{recordIndex} ]
	  if $self->_hasCurrentRecord();
	return;
}


sub getFirstRecordIndex {
	my $self = shift;
	my $col  = $self->getColumn('FIRST');
	if ( defined $col ) {
		my $f = $col->getDataByIndex(0);
		if ( defined $f ) {
			return int $f;
		}
	}
	my $len = scalar @{$self->{records}};
	return 0 if ( $len > 0 );
	return;
}


sub getLastRecordIndex {
	my $self = shift;
	my $col  = $self->getColumn('LAST');
	if ( defined $col ) {
		my $l = $col->getDataByIndex(0);
		if ( defined $l ) {
			return int $l;
		}
	}
	my $len = $self->getRecordsCount();
	if ( $len > 0 ) {
		return ( $len - 1 );
	}
	return;
}


sub getListHash {
	my $self = shift;
	my @lh   = ();
	foreach my $rec (@{$self->getRecords()} ) {
		push @lh, $rec->getData();
	}
	my $r = {
		LIST => \@lh,
		meta => {
			columns => $self->getColumnKeys(),
			pg      => $self->getPagination()
		}
	};
	return $r;
}


sub getNextRecord {
	my $self = shift;
	return $self->{records}[ ++$self->{recordIndex} ]
	  if ( $self->_hasNextRecord() );
	return;
}


sub getNextPageNumber {
	my $self = shift;
	my $cp   = $self->getCurrentPageNumber();
	if ( !defined $cp ) {
		return;
	}
	my $page  = $cp + 1;
	my $pages = $self->getNumberOfPages();
	return $page if ( $page <= $pages );
	return $pages;
}


sub getNumberOfPages {
	my $self  = shift;
	my $t     = $self->getRecordsTotalCount();
	my $limit = $self->getRecordsLimitation();
	if ( $t > 0 && $limit > 0 ) {
		return ceil( $t / $limit );
	}
	return 0;
}


sub getPagination {
	my $self = shift;
	my $r = {
		COUNT        => $self->getRecordsCount(),
		CURRENTPAGE  => $self->getCurrentPageNumber(),
		FIRST        => $self->getFirstRecordIndex(),
		LAST         => $self->getLastRecordIndex(),
		LIMIT        => $self->getRecordsLimitation(),
		NEXTPAGE     => $self->getNextPageNumber(),
		PAGES        => $self->getNumberOfPages(),
		PREVIOUSPAGE => $self->getPreviousPageNumber(),
		TOTAL        => $self->getRecordsTotalCount()
	};
	return $r;
}


sub getPreviousPageNumber {
	my $self = shift;
	my $cp   = $self->getCurrentPageNumber();
	if ( !defined $cp ) {
		return;
	}
	my $np = $cp - 1;
	return $np if ( $np > 0 );
	return $INDEX_NOT_FOUND;
}


sub getPreviousRecord {
	my $self = shift;
	return $self->{records}[ --$self->{recordIndex} ]
	  if ( $self->_hasPreviousRecord() );
	return;
}


sub getRecord {
	my ( $self, $idx ) = @_;
	if ( $idx >= 0 && $self->getRecordsCount() > $idx ) {
		return $self->{records}[$idx];
	}
	return;
}


sub getRecords {
	my $self = shift;
	return \@{$self->{records}};
}


sub getRecordsCount {
	my $self = shift;
	my $len  = scalar @{$self->{records}};
	return $len;
}


sub getRecordsTotalCount {
	my $self = shift;
	my $col  = $self->getColumn('TOTAL');
	if ( defined $col ) {
		my $t = $col->getDataByIndex(0);
		if ( defined $t ) {
			return int $t;
		}
	}
	return $self->getRecordsCount();
}


sub getRecordsLimitation {
	my $self = shift;
	my $col  = $self->getColumn('LIMIT');
	if ( defined $col ) {
		my $l = $col->getDataByIndex(0);
		if ( defined $l ) {
			return int $l;
		}
	}
	return $self->getRecordsCount();
}


sub hasNextPage {
	my $self = shift;
	my $cp   = $self->getCurrentPageNumber();
	if ( !defined $cp ) {
		return 0;
	}
	my $np = $cp + 1;
	if ($np <= $self->getNumberOfPages()){
		return 1;
	}
	return 0;
}


sub hasPreviousPage {
	my $self = shift;
	my $cp   = $self->getCurrentPageNumber();
	if ( !defined $cp ) {
		return 0;
	}
	my $pp = $cp - 1;
	if ( $pp > 0 ){
		return 1;
	}
	return 0;
}


sub rewindRecordList {
	my $self = shift;
	$self->{recordIndex} = 0;
	return $self;
}


sub _hasColumn {
	my ( $self, $key ) = @_;
	my $idx = first_index { $_ eq $key } @{$self->{columnkeys}};
	return ( $idx > $INDEX_NOT_FOUND );
}


sub _hasCurrentRecord {
	my $self = shift;
	my $len  = scalar @{$self->{records}};
	return ( $len > 0 && $self->{recordIndex} >= 0 && $self->{recordIndex} < $len );
}


sub _hasNextRecord {
	my $self = shift;
	my $next = $self->{recordIndex} + 1;
	my $len  = scalar @{$self->{records}};
	return ( $self->_hasCurrentRecord() && $next < $len );
}


sub _hasPreviousRecord {
	my $self = shift;
	return ( $self->{recordIndex} > 0 && $self->_hasCurrentRecord() );
}

1;
