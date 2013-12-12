package ZixWeb::Utils;

use Mojo::Base 'Exporter';
use boolean;
use DateTime;
use Spreadsheet::WriteExcel;

our @EXPORT =
  qw(_post_url _gen_file _updateAcct _transform _updateBfjacct
  _updateFypacct _updateFhydacct _updateFhwtype  _updateZyzjacct
  _updateYstype _updateBi _updateP _updateUsers _updateRoutes
  _uf _nf _initDict _decode_ch _page_data _select _update _errhandle
  _params);

sub _uf {
	my $number = shift;
	my $flag   = 0;
	$number = 0.00 unless ( defined $number );
	$number =~ s/,//g;
	return $number;
}

sub _nf {
	my $num = shift || 0;
	my $minus = 1;
	if ( $num < 0 ) {
		$num   = abs($num);
		$minus = -1;
	}
	$num = sprintf "%.2f", $num;
	my ( $p1, $p2 ) = split '\.', $num;
	my $len = length $p1;

	my $grp = int( $len / 3 );
	my $res = $len % 3;

	my $format;
	if ( $res == 0 ) {
		$format = "A3" x $grp;
	}
	else {
		$format = "A$res" . ( "A3" x $grp );
	}

	$p1 = join ',', unpack $format, $p1;
	if ( $minus > 0 ) {
		return "$p1.$p2";
	}
	else {
		return "-$p1.$p2";
	}
}

sub _initDict {
	my $self = shift;
	my $dict = $self->dict;
	my $data = $self->select(
		"select id, code, value, name, class, set from dict_book order by code"
	);
	for my $row (@$data) {
		$dict->{book}{ $row->{id} } = [
			$row->{value}, $row->{name}, $row->{code},
			$row->{class}, $row->{set}
		];
		$dict->{types}{book}{ $row->{value} } = $row->{name};
		$dict->{bookcode}{ $row->{id} } = $row->{code} . "-" . $row->{name};
	}
	$data = $self->select("select dim, name from dict_dim");
	for my $row (@$data) {
		$dict->{dim}{ $row->{dim} } = $row->{name};
	}
	$data = $self->select(
		"select class, key, val from dict where class like 'yspz%'");
	for my $row (@$data) {
		$dict->{types}{ $row->{class} }{ $row->{key} } = $row->{val};
	}
	$dict->{types}{status} = {
		0 => '未处理',
		1 => '处理成功',
		2 => '处理失败',
	};
	$dict->{types}{tx_type} = {
		1 => '收款',
		2 => '反向交易'
	};
	$dict->{types}{pack_status} = {
		1  => '可生成',
		2  => '生成中',
		3  => '生成成功',
		-1 => '无',
		-2 => '生成失败',
	};
	$dict->{types}{mission_status} = {
		1  => '可开始',
		2  => '下载中',
		3  => '可分配',
		4  => '分配中',
		5  => '可运行',
		6  => '运行中',
		7  => '运行成功',
		-1 => '下载失败',
		-2 => '分配失败',
		-3 => '运行失败',
	};
	$dict->{types}{job_status} = {
		1  => '可运行',
		2  => '运行中',
		3  => '运行成功',
		-1 => '运行失败',
	};
	$dict->{types}{flag} = {
		0 => '未撤销',
		1 => '已撤销',
		2 => '撤销申请中',
	};
	$dict->{types}{dim_bi_type} = {
		1 => '出款',
		2 => '入款'
	};
	$dict->{types}{im_bjhf_period} = {
		1 => '天',
		2 => '周',
		3 => '月',
		4 => '季',
		5 => '半年',
		6 => '年',
		7 => '实时',
	};
	$dict->{types}{im_round} = {
		1 => '四舍五入',
		2 => '向上取整',
		3 => '向下取整',
	};
	$dict->{types}{user_role_status} = {
		0 => '禁用',
		1 => '启动',
	};
	$data = $self->select("select id, name from dim_wlzj_type");

	for my $row (@$data) {
		$dict->{types}{wlzj_type}{ $row->{id} }      = $row->{name};
		$dict->{types}{wlzjtypes_id}{ $row->{name} } = $row->{id};
	}

	#业务类型
	$data = $self->select("select id, name from dim_fyw_type");
	for my $row (@$data) {
		$dict->{types}{fyw_type}{ $row->{id} } = $row->{name};
		$dict->{types}{fyw_id}{ $row->{name} } = $row->{id};

	}
	$data = $self->select("select key, val from dict where class='class'");
	for my $row (@$data) {
		$dict->{types}{class}{ $row->{key} } = $row->{val};
	}
	for (
		qw/bfee bfee_1 bfee_2 bfee_3 bfee_1_back bfee_2_back bfee_3_back bfj_bfee
		bfj_blc bfj_bsc cwwf_bfee cwwf_bfee_1 cwwf_bfee_2 cwwf_bfee_3 cwwf_bfee_1_back
		cwwf_bfee_2_back cwwf_bfee_3_back cwws_cfee cwws_cfee_back cfee cfee_back
		cc_bfee cc_bfee_1 cc_bfee_2 cc_bfee_3 cc_bfee_1_back cc_bfee_2_back cc_bfee_3_back
		cc_cwwf_bfee tx_amt tx_date e_date e_date_bfj e_date_zyzj zg_bfee zg_bfee_1
		zg_bfee_1_back zg_bfee_2 zg_bfee_2_back zg_bfee_3 zg_bfee_3_back zjbd_date_in
		zjbd_date_in_1  zjbd_date_in_2 zjbd_date_in_3  zjbd_date_in_bj zjbd_date_in_bfj
		zjbd_date_in_zyzj zjbd_date_out zjbd_date_out_1 zjbd_date_out_2 zjbd_date_out_3
		zjbd_date_out_bj zjbd_date_out_bfj zjbd_date_out_zyzj zjhb_amt zhlx_amt zhgl_fee
		zyzj_bfee zyzj_blc zyzj_bsc wk_cfee yhys_txamt yhys_bamt yhys_bfee yhys_bamt yhyf_bamt
		yhyf_bfee yhyf_bamt lfee ls_amt psp_lfee psp_amt rp_bfee in_cost fe_date/
	  )
	{
		$dict->{types}{range_fields}->{$_} = 1;
	}
	$self->updateUsers;
	$self->updateRoutes;
	$self->updateP;
	$self->updateBi;
	$self->updateYstype;
	$self->updateAcct;
	$self->updateBfjacct;
	$self->updateZyzjacct;
	$self->updateFypacct;
	$self->updateFhydacct;
	$self->updateFhwtype;
}

