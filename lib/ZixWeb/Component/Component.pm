package ZixWeb::Component::Component;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;
use Env qw/ZIXWEB_HOME/;

sub roles {
	my $self = shift;
	my $id   = $self->param('id');
	my $data = $self->select(
		"select role_id from tbl_user_role_map where user_id = $id");
	my $result = [];
	for my $d (@$data) {
		push @$result, $d->{role_id};
	}
	$self->render( json => $result );
}

sub allroles {
	my $self = shift;
	my $data = $self->select(
		"select role_id, role_name as name from tbl_role_inf where status = 1");
	$self->render( json => $data );
}

sub routes {
	my $self = shift;
	my $id   = $self->param('id');
	my $sql  = "select distinct route_name as text, parent_id, route_id
	    from tbl_route_inf where status>=1";
	my $rdata   = $self->select($sql);
	my $checked = {};
	if ($id) {
		my $cdata = $self->select(
			"select route_id from tbl_role_route_map where role_id = $id");
		for my $r (@$cdata) {
			$checked->{ $r->{route_id} } = true;
		}
	}
	for (@$rdata) {
		my $pid = $_->{parent_id};
		if ( $pid != 0 ) {
			my $p = [ grep { $_->{route_id} == $pid } @$rdata ]->[0];
			unless ( exists $p->{children} ) {
				$_->{leaf}     = true;
				$_->{checked}  = $checked->{ $_->{route_id} } ||= false;
				$p->{leaf}     = false;
				$p->{checked}  = $checked->{ $p->{route_id} } ||= false;
				$p->{children} = [];
				push @{ $p->{children} }, $_;
			}
			else {
				$_->{leaf} = true;
				$_->{checked} = $checked->{ $_->{route_id} } ||= false;
				push @{ $p->{children} }, $_;
			}
		}
	}
	my $parents =
	  [ grep { exists $_->{parent_id} && $_->{parent_id} == 0 } @$rdata ];

	$self->render( json => $parents );
}

sub books {
	my $self   = shift;
	my $set    = $self->param('set');
	my $result = [];
	my $books  = $self->dict->{book};
	for my $key (
		sort { $books->{$a}->[2] cmp $books->{$b}->[2] }
		grep { $set =~ /$books->{$_}[4]/ } keys %$books
	  )
	{
		push @$result,
		  {
			id   => $key,
			name => $books->{$key}[2] . '-' . $books->{$key}[1],
			set  => $books->{$key}[4]
		  };
	}

	$self->render( json => $result );
}

sub account {
	my $self   = shift;
	my $result = [];
	my $acct   = $self->acct;
	for my $key ( sort { $acct->{$a} cmp $acct->{$b} } keys %$acct ) {
		push @$result, { id => $key, name => $acct->{$key} };
	}
	$self->render( json => $result );
}

sub bfjacct {
	my $self     = shift;
	my $result   = [];
	my $bfj_acct = $self->bfj_acct;
	for my $key ( sort { $bfj_acct->{$a} cmp $bfj_acct->{$b} } keys %$bfj_acct )
	{
		push @$result, { id => $key, name => $bfj_acct->{$key} };
	}

	$self->render( json => $result );
}

sub zyzjacct {
	my $self      = shift;
	my $result    = [];
	my $zyzj_acct = $self->zyzj_acct;
	for my $key (
		sort { $zyzj_acct->{$a} cmp $zyzj_acct->{$b} }
		keys %$zyzj_acct
	  )
	{
		push @$result, { id => $key, name => $zyzj_acct->{$key} };
	}

	$self->render( json => $result );
}

sub zjbdtype {
	my $self      = shift;
	my $result    = [];
	my $zjbd_type = $self->zjbd_type;
	for my $key (
		sort { $zjbd_type->{$a} cmp $zjbd_type->{$b} }
		keys %$zjbd_type
	  )
	{
		push @$result, { id => $key, name => $zjbd_type->{$key} };
	}

	$self->render( json => $result );
}

sub wlzjtype {
	my $self      = shift;
	my $result    = [];
	my $wlzj_type = $self->dict->{types}{wlzj_type};
	for my $key (
		sort { $wlzj_type->{$a} cmp $wlzj_type->{$b} }
		keys %$wlzj_type
	  )
	{
		push @$result, { id => $key, name => $wlzj_type->{$key} };
	}

	$self->render( json => $result );
}

sub fywtype {
	my $self     = shift;
	my $result   = [];
	my $fyw_type = $self->dict->{types}{fyw_type};
	for my $key (
		sort { $fyw_type->{$a} cmp $fyw_type->{$b} }
		keys %$fyw_type
	  )
	{
		push @$result, { id => $key, name => $fyw_type->{$key} };
	}

	$self->render( json => $result );
}

