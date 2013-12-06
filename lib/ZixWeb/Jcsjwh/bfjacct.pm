package ZixWeb::Jcsjwh::bfjacct;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

#查询备付金账户信息列表数据
sub list {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/bfj_acct status/) {
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';

	$p = $self->params(
		{
			id => $params->{bfj_acct} && $self->quote( $params->{bfj_acct} ),
			valid => $params->{status},
		}
	);

	my $sql =
"select id as bfj_id, b_acct as bfj_acct, acct_name, b_name,valid as status ,memo , rownumber() over(order by id asc) as rowid from dim_bfj_acct $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

#检查账户信息是否已存在
sub check {
	my $self     = shift;
	my $bfj_acct = $self->param('name');
	my $result   = false;
	my $sql =
"select count(*) as count from dim_bfj_acct where b_acct = \'$bfj_acct'\ ";
	my $key = $self->dbh->selectrow_hashref($sql);
	$result = true if $key->{count} == 0;
	$self->render( json => { success => $result } );
}

#添加备付金账户信息
sub add {
	my $self = shift;
	my $data;
	my $bfj_acct  = $self->param('bfj_acct');
	my $b_name    = $self->param('b_name');
	my $acct_name = $self->param('acct_name');
	my $status    = $self->param('status');
	my $memo      = $self->param('memo');

	my $uid = $self->dbh->selectall_arrayref(
		"select count(*) from dim_bfj_acct where b_acct= \'$bfj_acct'\ ");
	if ( $uid->[0]->[0] ) {
		$self->render( json => { success => false } );
		return;
	}
	$self->dbh->begin_work;
	my $sql =
"insert into dim_bfj_acct(b_acct, b_name, acct_name,valid, memo) values(\'$bfj_acct\',\'$b_name\',\'$acct_name\',\'$status\',\'$memo\')";

	$self->dbh->do($sql)
	  or $self->errhandle($sql)
	  and $self->dbh->rollback;
	$self->dbh->commit;
	$self->render( json => { success => true } );
}

sub edit {
	my $self = shift;
	my $data;
	my $bfj_id    = $self->param('bfj_id');
	my $b_name    = $self->param('b_name');
	my $acct_name = $self->param('acct_name');
	my $status    = $self->param('status');
	my $memo      = $self->param('memo');

	my $uid = $self->dbh->selectall_arrayref(
		"select count(*) from dim_bfj_acct where id= $bfj_id ");

	unless ( $uid->[0]->[0] ) {
		$self->render( json => { success => false } );
		return;
	}
	$self->dbh->begin_work;
	my $sql =
"update dim_bfj_acct set b_name = \'$b_name\',acct_name = \'$acct_name\',valid = \'$status\',memo = \'$memo\' where id = \'$bfj_id\'";

	$self->dbh->do($sql)
	  or $self->errhandle($sql)
	  and $self->dbh->rollback;
	$self->dbh->commit;

	$self->render( json => { success => true } );
}

sub query {
	my $self   = shift;
	my $bfj_id = $self->param('bfj_id');

	my $data =
	  $self->select("select memo from dim_bfj_acct where id = \'$bfj_id\' ");

	$self->render( json => { success => true, data => $data } );

}

1;