# 更新角色路由信息
sub _updateRoutes {
	my $self   = shift;
	my $routes = {};
	my $data   = $self->select(
		"select route.route_regex as route_regex, role_route.role_id as id
    	    from tbl_route_inf route 
    	    join tbl_role_route_map role_route 
    	    on role_route.route_id=route.route_id
            order by id"
	);
	for my $row (@$data) {
		$routes->{ $row->{id} } = [] unless exists $routes->{ $row->{id} };
		push @{ $routes->{ $row->{id} } }, $row->{route_regex}
		  if $row->{route_regex} ne '';
	}
	$self->memd->set( 'routes', $routes );
}

# 更新用户角色信息
sub _updateUsers {
	my $self      = shift;
	my $users     = {};
	my $usernames = {};
	my $uids      = {};
	my $data      = $self->select(
"select user.username as username, user.user_id as user_id, user_role.role_id as role_id
    	    from tbl_user_inf user 
    	    join tbl_user_role_map user_role 
    	    on user.user_id=user_role.user_id
            order by user_id"
	);
	for my $row (@$data) {
		$users->{ $row->{user_id} } = []
		  unless exists $users->{ $row->{user_id} };
		$usernames->{ $row->{user_id} } = $row->{username};
		$uids->{ $row->{username} }     = $row->{user_id};
		push @{ $users->{ $row->{user_id} } }, $row->{role_id};
	}
	$self->memd->set( 'users',     $users );
	$self->memd->set( 'usernames', $usernames );
	$self->memd->set( 'uids',      $uids );
}

# 更新产品信息
sub _updateP {
	my $self = shift;
	my $p    = {};
	my $p_id = {};
	my $data = $self->select("select id, name from dim_p");
	for my $row (@$data) {
		$p->{ $row->{id} }      = $row->{name};
		$p_id->{ $row->{name} } = $row->{id};
	}
	$self->memd->set( 'p',    $p );
	$self->memd->set( 'p_id', $p_id );
}

