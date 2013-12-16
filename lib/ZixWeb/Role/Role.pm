package ZixWeb::Role::Role;

use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use boolean;
use JSON::XS;

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
"select role_id, role_name as name, remark as memo, rownumber() over($s_str) as rowid from tbl_role_inf";
	my $data = $self->page_data( $sql, $page, $limit, $sort );
	$data->{success} = true;
	$self->render( json => $data );
}

sub add {
	my $self       = shift;
	my $role_name  = $self->param('name');
	my $memo       = $self->param('memo');
	my @limits     = $self->param('limits');
	my $dt         = DateTime->now( time_zone => 'local' );
	my $oper_date  = $dt->ymd('-');
	my $oper_staff = $self->session->{uid};
	my $rid        = $self->select(
		"select * from tbl_role_inf where role_name=\'$role_name\'");

	if ($rid) {
		$self->render(
			json => { success => false, msg => '角色名已存在' } );
		return 1;
	}
	$self->dbh->begin_work;

	my $role_sql =
"insert into tbl_role_inf(role_id, role_name, remark, oper_staff, oper_date, status)
values(nextval for seq_role_id, \'$role_name\', \'$memo\', $oper_staff, \'$oper_date\', 1 )"
	  ;

	#差错处理
	unless ( $self->dbh->do($role_sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($role_sql),
			}
		);
		$self->dbh->rollback;
		return;
	}
	my $role_id = $self->select(
		"select role_id from tbl_role_inf where role_name=\'$role_name\'");
	for my $limit (@limits) {
		my $sql =
"insert into tbl_role_route_map(role_id, route_id) values($role_id->[0]{role_id}, $limit)";

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
		  . "[add role] with sql[$role_sql] with limits["
		  . join( ',', @limits )
		  . ']' );
	$self->dbh->commit;
	$self->updateRoutes;
	$self->render( json => { success => true } );
}

sub check {
	my $self   = shift;
	my $name   = $self->param('name');
	my $id     = $self->param('id');
	my $result = false;
	my $sql =
	  "select * from tbl_role_inf where role_name=\'$name\' and role_id <> $id";
	my $key = $self->select($sql);
	$result = true unless $key;
	$self->render( json => { success => $result } );
}

sub update {
	my $self = shift;
	my $data;
	my $role_name = $self->param('name');
	my $role_id   = $self->param('role_id');
	my $memo      = $self->param('memo');
	my @limits    = $self->param('limits');

	$self->dbh->begin_work;
	my $role_sql =
"update tbl_role_inf set role_name=\'$role_name\', remark = \'$memo\' where role_id = $role_id";

	#差错处理
	unless ( $self->dbh->do($role_sql) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($role_sql),
			}
		);
		$self->dbh->rollback;
		return;
	}

	my $sql = "delete from tbl_role_route_map where role_id = $role_id";

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
	for my $limit (@limits) {
		my $sql =
"insert into tbl_role_route_map(role_id, route_id) values($role_id, $limit)";

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
	$self->log->info(
		$self->whois
		  . "[update role] with sql[$role_sql] with limits["
		  . join( ',', @limits ) . ']'
	);
	$self->dbh->commit;
	$self->updateRoutes;
	$self->render( json => { success => true } );
}

sub delete {
	my $self = shift;
	my $id   = $self->param('id');
	my $sql  = "delete from tbl_role_route_map where role_id=$id";
	my $sql_ = "delete from tbl_role_inf where role_id = $id";
	$self->dbh->begin_work;

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

	#差错处理
	unless ( $self->dbh->do($sql_) ) {
		$self->render(
			json => {
				success => false,
				msg     => $self->errhandle($sql_),
			}
		);
		$self->dbh->rollback;
		return;
	}
	$self->log->info( $self->whois . "[delete role] with sql[$sql_][$sql] " );
	$self->dbh->commit;
	$self->render( json => { success => true } );
}

1;
