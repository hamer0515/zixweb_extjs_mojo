package ZixWeb::Component::Component;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Digest::MD5;
use JSON::XS;
use boolean;
use Encode;

use constant { DEBUG => $ENV{BASIC_DEBUG} || 0, };

BEGIN {
	require Data::Dump if DEBUG;
}

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
	my $sql =
	  "select distinct route_name as text, parent_id, route_id
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
				$_->{leaf}    = true;
				$_->{checked} = $checked->{ $_->{route_id} } ||= false;
				$p->{leaf}    = false;
				$p->{checked} = $checked->{ $p->{route_id} } ||= false;
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
	my $result = [];
	my $books  = $self->dict->{book};
	for
	  my $key ( sort { $books->{$a}->[2] cmp $books->{$b}->[2] } keys %$books )
	{
		push @$result,
		  { id => $key, name => $books->{$key}[2] . '-' . $books->{$key}[1] };
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
	my $cid   = $arr[0];
	my $c_sql = "select count(*) as count from dict_dept where id= $cid";
	my $count = $self->dbh->selectrow_hashref($c_sql);
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

1;