# 更新银行接口
sub _updateBi {
	my $self      = shift;
	my $data      = $self->select("select id, name from dim_bi");
	my $zjbd_type = {};
	my $zjbd_id   = {};
	my $bi        = {};
	my $bi_id     = {};
	for my $row (@$data) {
		$zjbd_type->{ $row->{id} } = $row->{name};
		$zjbd_id->{ $row->{name} } = $row->{id};
		$bi->{ $row->{id} }        = $row->{name};
		$bi_id->{ $row->{name} }   = $row->{id};
	}
	$data = $self->select("select id, name from dim_zjbd_type");
	for my $row (@$data) {
		$zjbd_type->{ $row->{id} } = $row->{name};
		$zjbd_id->{ $row->{name} } = $row->{id};
	}
	$self->memd->set( 'zjbd_type', $zjbd_type );
	$self->memd->set( 'zjbd_id',   $zjbd_id );
	$self->memd->set( 'bi',        $bi );
	$self->memd->set( 'bi_id',     $bi_id );
}

# 更新原始凭证字典信息
sub _updateYstype {
	my $self    = shift;
	my $ys_type = {};
	my $data    = $self->select("select code, name from dict_yspz");
	for my $row (@$data) {
		$ys_type->{ $row->{code} } = $row->{name};
	}
	$self->memd->set( 'ys_type', $ys_type );
}

# 更新账户信息
sub _updateAcct {
	my $self    = shift;
	my $acct    = {};
	my $acct_id = {};
	my $data =
	  $self->select( "select a.id as id,z.b_acct as b_acct,z.b_name as b_name "
		  . "from dim_acct a ,dim_zyzj_acct z "
		  . "where a.sub_id = z.id and sub_type=2 "
		  . "union( "
		  . "select a.id as id,b.b_acct as b_acct ,b.b_name as b_name "
		  . "from dim_acct a ,dim_bfj_acct b "
		  . "where a.sub_id = b.id and sub_type=1)" );
	for my $row (@$data) {
		$acct->{ $row->{id} } = $row->{b_name} . '-' . $row->{b_acct};
		$acct_id->{ $row->{b_name} . '-' . $row->{b_acct} } = $row->{id};
	}
	$self->memd->set( 'acct',    $acct );
	$self->memd->set( 'acct_id', $acct_id );
}

# 更新备付金帐号字典信息
sub _updateBfjacct {
	my $self     = shift;
	my $bfj_acct = {};
	my $bfj_id   = {};
	my $data     = $self->select("select id, b_acct, b_name from dim_bfj_acct");
	for my $row (@$data) {
		$bfj_acct->{ $row->{id} } = $row->{b_name} . "-" . $row->{b_acct};
		$bfj_id->{ $row->{b_name} . "-" . $row->{b_acct} } = $row->{id};
	}
	$self->memd->set( 'bfj_acct', $bfj_acct );
	$self->memd->set( 'bfj_id',   $bfj_id );
}

# 更新自有资金帐号字典信息
sub _updateZyzjacct {
	my $self      = shift;
	my $zyzj_acct = {};
	my $zyzj_id   = {};
	my $data = $self->select("select id, b_acct, b_name from dim_zyzj_acct");
	for my $row (@$data) {
		$zyzj_acct->{ $row->{id} } = $row->{b_name} . '-' . $row->{b_acct};
		$zyzj_id->{ $row->{b_name} . '-' . $row->{b_acct} } = $row->{id};
	}
	$self->memd->set( 'zyzj_acct', $zyzj_acct );
	$self->memd->set( 'zyzj_id',   $zyzj_id );
}

# 更新易宝中间账户号字典信息
sub _updateFypacct {
	my $self     = shift;
	my $fyp_acct = {};
	my $fyp_id   = {};
	my $data     = $self->select("select id, acct, name from dim_fyp_acct");
	for my $row (@$data) {
		$fyp_acct->{ $row->{id} } = $row->{name} . "-" . $row->{acct};
		$fyp_id->{ $row->{name} . "-" . $row->{acct} } = $row->{id};
	}
	$self->memd->set( 'fyp_acct', $fyp_acct );
	$self->memd->set( 'fyp_id',   $fyp_id );
}

