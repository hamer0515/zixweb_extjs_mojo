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

		my ( $bn, $name, $code, $cls, $set, $entity ) = @{ $books->{$book} };

		my $row = $data->{$book};
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
			$tree->{$cls}->{ $code[0] }->{url}    = $bn;
			$tree->{$cls}->{ $code[0] }->{bid}    = $book;
			$tree->{$cls}->{ $code[0] }->{leaf}   = true;
			$tree->{$cls}->{ $code[0] }->{entity} = $entity;
		}
		if ( $#name > 0 ) {
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{j} += $row->{j};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{d} += $row->{d};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{text} =
			  join( '.', @code[ 0 .. 1 ] ) . '-' . $name[1];
			if ( $#name == 1 ) {
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{url}    = $bn;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{bid}    = $book;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{leaf}   = true;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{entity} = $entity;
			}
		}
		if ( $#name > 1 ) {
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{j} +=
			  $row->{j};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{d} +=
			  $row->{d};
			$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{text} =
			  join( '.', @code[ 0 .. 2 ] ) . '-' . $name[2];
			if ( $#name == 2 ) {
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{url} =
				  $bn;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }->{bid} =
				  $book;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }
				  ->{leaf} = true;
				$tree->{$cls}->{ $code[0] }->{ $code[1] }->{ $code[2] }
				  ->{entity} = $entity;
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

# 汇总查询
sub sum {
	my $self  = shift;
	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my @p = split '/', $self->req->url->path;
	my $book = pop @p;

	my $dims =
	  $self->configure->{headers}{ $self->dict->{value2id}{book}{$book} };
	my $ps = {
		period => [
			$self->quote( $self->param('period_from') || '' ),
			$self->quote( $self->param('period_to')   || '' )
		],
	};

	for my $dim ( @{$dims} ) {

		# 日期类型核算项
		if ( $self->dict->{dimtype}{$dim} == 3 ) {
			my ( $from, $to ) =
			  ( $self->param( $dim . "from" ), $self->param( $dim . "to" ) );
			$ps->{$dim} =
			  [ 0, $from && $self->quote($from), $to && $self->quote($to) ];
		}

		# 字符类型核算项
		elsif ( $self->dict->{dimtype}{$dim} == 2 ) {
			my $v = $self->param($dim);
			$ps->{$dim} = $v && $self->quote($v);
		}

		# 整型核算项
		else {
			$ps->{$dim} = $self->param($dim);
		}
	}
	my @hsx;
	for ( my $i = 0 ; $i <= length @$dims ; $i++ ) {
		my $h = $self->param( $self->configure->{hsx}[$i] );
		if ($h) {
			push @hsx, $h;
		}
	}
	if ( $#hsx == -1 ) {
		push @hsx, @{$dims};
		push @hsx, 'period';
	}
	my $fields    = join ', ', grep { $_ } @hsx;
	my $p         = $self->params($ps);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_$book $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

# 汇总查询excel下载
sub sum_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	my @p = split '/', $self->req->url->path;
	my $book = pop @p;

	# 去掉末尾的_excel
	$book =~ s/.{6}$//;

	my $dims =
	  $self->configure->{headers}{ $self->dict->{value2id}{book}{$book} };
	my $ps = {
		period => [
			$self->quote( $self->param('period_from') || '' ),
			$self->quote( $self->param('period_to')   || '' )
		],
	};

	for my $dim ( @{$dims} ) {

		# 日期类型核算项
		if ( $self->dict->{dimtype}{$dim} == 3 ) {
			my ( $from, $to ) =
			  ( $self->param( $dim . "from" ), $self->param( $dim . "to" ) );
			$ps->{$dim} =
			  [ 0, $from && $self->quote($from), $to && $self->quote($to) ];
		}

		# 字符类型核算项
		elsif ( $self->dict->{dimtype}{$dim} == 2 ) {
			my $v = $self->param($dim);
			$ps->{$dim} = $v && $self->quote($v);
		}

		# 整型核算项
		else {
			$ps->{$dim} = $self->param($dim);
		}
	}
	my @hsx;
	for ( my $i = 0 ; $i <= length @$dims ; $i++ ) {
		my $h = $self->param( $self->configure->{hsx}[$i] );
		if ($h) {
			push @hsx, $h;
		}
	}
	if ( $#hsx == -1 ) {
		push @hsx, @{$dims};
		push @hsx, 'period';
	}
	my $fields    = join ', ', grep { $_ } @hsx;
	my $p         = $self->params($ps);
	my $condition = $p->{condition};
	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_$book $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );

}