sub fhwtype {
	my $self     = shift;
	my $result   = [];
	my $fhw_type = $self->fhw_type;
	for my $key ( sort { $fhw_type->{$a} cmp $fhw_type->{$b} } keys %$fhw_type )
	{
		push @$result, { id => $key, name => $fhw_type->{$key} };
	}

	$self->render( json => $result );
}

sub fypacct {
	my $self     = shift;
	my $result   = [];
	my $fyp_acct = $self->fyp_acct;
	for my $key ( sort { $fyp_acct->{$a} cmp $fyp_acct->{$b} } keys %$fyp_acct )
	{
		push @$result, { id => $key, name => $fyp_acct->{$key} };
	}

	$self->render( json => $result );
}

sub fhydacct {
	my $self      = shift;
	my $result    = [];
	my $fhyd_acct = $self->fhyd_acct;
	for my $key (
		sort { $fhyd_acct->{$a} cmp $fhyd_acct->{$b} }
		keys %$fhyd_acct
	  )
	{
		push @$result, { id => $key, name => $fhyd_acct->{$key} };
	}

	$self->render( json => $result );
}

sub product {
	my $self   = shift;
	my $result = [];
	my $p      = $self->p;
	for my $key ( sort { $p->{$a} cmp $p->{$b} } keys %$p ) {
		push @$result, { id => $key, name => $p->{$key} };
	}
	$self->render( json => $result );
}

sub bi_dict {
	my $self   = shift;
	my $result = [];
	my $bi     = $self->bi;
	for my $key ( sort { $bi->{$a} cmp $bi->{$b} } keys %$bi ) {
		push @$result, { id => $key, name => $bi->{$key} };
	}
	$self->render( json => $result );
}

sub ystype {
	my $self    = shift;
	my $entity  = $self->param('entity') || 0;
	my $fir     = { 0 => '.', 1 => 0, 2 => 'F' };
	my $result  = [];
	my $ys_type = $self->ys_type;
	for my $key ( sort keys %$ys_type ) {
		push @$result, { id => $key, name => $key . $ys_type->{$key} }
		  if $key =~ /^$fir->{$entity}/;
	}
	$self->render( json => $result );
}

sub ystype_fhyd {
	my $self    = shift;
	my $result  = [];
	my $ys_type = $self->ys_type;
	for my $key ( sort keys %$ys_type ) {
		push @$result, { id => $key, name => $key . $ys_type->{$key} };
	}
	$self->render( json => $result );
}

sub c {
	my $self   = shift;
	my $result = false;
	my $c      = $self->param('name');
	my @arr    = split( '\.', $c );
	my $cid    = $arr[0];
	my $c_sql  = "select count(*) as count from dict_dept where id= $cid";
	my $count  = $self->dbh->selectrow_hashref($c_sql);
	$result = true if $count && $count->{count} == 1;
	return $self->render( json => { success => $result } );
}

sub cust_proto {
	my $self       = shift;
	my $result     = false;
	my $cust_proto = $self->param('name');
	my @arr        = split( '\_', $cust_proto );
	my $pid        = $arr[0];
	my $p_sql      = "select count(*) from dim_p where id= $pid";
	my $count      = $self->dbh->selectrow_hashref($p_sql);
	$result = true if $count && $count->{count} == 1;
	return $self->render( json => { success => $result } );
}

sub excel {
	my $self = shift;
	my $file = $self->param('file');
	my $path = "${ZIXWEB_HOME}${file}";
	if ( $file !~ /^\/var/ ) {
		$self->render_file(
			'filepath' => "${ZIXWEB_HOME}/var/没有访问权限.txt" );
	}
	if ( -e $path ) {
		$self->render_file( 'filepath' => "${ZIXWEB_HOME}${file}" );
	}
	else {
		$self->render_file(
			'filename' => '${ZIXWEB_HOME}/var/文件不存在.txt' );
	}
}

sub book_headers {
	my $self    = shift;
	my $headers = $self->configure->{headers};
	my $data    = {};
	for my $id ( keys %$headers ) {
		my $source = { amt => '' };
		for my $item ( @{ $headers->{$id} } ) {
			$source->{$item} = '';
		}
		my $book_name = $self->dict->{book}{$id}[1];
		$data->{$id} = JSON::XS->new->latin1->encode(
			{
				source    => $source,
				book_name => $book_name
			}
		);
	}
	return $self->render( json => { success => $data } );
}

sub book_dim {
	my $self = shift;
	my $data = $self->dict->{dim};
	$data->{amt} = '金额';
	return $self->render( json => { success => $data } );
}

1;
