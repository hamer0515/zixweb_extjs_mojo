package ZixWeb::User::User;

use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use JSON::XS;
use boolean;

sub list {
	my $self  = shift;
	my $page  = $self->param('page');
	my $limit = $self->param('limit');
	my $sort  = $self->param('sort');
	my $s_str = '';
	if ($sort) {
		$s_str = 'order by ';
		$sort  = decode_json $sort;
		for my $s (@$sort) {
			$s_str .= $s->{property} . ' ' . $s->{direction};
		}
	}
	my $sql =
"select user_id, username, status, pwd_chg_date, rownumber() over($s_str) as rowid from tbl_user_inf";
	my $data = $self->page_data( $sql, $page, $limit, $sort );
	$data->{success} = true;
	$self->render( json => $data );
}

sub add {
	my $self = shift;
	my $data;
	my $username = $self->param('username');
	my $password = $self->param('password');
	$password = Digest::MD5->new->add($password)->hexdigest;
	my @roles = split ',', $self->param('roles');
	my $dt = DateTime->now( time_zone => 'local' );
	my $oper_date = $dt->ymd('-');
	my $uid =
	  $self->select("select * from tbl_user_inf where username=\'$username\'");

	if ($uid) {
		$self->render(
			json => { success => false, msg => '用户名已存在' } );
		return;
	}
	$self->dbh->begin_work;
	my $user_sql =
"insert into tbl_user_inf(user_id, username, user_pwd, pwd_chg_date, status) values (nextval for seq_user_id, \'$username\', \'$password\', \'$oper_date\', 1)";

	#差错处理
	unless ( $self->dbh->do($user_sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($user_sql),
			}
		);
		$self->dbh->rollback;
		return;
	}
	my $user_id = $self->select(
		"select user_id from tbl_user_inf where username=\'$username\'");
	for my $role (@roles) {
		my $sql =
"insert into tbl_user_role_map(user_id, role_id) values($user_id->[0]{user_id}, $role)";

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
	}
	$self->log->info( $self->whois
		  . "[add user] with sql[$user_sql] with roles["
		  . join( ',', @roles )
		  . ']' );
	$self->dbh->commit;
	$self->updateUsers;
	$self->render( json => { success => true } );
}

sub check {
	my $self   = shift;
	my $name   = $self->param('name');
	my $id     = $self->param('id');
	my $result = false;
	my $sql =
	  "select * from tbl_user_inf where username=\'$name\' and user_id <> $id";
	my $key = $self->select($sql);
	$result = true unless $key;
	$self->render( json => { success => $result } );
}

sub update {
	my $self = shift;
	my $data;
	my $username = $self->param('username');
	my $status   = $self->param('status');
	my $user_id  = $self->param('user_id');
	my $password = $self->param('password') || '';
	my @roles    = split ',', $self->param('roles');
	$self->dbh->begin_work;
	my $user_sql;

	if ( $password eq '' ) {
		$user_sql =
"update tbl_user_inf set username = \'$username\' , status = \'$status\' where user_id = $user_id";
	}
	else {
		$password = Digest::MD5->new->add($password)->hexdigest;
		$user_sql =
"update tbl_user_inf set username = \'$username\', user_pwd = \'$password\', status = \'$status\' where user_id = $user_id";
	}

	#差错处理
	unless ( $self->dbh->do($user_sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($user_sql),
			}
		);
		$self->dbh->rollback;
		return;
	}

	my $sql = "delete from tbl_user_role_map where user_id = $user_id";

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

	for my $role (@roles) {
		my $sql =
"insert into tbl_user_role_map(user_id, role_id) values($user_id, $role)";

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
	}
	$self->log->info( $self->whois
		  . "[update user] with sql[$user_sql] with roles["
		  . join( ',', @roles )
		  . ']' );
	$self->dbh->commit;
	$self->updateUsers;
	$self->render( json => { success => true } );
}

1;