# 更新货物类型字典信息
sub _updateFhwtype {
	my $self     = shift;
	my $fhw_type = {};
	my $fhw_id   = {};
	my $data     = $self->select("select id, name from dim_fhw_type");
	for my $row (@$data) {
		$fhw_type->{ $row->{id} } = $row->{name};
		$fhw_id->{ $row->{name} } = $row->{id};
	}
	$self->memd->set( 'fhw_type', $fhw_type );
	$self->memd->set( 'fhw_id',   $fhw_id );
}

# 更新富汇易达帐号字典信息
sub _updateFhydacct {
	my $self      = shift;
	my $fhyd_acct = {};
	my $fhyd_id   = {};
	my $data =
	  $self->select("select id, acct, acct_name, name from dim_fhyd_acct");
	for my $row (@$data) {
		$fhyd_acct->{ $row->{id} } = $row->{name} . "-" . $row->{acct};
		$fhyd_id->{ $row->{name} . "-" . $row->{acct} } = $row->{id};
	}
	$self->memd->set( 'fhyd_acct', $fhyd_acct );
	$self->memd->set( 'fhyd_id',   $fhyd_id );
}

sub _decode_ch {
	my $self = shift;
	my $row  = shift;

	# chinese decode
	for (
		qw/route_name route_value role_name role_type
		remark username revoke_cause cause name
		val b_name memo cust_proto c acct_name text
		/
	  )
	{
		$row->{$_} = $self->my_decode( $row->{$_} ) if $row->{$_};
	}
	if ( $row->{revoke_user} ) {
		$row->{revoke_user_name} = $self->usernames->{ $row->{revoke_user} }
		  || $row->{revoke_user};
	}
	if ( $row->{creator} ) {
		$row->{creator_name} = $self->usernames->{ $row->{creator} }
		  || $row->{creator};
	}
	if ( $row->{v_user} ) {
		$row->{v_user_name} = $self->usernames->{ $row->{v_user} }
		  || $row->{v_user};
	}
	if ( $row->{c_user} ) {
		$row->{c_user_name} = $self->usernames->{ $row->{c_user} }
		  || $row->{c_user};
	}
	if ( $row->{crt_id} ) {
		$row->{crt_user} = $self->usernames->{ $row->{crt_id} }
		  || $row->{crt_id};
	}

	# string cut off
	$row->{ts_revoke}  =~ s/\..*$// if $row->{ts_revoke};
	$row->{v_ts}       =~ s/\..*$// if $row->{v_ts};
	$row->{ts_c}       =~ s/\..*$// if $row->{ts_c};
	$row->{ts_u}       =~ s/\..*$// if $row->{ts_u};
	$row->{rec_upd_ts} =~ s/\..*$// if $row->{rec_upd_ts};
}