# 详细查询
sub detail {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my @p = split '/', $self->req->url->path;
	my $book = pop @p;

	my $dims =
	  $self->configure->{headers}{ $self->dict->{value2id}{book}{$book} };
	my $params = {};
	for (qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to/) {
		my $p = $self->param($_) || '';
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $ps = {
		period => [
			$self->quote( $params->{period_from} ),
			$self->quote( $params->{period_to} ),
		],
		id      => $params->{id},
		ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
		ys_id   => $params->{ys_id},
		j       => [ 0, $params->{j_from}, $params->{j_to} ],
		d       => [ 0, $params->{d_from}, $params->{d_to} ],
	};

	for my $dim ( @{$dims} ) {

		# 日期类型核算项
		if ( $self->dict->{dimtype}{$dim} == 3 ) {
			my ( $from, $to ) =
			  ( $self->param( $dim . "from" ), $self->param( $dim . "to" ) );
			$ps->{$dim} =
			  [ 0, $from && $self->quote($from), $to && $self->quote($to) ];
		}

		# 字符类型核算项
		elsif ( $self->dict->{dimtype}{$dim} == 2 ) {
			my $v = $self->param($dim);
			$ps->{$dim} = $v && $self->quote($v);
		}

		# 整型核算项
		else {
			$ps->{$dim} = $self->param($dim);
		}
	}

	my $fields    = join ', ', grep { $_ } @$dims;
	my $p         = $self->params($ps);
	my $condition = $p->{condition};

	my $sql =
"select $fields, id, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_$book $condition";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

# 详细查询excel下载
sub detail_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	$header = { reverse %$header };

	my @p = split '/', $self->req->url->path;
	my $book = pop @p;

	# 去掉末尾的_excel
	$book =~ s/.{6}$//;

	my $dims =
	  $self->configure->{headers}{ $self->dict->{value2id}{book}{$book} };
	my $params = {};
	for (qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to/) {
		my $p = $self->param($_) || '';
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $ps = {
		period => [
			$self->quote( $params->{period_from} ),
			$self->quote( $params->{period_to} ),
		],
		id      => $params->{id},
		ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
		ys_id   => $params->{ys_id},
		j       => [ 0, $params->{j_from}, $params->{j_to} ],
		d       => [ 0, $params->{d_from}, $params->{d_to} ],
	};

	for my $dim ( @{$dims} ) {

		# 日期类型核算项
		if ( $self->dict->{dimtype}{$dim} == 3 ) {
			my ( $from, $to ) =
			  ( $self->param( $dim . "from" ), $self->param( $dim . "to" ) );
			$ps->{$dim} =
			  [ 0, $from && $self->quote($from), $to && $self->quote($to) ];
		}

		# 字符类型核算项
		elsif ( $self->dict->{dimtype}{$dim} == 2 ) {
			my $v = $self->param($dim);
			$ps->{$dim} = $v && $self->quote($v);
		}

		# 整型核算项
		else {
			$ps->{$dim} = $self->param($dim);
		}
	}

	my $fields    = join ', ', keys %$header;
	my $p         = $self->params($ps);
	my $condition = $p->{condition};

	my $sql  = "select $fields from book_$book $condition order by id desc";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
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
