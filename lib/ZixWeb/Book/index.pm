package ZixWeb::Book::index;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;
use boolean;

sub get_books {
	my $self   = shift;
	my $type   = shift;
	my $result = [];
	my $books  = $self->dict->{book};
	my $data   = {};
	my @books;
	if ( $type eq 'all' ) {
		@books =
		  grep { $books->{$_}[4] == 1 }
		  sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
		push @books, grep { $books->{$_}[4] == 0 }
		  sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
	}
	elsif ( $type eq 'bfj' ) {
		@books =
		  grep { $books->{$_}[4] == 1 }
		  sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
	}
	elsif ( $type eq 'zyzj' ) {
		@books =
		  grep { $books->{$_}[4] == 0 }
		  sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
	}
	elsif ( $type eq 'fhyd' ) {
		@books =
		  grep { $books->{$_}[4] == 2 }
		  sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
	}

	# 从数据库里面获得数据
	for my $book (@books) {
		my $d = $self->select(
			'select sum(j) as j, sum(d) as d from sum_' . $books->{$book}[0] )
		  ->[0];
		$d->{j} ||= 0;
		$d->{d} ||= 0;
		$data->{$book}->{j} = $d->{j};
		$data->{$book}->{d} = $d->{d};
	}
	my $total = { j => 0, d => 0, text => '汇总', leaf => true };

	# 组织树结构
	my $tree = {};
	for my $book (@books) {
		my $bn   = $books->{$book}->[0];
		my $cls  = $books->{$book}->[3];
		my $name = $books->{$book}->[1];
		my $code = $books->{$book}->[2];
		my $row  = $data->{$book};

		$total->{j}      += $row->{j};
		$total->{d}      += $row->{d};
		$tree->{$cls}{j} += $row->{j};
		$tree->{$cls}{d} += $row->{d};
		$tree->{$cls}{text} = $cls . '-' . $self->dict->{types}{class}{$cls};
		my @name = split '-',  $name;
		my @code = split '\.', $code;
		$tree->{$cls}{ $code[0] }{j} += $row->{j};
		$tree->{$cls}{ $code[0] }{d} += $row->{d};
		$tree->{$cls}{ $code[0] }{text} = $code[0] . '-' . $name[0];

		if ( $#name == 0 ) {
			$tree->{$cls}->{ $code[0] }->{url}  = $bn;
			$tree->{$cls}->{ $code[0] }->{leaf} = true;
		}
		if ( $#name > 0 ) {
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{j} += $row->{j};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{d} += $row->{d};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{text} =
			  join( '.', @code[ 0 .. 1 ] ) . '-' . $name[1];
			if ( $#name == 1 ) {
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{url}  = $bn;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{leaf} = true;
			}
		}
		if ( $#name > 1 ) {
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }
			  ->{j} +=
			  $row->{j};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{d} +=
			  $row->{d};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{text} =
			  join( '.', @code[ 0 .. 2 ] ) . '-' . $name[2];
			if ( $#name == 2 ) {
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{url} =
				  $bn;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }
				  ->{leaf} = true;
			}
		}
	}
	$tree->{total} = $total;
	$tree->{total} = $total;

	#转换为extjs要求格式
	return &_trans($tree);
}

sub all {
	my $self = shift;
	my $data = $self->get_books('all');

	$self->render( json => $data->{children} );
}

sub bfj {
	my $self = shift;
	my $data = $self->get_books('bfj');

	$data->{title} = '科目余额表-备付金帐套';

	$self->render( json => $data->{children} );
}

sub zyzj {
	my $self = shift;
	my $data = $self->get_books('zyzj');

	$data->{title} = '科目余额表-自有资金帐套';

	$self->render( json => $data->{children} );
}

sub fhyd {
	my $self = shift;
	my $data = $self->get_books('fhyd');
	$data->{title} = '科目余额表-富汇易达帐套';

	$self->render( json => $data->{children} );
}

sub _trans {
	my $href   = shift;
	my $record = {};
	for my $key ( sort keys %$href ) {
		if ( ref $href->{$key} eq 'HASH' ) {
			push @{ $record->{children} }, &_trans( $href->{$key} );
		}
		else {
			$record->{$key} = $href->{$key};
		}
	}
	return $record;
}

1;