sub _transform {
	my $self = shift;
	my $row  = shift;

	# 单位转换：分=>元 并格式化
	for (
		qw/j d zjhb_amt zyzj_bfee tx_amt bfj_bfee cwwf_bfee wk_cfee
		bfee yhyf_bamt yhyf_txamt yhys_bamt yhys_txamt bfj_blc zyzj_blc
		zhgl_fee zhlx_amt yhys_bfee yhyf_bfee bfj_bsc zyzj_bsc
		psp_amt cfee psp_lfee lfee bfee_1 bfee_2 bfee_3 cwws_cfee
		cfee_back cwws_cfee_back zg_bfee zg_bfee_1 zg_bfee_2 zg_bfee_3
		ls_amt cwwf_bfee_1 cwwf_bfee_2 bfee_2_back bfee_3_back
		cwwf_bfee_3 cwwf_bfee_1_back cwwf_bfee_2_back cwwf_bfee_3_back
		zg_bfee_1_back zg_bfee_2_back zg_bfee_3_back bfee_1_back
		cc_bfee_1 cc_bfee_2 cc_bfee_3
		cc_bfee_1_back cc_bfee_2_back cc_bfee_3_back in_cost rb_cwwf_bfee
		rb_cwwf_bfee_back bfee_4 bfee_5 cwwf_bfee_4 cwwf_bfee_5 zg_bfee_4 zg_bfee_5
		cj_amt chtx_amt mtx_amt income_amt back_amt entrust_amt yyws_amt
		lc_bfee_1 lc_bfee_2 lc_bfee_3 lc_bfee_4 lc_bfee_5 sc_bfee_1 sc_bfee_2
		sc_bfee_3 sc_bfee_4 sc_bfee_5 sc_amt lc_amt
		/
	  )
	{
		$row->{$_} = $self->nf( $row->{$_} / 100 ) if exists $row->{$_};
	}

	# optional value replace
	for (qw/zjbd_type bfj_zjbd_type zyzj_zjbd_type/) {
		$row->{$_} = $self->zjbd_type->{ $row->{$_} } if defined $row->{$_};
	}
	for (
		qw/bfj_acct bfj_acct_1 bfj_acct_2 bfj_acct_3 bfj_acct_in bfj_acct_out bfj_acct_bj bfj_acct_bfee/
	  )
	{
		$row->{$_} = $self->bfj_acct->{ $row->{$_} }
		  if $row->{$_} && $self->bfj_acct->{ $row->{$_} };
	}
	$row->{zyzj_acct} = $self->zyzj_acct->{ $row->{zyzj_acct} }
	  if $row->{zyzj_acct};

	$row->{fyp_acct} = $self->fyp_acct->{ $row->{fyp_acct} }
	  if $row->{fyp_acct};

	$row->{fhyd_acct} = $self->fhyd_acct->{ $row->{fhyd_acct} }
	  if $row->{fhyd_acct};

	$row->{fhw_type} = $self->fhw_type->{ $row->{fhw_type} }
	  if $row->{fhw_type};

	for (
		qw/flag wlzj_type fyw_type acct mission_status job_status dim_bi_type tx_type status/
	  )
	{
		$row->{$_} = $self->dict->{types}->{$_}{ $row->{$_} }
		  if defined $row->{$_};
	}
	for (qw/pack_status user_role_status/) {
		$row->{ $_ . '_name' } = $self->dict->{types}{$_}{ $row->{$_} }
		  if defined $row->{$_};
	}

	# memcached
	$row->{bi} = $self->bi->{ $row->{bi} } if defined $row->{bi};
	$row->{p}  = $self->p->{ $row->{p} }   if defined $row->{p};

	if ( defined $row->{crt_id} ) {
		if ( $row->{crt_id} == 0 ) {
			$row->{crt_id_name} = "系统";
		}
		else {
			$row->{crt_id_name} = $self->usernames->{ $row->{crt_id} }
			  || $row->{crt_id};
		}
	}
	for (qw/bjhf_period round/) {
		$row->{ $_ . "_trans" } =
		  $self->dict->{types}->{ 'im_' . $_ }->{ $row->{$_} }
		  if defined $row->{$_};
	}
	$row->{bjhf_acct_trans} = $self->bfj_acct->{ $row->{bjhf_acct} }
	  if defined $row->{bjhf_acct};
	$row->{im_bi_trans} = $self->bi->{ $row->{im_bi} } if defined $row->{im_bi};
}

sub _page_data {
	my $self  = shift;
	my $sql   = shift;
	my $page  = shift;
	my $limit = shift;
	my @data;

	my $start = ( $page - 1 ) * $limit + 1;
	my $end   = ( $start + $limit );

	my $sql_data  = "select * from ($sql) where rowid>=$start and rowid < $end";
	my $sql_count = "select count(*) from ($sql)";
	my $dbh       = $self->dbh;
	my $dh        = $dbh->prepare($sql_data);
	my $ch        = $dbh->prepare($sql_count);
	$self->log->error( "can't do [$sql_data]:[" . $dh->errstr . "]" )
	  unless $dh->execute;

	while ( my $row = $dh->fetchrow_hashref ) {
		$self->decode_ch($row);
		push @data, $row;
	}
	$dh->finish;

	$self->log->error( "can't do [$sql_count]:[" . $ch->errstr . "]" )
	  unless $ch->execute;
	my $count = $ch->fetchrow_arrayref->[0];

	return {
		data       => \@data,
		totalCount => $count,
	};
}

sub _select {
	my $self = shift;
	my $sql  = shift;
	my $data;
	my $dh = $self->dbh->prepare($sql);
	$self->log->error( "can't execute [$sql]:[" . $dh->errstr . "]" )
	  unless $dh->execute;
	while ( my $row = $dh->fetchrow_hashref ) {
		$self->decode_ch($row);
		push @$data, $row;
	}
	$dh->finish;
	return $data;
}

sub _errhandle {
	my $self   = shift;
	my $sql    = shift;
	my $errstr = "can't do [$sql]:[" . $self->dbh->errstr . "]";
	$self->log->error($errstr);
	return $errstr;
}

