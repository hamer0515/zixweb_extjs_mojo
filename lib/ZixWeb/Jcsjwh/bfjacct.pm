package ZixWeb::Jcsjwh::bfjacct;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

#查询备付金账户信息列表数据
sub list {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/id valid/) {
		my $p = $self->param($_) || '';
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';

	$p = $self->params(
		{
			id    => $params->{id},
			valid => $params->{valid} && $self->quote( $params->{valid} ),
		}
	);

	my $sql =
"select id, b_acct, acct_name, b_name, valid ,memo , rownumber() over(order by id) as rowid from dim_bfj_acct $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

#检查账户信息是否已存在
sub check {
	my $self   = shift;
	my $b_acct = $self->param('name');
	my $result = false;
	my $sql    = "select * from dim_bfj_acct where b_acct = \'$b_acct\'";
	my $key    = $self->select($sql);
	$result = true unless $key;
	$self->render( json => { success => $result } );
}

#添加备付金账户信息
sub add {
	my $self = shift;
	my $data;
	my $b_acct    = $self->param('b_acct');
	my $b_name    = $self->param('b_name');
	my $acct_name = $self->param('acct_name');
	my $valid     = $self->param('valid');
	my $memo      = $self->param('memo');

	my $uid =
	  $self->select("select * from dim_bfj_acct where b_acct= \'$b_acct\'");
	if ($uid) {
		$self->render(
			json => { success => false, msg => '账户信息已存在' } );
		return;
	}
	$self->dbh->begin_work;
	my $sql =
"insert into dim_bfj_acct(id, b_acct, b_name, acct_name, valid, memo) values(nextval for seq_bfj_acct, \'$b_acct\',\'$b_name\',\'$acct_name\',\'$valid\',\'$memo\')";

	#差错处理
	unless ( $self->dbh->do($sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($sql),
			}
		);
		$self->dbh->rollback;
		return;
	}
	$self->log->info( $self->whois . "[add bfj_acct] with sql[$sql]" );
	$self->dbh->commit;
	$self->render( json => { success => true } );
}

sub edit {
	my $self = shift;
	my $data;
	my $id        = $self->param('id');
	my $b_name    = $self->param('b_name');
	my $acct_name = $self->param('acct_name');
	my $valid     = $self->param('valid');
	my $memo      = $self->param('memo');

	my $uid = $self->select("select * from dim_bfj_acct where id= $id ");

	unless ($uid) {
		$self->render(
			json => { success => false },
			msg  => '账户信息已存在'
		);
		return;
	}
	$self->dbh->begin_work;
	my $sql =
"update dim_bfj_acct set b_name = \'$b_name\', acct_name = \'$acct_name\', 
valid = \'$valid\', memo = \'$memo\' where id = \'$id\'";

	#差错处理
	unless ( $self->dbh->do($sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($sql),
			}
		);
		$self->dbh->rollback;
		return;
	}
	$self->log->info( $self->whois . "[update bfj_acct] with sql[$sql]" );
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