sub _params {
	my $self      = shift;
	my $params    = shift;
	my $condition = '';
	if ( exists $params->{period} && ( ref $params->{period} ) eq 'ARRAY' ) {
		my $data = delete $params->{period};
		unless ( $data->[0] eq "''" ) {
			$condition .= " and period>=$data->[0]";
		}
		unless ( $data->[1] eq "''" ) {
			$condition .= " and period<=$data->[1]";
		}
	}
	if ( exists $params->{status} && $params->{status} ) {
		$condition .= " and status=" . delete $params->{status};
	}

	# 金额乘以100 由元转到分
	for (qw/j d/) {
		if ( exists $params->{$_} ) {
			$params->{$_}[1] *= 100 if defined $params->{$_}[1];
			$params->{$_}[2] *= 100 if defined $params->{$_}[2];
		}
	}
	for my $key ( keys %$params ) {
		my $type = ref $params->{$key};
		if ( $type eq 'ARRAY' ) {

			#
			# 0: >= and <=
			#
			my $data = $params->{$key};
			if ( $data->[0] == 0 ) {
				if ( $data->[1] ) {
					$condition .= " and $key>=$data->[1]";
				}
				if ( $data->[2] ) {
					$condition .= " and $key<=$data->[2]";
				}
			}
			elsif ( $data->[0] == 1 ) {
				$condition .= " and $data->[1]=$data->[2]"
				  if $data->[2];
			}
			elsif ( $data->[0] == 2 ) {
				$condition .= " and $key>=$data->[1]" if $data->[1];
				$condition .= " and $key<=$data->[2]" if $data->[2];
			}
			elsif ( $data->[0] == 3 ) {    # a= b || a<>b
				$condition .= " and  $key=$data->[2]"  if ( $data->[1] == 1 );
				$condition .= " and  $key<>$data->[2]" if ( $data->[1] == 2 );
			}
			elsif ( $data->[0] == 4 ) {    # a= b || a<>b
				$condition .= " and  $key like \'$data->[1]\'"
				  if $data->[1];
			}
		}
		else {
			if ( defined $params->{$key} && $params->{$key} ne '' ) {
				$condition .= " and $key=$params->{$key}";
			}
		}
	}
	$condition =~ s/^ and // if $condition;
	$condition = ' where ' . $condition if $condition;
	return { condition => $condition || '' };
}

sub _gen_file {
	my $self   = shift;
	my $sql    = shift;
	my $header = shift;
	my @hs;
	if ( exists $header->{headers} ) {
		@hs = @{ $header->{headers} };
	}
	else {
		@hs = keys %$header;
	}

	#	my $uuid;
	my $filename;

	#UUID::generate($uuid);
	#UUID::unparse( $uuid, $filename );
	my $dt = DateTime->now( time_zone => 'local' );
	$filename = $dt->ymd . $dt->hms . ".xls";

	#$filename = "${filename}.xls";
	my $path = "$ENV{ZIXWEB_HOME}/var/${filename}";
	my $data = $self->select($sql);

	# Create a new Excel workbook
	my $workbook = Spreadsheet::WriteExcel->new($path);

	# Add a worksheet
	my $worksheet = $workbook->add_worksheet();

	#  Add and define a format
	my $format = $workbook->add_format();
	$format->set_align('center');
	my ( $c, $r ) = ( 0, 0 );

	# 写入表头
	for my $h (@hs) {
		$worksheet->write( 0, $c++, $header->{$h}, $format );
	}
	$r++;
	for my $row (@$data) {
		$self->transform($row);
		$c = 0;
		for my $h (@hs) {
			$worksheet->write( $r, $c, $row->{$h}, $format )
			  if $row->{$h};
			$c++;
		}
		$r++;
	}
	return $filename;
}

sub _post_url {
	my $self = shift;
	my $url  = shift;
	my $data = shift;
	my $json = shift || false;
	my $res  = $self->ua->post( $url, $data )->res;
	my $result;
	my $err = $res->error;

	# 交互出错处理
	if ($err) {
		$result->{msg}     = $err;
		$result->{success} = false;
		$self->log->error("post [$data] to [$url] error[$err]");
		return $result;
	}
	else {
		$json ? $result = $res->json : $result->{success} = true;
	}
	return $result;
}

1;

