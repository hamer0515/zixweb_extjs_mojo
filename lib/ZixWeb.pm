package ZixWeb;

use Mojo::Base 'Mojolicious';
use DBI;
use Env qw/ZIXWEB_HOME/;
use Encode qw/decode/;
use Cache::Memcached;
use JSON::XS;
use Mojo::Log;

#use Crypt::RSA;
use ZixWeb::Utils qw/_post_url _gen_file _updateAcct _transform _updateBfjacct
  _updateFypacct _updateFhydacct _updateFhwtype  _updateZyzjacct
  _updateYstype _updateYwtype _updateBi _updateP _updateUsers _updateRoutes
  _uf _nf _initDict _decode_ch _page_data _select _update
  _errhandle _params _updateFch/;

# This method will run once at server start
sub startup {
	my $self   = shift;
	my $log    = $self->log;
	my $dict   = {};
	my $config = do "$ZIXWEB_HOME/conf/conf.pl";
	my $dbh    = $self->connect_db($config);
	my $memd   = new Cache::Memcached {
		'servers'            => $config->{mem_server},
		'debug'              => 0,
		'compress_threshold' => 10_000,
	};

	#	my $rsa = new Crypt::RSA;
	#	my ( $public, $private ) = $rsa->keygen(
	#		Identity  => 'Lord Macbeth <macbeth@glamis.com>',
	#		Size      => 1024,
	#		Password  => 'A day so foul & fair',
	#		Verbosity => 1,
	#	  )
	#	  or warn $rsa->errstr()
	#	  or kill( INT, $$ );

# 设置session签名的验证码（随机生成，每次重启后台的时候，session失效）
	my $secret = '';
	for ( 1 .. 10 ) {
		$secret .= ${ $config->{di} }[ rand(62) ];
	}
	$self->secret($secret);

	# 设置session过期时间
	$self->session( expiration => $config->{expire} );

	# hypnoload
	$self->config(
		hypnotoad => { listen => [ 'http://*:' . $config->{port} ] } );

	# plugin
	$self->plugin( Charset => { charset => 'utf-8' } );
	$self->plugin('RenderFile');

	# helper
	$self->helper(
		dbh => sub {
			$dbh = $self->connect_db( $self->configure )
			  unless $dbh;
			return $dbh;
		}
	);
	$self->helper(
		whois => sub {
			my $self  = shift;
			my $agent = $self->req->headers->user_agent || 'Anonymous';
			my $ip    = $self->tx->remote_address;
			return "$agent ($ip)";
		}
	);
	$self->helper( log          => sub { return $log; } );
	$self->helper( memd         => sub { return $memd; } );
	$self->helper( configure    => sub { return $config; } );
	$self->helper( header       => sub { return $config->{header}; } );
	$self->helper( quote        => sub { return $self->dbh->quote( $_[1] ); } );
	$self->helper( dict         => sub { return $dict; } );
	$self->helper( transform    => sub { &_transform(@_); } );
	$self->helper( my_decode    => sub { return &decode( 'utf8', $_[1] ); } );
	$self->helper( decode_ch    => sub { &_decode_ch(@_); } );
	$self->helper( page_data    => sub { &_page_data(@_); } );
	$self->helper( select       => sub { &_select(@_); } );
	$self->helper( errhandle    => sub { &_errhandle(@_); } );
	$self->helper( uf           => sub { &_uf( $_[1] ); } );
	$self->helper( nf           => sub { &_nf( $_[1] ); } );
	$self->helper( params       => sub { &_params(@_); } );
	$self->helper( gen_file     => sub { $self->_gen_file( @_[ 1 .. 2 ] ); } );
	$self->helper( post_url     => sub { $self->_post_url( @_[ 1 .. 3 ] ); } );
	$self->helper( updateUsers  => sub { $self->_updateUsers; } );
	$self->helper( updateRoutes => sub { $self->_updateRoutes; } );
	$self->helper( updateP      => sub { $self->_updateP; } );
	$self->helper( updateBi     => sub { $self->_updateBi; } );
	$self->helper( updateYstype => sub { $self->_updateYstype; } );
	$self->helper( updateAcct   => sub { $self->_updateAcct; } );
	$self->helper( updateBfjacct  => sub { $self->_updateBfjacct; } );
	$self->helper( updateZyzjacct => sub { $self->_updateZyzjacct; } );
	$self->helper( updateFypacct  => sub { $self->_updateFypacct; } );
	$self->helper( updateFhydacct => sub { $self->_updateFhydacct; } );
	$self->helper( updateFhwtype  => sub { $self->_updateFhwtype; } );
	$self->helper( updateYwtype   => sub { $self->_updateYwtype; } );

	#	$self->helper( updateFch      => sub { $self->_updateFch; } );
	$self->helper( routes    => sub { $self->memd->get('routes'); } );
	$self->helper( users     => sub { $self->memd->get('users'); } );
	$self->helper( usernames => sub { $self->memd->get('usernames'); } );
	$self->helper( uids      => sub { $self->memd->get('uids'); } );
	$self->helper( p         => sub { $self->memd->get('p'); } );
	$self->helper( p_id      => sub { $self->memd->get('p_id'); } );
	$self->helper( zjbd_type => sub { $self->memd->get('zjbd_type'); } );
	$self->helper( zjbd_id   => sub { $self->memd->get('zjbd_id'); } );
	$self->helper( bi        => sub { $self->memd->get('bi'); } );
	$self->helper( bi_id     => sub { $self->memd->get('bi_id'); } );
	$self->helper( ys_type   => sub { $self->memd->get('ys_type'); } );
	$self->helper( bfj_acct  => sub { $self->memd->get('bfj_acct'); } );
	$self->helper( bfj_id    => sub { $self->memd->get('bfj_id'); } );
	$self->helper( zyzj_acct => sub { $self->memd->get('zyzj_acct'); } );
	$self->helper( zyzj_id   => sub { $self->memd->get('zyzj_id'); } );
	$self->helper( acct      => sub { $self->memd->get('acct'); } );
	$self->helper( acct_id   => sub { $self->memd->get('acct_id'); } );
	$self->helper( fyp_acct  => sub { $self->memd->get('fyp_acct'); } );
	$self->helper( fyp_id    => sub { $self->memd->get('fyp_id'); } );
	$self->helper( fhyd_acct => sub { $self->memd->get('fhyd_acct'); } );
	$self->helper( fhyd_id   => sub { $self->memd->get('fhyd_id'); } );
	$self->helper( fhw_type  => sub { $self->memd->get('fhw_type'); } );
	$self->helper( fhw_id    => sub { $self->memd->get('fhw_id'); } );
	$self->helper( ywtype    => sub { $self->memd->get('yw_type'); } );

	# hook
	$self->hook( before_dispatch => \&_before_dispatch );

	# Router
	$self->set_route;

	# init
	$self->_initDict;
	$self->dbh->rollback;
	$self->dbh->disconnect;
	$dbh = undef;
}

sub _before_dispatch {
	my $self = shift;

	my $path = $self->req->url->path;

	# 可以访问主页
	return 1 if $path =~ /^\/$/;

	# 静态文件可以访问
	if ( $path =~ /(js|jpg|gif|css|png|ico)$/ ) {

		#静态文件启用缓存
		$self->res->headers->cache_control('public');
		return 1;
	}

	#	return 1 if $path =~ /(js|jpg|gif|css|png|ico)$/;

	# 可以进行登录操作
	return 1 if $path =~ /^\/login\/login$/;

	# 可以进行登出操作
	return 1 if $path =~ /^\/login\/logout$/;

	my $sess = $self->session;
	my $uid  = $sess->{uid};

	#	$self->render( json => { success => 'forbidden' } );

	#	$self->rendered(403);
	#	return 0;
	unless ($uid) {
		$self->rendered(403);
		return 0;
	}

	# 登录之後可以访问基础信息数据
	return 1
	  if $path =~ /^\/base/;

	# 登录之後可以獲得菜单
	return 1
	  if $path =~ /^\/login\/menu/;

	my $role = $self->users->{$uid};
	for my $role (@$role) {
		for my $route ( @{ $self->routes->{$role} } ) {
			if ( $path =~ m{$route$} ) {
				return 1;
			}
		}
	}
	$self->render( json => { success => 'forbidden' } );
}

sub connect_db {
	my $self   = shift;
	my $config = shift;
	my $dbh;
	$dbh = DBI->connect(
		$config->{dsn},
		$config->{user},
		$config->{pass},
		{
			RaiseError       => 0,
			PrintError       => 0,
			AutoCommit       => 0,
			FetchHashKeyName => 'NAME_lc',
			ChopBlanks       => 1,
		}
	);
	unless ($dbh) {
		$self->log->error("can not connect $config->{dsn}");
		return;
	}

	$dbh->do("set current schema $config->{schema}")
	  or $self->log->error("can not set current schema $config->{schema}");

	return $dbh;
}

sub set_route {
	my $self = shift;
	my $r    = $self->routes;

	# 登录页面
	$r->any('/')->to( namespace => 'ZixWeb::Login::Login', action => 'show' );

	# 基础信息
	$r->any("/base/$_")
	  ->to( namespace => "ZixWeb::Component::Component", action => $_ )
	  for (
		qw/
		routes roles allroles account
		bfjacct zyzjacct product ystype
		books zjbdtype wlzjtype fhwtype fch_c
		fywtype fypacct fhydacct bi_dict
		c fp cust_proto excel book_headers
		book_dim table_headers dimbyid yspz_fields yw_type
		/
	  );

	# 登录路由
	$r->any("/login/$_")
	  ->to( namespace => "ZixWeb::Login::Login", action => $_ )
	  for (qw/menu passwordreset login logout/);

	# 角色管理
	$r->any("/role/$_")->to( namespace => "ZixWeb::Role::Role", action => $_ )
	  for (qw/list add check update delete/);

	# 用户管理
	$r->any("/user/$_")->to( namespace => "ZixWeb::User::User", action => $_ )
	  for (qw/list add check update/);

	# 特种调帐单录入审核
	$r->any("/task0000/$_")
	  ->to( namespace => "ZixWeb::Task::Task0000", action => $_ )
	  for (qw/list detail pass deny/);

	# 特种调帐单录入审核-富汇易达
	$r->any("/taskf0000/$_")
	  ->to( namespace => "ZixWeb::Task::TaskF0000", action => $_ )
	  for (qw/list detail pass deny/);

	# 凭证撤销审核
	$r->any("/taskpzcx/$_")
	  ->to( namespace => "ZixWeb::Task::Taskpzcx", action => $_ )
	  for (qw/list detail pass deny/);

	# 凭证撤销审核-富汇易达
	$r->any("/taskfpzcx/$_")
	  ->to( namespace => "ZixWeb::Task::TaskFpzcx", action => $_ )
	  for (qw/list detail pass deny/);

	# 我的任务
	$r->any("/taskmy/$_")
	  ->to( namespace => "ZixWeb::Task::Taskmy", action => $_ )
	  for (qw/list detail/);

	# 我的任务-富汇易达
	$r->any("/taskfmy/$_")
	  ->to( namespace => "ZixWeb::Task::TaskFmy", action => $_ )
	  for (qw/list detail/);

	# 资金对账
	$r->any("/zjdz/$_")->to( namespace => "ZixWeb::Zjdz::Zjdz", action => $_ )
	  for (qw/bfj bfjcheck bfjcheckdone bfjgzcx bfjrefresh_mqt bfjresult/);

	# 富汇易达渠道方对账
	$r->any("/zjdz/$_")
	  ->to( namespace => "ZixWeb::Zjdz::Zjdz_qd", action => $_ )
	  for (qw/qd qdcheck qdcheckdone qdgzcx/);

	# 富汇易达易宝中间帐号对账
	$r->any("/zjdz/$_")
	  ->to( namespace => "ZixWeb::Zjdz::Zjdz_fyp", action => $_ )
	  for (qw/fyp fypcheck fypcheckdone fypgzcx/);

	# 帐套查询
	for (qw/all bfj zyzj fhyd/) {
		$r->any("/book/$_")
		  ->to( namespace => "ZixWeb::Book::index", action => $_ );
	}

	# 周期确认
	for (qw/query submit/) {
		$r->any("/zqqr/$_")
		  ->to( namespace => "ZixWeb::Zqqr::$_", action => $_ );
	}

	# 科目历史  详细查询
	for (
		qw/
		adjust_qc adjust_qc_excel
		bamt_yhyf bamt_yhyf_excel
		bamt_yhys bamt_yhys_excel
		bfee_cwwf bfee_cwwf_excel
		bfee_rb bfee_rb_excel
		bfee_yhyf bfee_yhyf_excel
		bfee_yhys bfee_yhys_excel
		bfee_zqqr bfee_zqqr_excel
		bfee_zqqr_zg bfee_zqqr_zg_excel
		bfj_cust bfj_cust_excel
		blc blc_excel
		blc_zyzj blc_zyzj_excel
		bsc bsc_excel
		bsc_jf bsc_jf_excel
		bsc_zyzj bsc_zyzj_excel
		cfee_dqhf cfee_dqhf_excel
		cost_bfee cost_bfee_excel
		cost_bfee_zg cost_bfee_zg_excel
		cost_dfss cost_dfss_excel
		cost_in cost_in_excel
		deposit_bfj deposit_bfj_excel
		deposit_zyzj deposit_zyzj_excel
		fee_jrjg fee_jrjg_excel
		income_add income_add_excel
		income_cfee income_cfee_excel
		income_in income_in_excel
		income_zhlx income_zhlx_excel
		lfee_psp lfee_psp_excel
		txamt_dgd txamt_dgd_excel
		txamt_dqr_byf txamt_dqr_byf_excel
		txamt_dqr_oyf txamt_dqr_oyf_excel
		txamt_dqr_oys txamt_dqr_oys_excel
		txamt_yhyf txamt_yhyf_excel
		txamt_yhys txamt_yhys_excel
		wlzj_yfbf wlzj_yfbf_excel
		wlzj_yfzy wlzj_yfzy_excel
		wlzj_ysbf wlzj_ysbf_excel
		wlzj_yszy wlzj_yszy_excel

		camt_dgd_fhyd camt_dgd_fhyd_excel
		camt_fhyd camt_fhyd_excel
		chamt_dgd_fhyd chamt_dgd_fhyd_excel
		cjgj_fhyd cjgj_fhyd_excel
		ckrsp_fhyd ckrsp_fhyd_excel
		cost_add_fhyd cost_add_fhyd_excel
		cost_dcch_fhyd cost_dcch_fhyd_excel
		cost_fee_fhyd cost_fee_fhyd_excel
		cost_ncss_fhyd cost_ncss_fhyd_excel
		cost_tcss_fhyd cost_tcss_fhyd_excel
		deposit_fhyd deposit_fhyd_excel
		income_add_fhyd income_add_fhyd_excel
		income_main_fhyd income_main_fhyd_excel
		nctxamt_dqr_oyf_fhyd nctxamt_dqr_oyf_fhyd_excel
		nctxamt_dqr_oys_fhyd nctxamt_dqr_oys_fhyd_excel
		oyf_nctxamt_dqr_fhyd oyf_nctxamt_dqr_fhyd_excel
		oyf_tctxamt_dqr_fhyd oyf_tctxamt_dqr_fhyd_excel
		oys_nctxamt_dqr_fhyd oys_nctxamt_dqr_fhyd_excel
		oys_tctxamt_dqr_fhyd oys_tctxamt_dqr_fhyd_excel
		qdlc_fhyd qdlc_fhyd_excel
		qdsc_fhyd qdsc_fhyd_excel
		tctxamt_dqr_oyf_fhyd tctxamt_dqr_oyf_fhyd_excel
		tctxamt_dqr_oys_fhyd tctxamt_dqr_oys_fhyd_excel
		tkhd_fhyd tkhd_fhyd_excel
		wlzj_fhyd wlzj_fhyd_excel
		yfamt_ch_dgd_fhyd yfamt_ch_dgd_fhyd_excel
		yfamt_ch_fhyd yfamt_ch_fhyd_excel
		yfamt_ckrsp_fhyd yfamt_ckrsp_fhyd_excel
		yfamt_dcch_fhyd yfamt_dcch_fhyd_excel
		yfamt_m_fhyd yfamt_m_fhyd_excel
		yfamt_qdlc_fhyd yfamt_qdlc_fhyd_excel
		yfamt_yplc_fhyd yfamt_yplc_fhyd_excel
		yplc_fhyd yplc_fhyd_excel
		ypsc_fhyd ypsc_fhyd_excel
		yp_acct_fhyd yp_acct_fhyd_excel
		ysamt_c_dgd_fhyd ysamt_c_dgd_fhyd_excel
		ysamt_c_fhyd ysamt_c_fhyd_excel
		ysamt_qdsc_fhyd ysamt_qdsc_fhyd_excel
		ysamt_ypsc_fhyd ysamt_ypsc_fhyd_excel
		yufamt_ch_fhyd yufamt_ch_fhyd_excel
		yufamt_yp_fhyd yufamt_yp_fhyd_excel
		yusamt_c_fhyd yusamt_c_fhyd_excel
		/
	  )
	{

		if (/excel$/) {

			#			my $pm = join '_', ( grep !/^excel$/, ( split '_', $_ ) );
			$r->any("/book/sum/$_")->to(
				namespace => 'ZixWeb::Book::index',
				action    => 'sum_excel'
			);
			$r->any("/book/detail/$_")->to(
				namespace => 'ZixWeb::Book::index',
				action    => 'detail_excel'
			);
		}
		else {
			$r->any("/book/detail/$_")
			  ->to( namespace => "ZixWeb::Book::index", action => 'detail' );
			$r->any("/book/sum/$_")
			  ->to( namespace => "ZixWeb::Book::index", action => 'sum' );
		}
	}

	# 原始凭证查询
	for (
		qw/
		y0000 y0001 y0002 y0003 y0004
		y0005 y0006 y0007 y0008 y0009
		y0010 y0011 y0012 y0013 y0014
		y0015 y0016 y0017 y0018
		y0028 y0029
		y0030 y0031 y0032 y0033 y0034
		y0035 y0036 y0037 y0038 y0039
		y0040 y0041 y0042 y0043 y0044
		y0045 y0046 y0047 y0048 y0049
		y0050 y0051 y0052 y0053 y0054
		y0055 y0056 y0057 y0058 y0059
		y0060 y0061 y0062 y0063 y0064
		y0065 y0066 y0067 y0068 y0069
		y0070 y0071 y0072 y0073 y0074
		y0075 y0076 y0077 y0078 y0079
		y0080 y0081 y0082 y0083 y0084
		y0085 y0086 y0087 y0088 y0089
		y0090 y0091 y0092 y0093 y0094
		y0095 y0096 y0097 y0098 y0099
		y0100 y0101 y0102 y0103 y0104
		y0105 y0106 y0107 y0108 y0109
		y0110 y0111 y0112 y0113 y0114
		y0115 y0116 y0117 y0118 y0119
		y0120 y0121 y0122 y0123 y0124
		y0143 y0144 y0145 y0146 y0147
		y0148 y0149

		yF0001 yF0002 yF0003 yF0004 yF0005
		yF0006 yF0007 yF0008 yF0009 yF0010
		yF0011 yF0012 yF0013 yF0014 yF0015
		yF0016 yF0017 yF0018 yF0019 yF0020
		yF0021 yF0000

		yF0022 yF0023 yF0024 yF0025 yF0026
		yF0027 yF0028 yF0029 yF0030 yF0031
		yF0032 yF0033 yF0034 yF0035 yF0036
		yF0037 yF0038 yF0039 yF0040 yF0041
		yF0042 yF0043 yF0044 yF0045 yF0047
		detail/
	  )
	{
		$r->any("/yspzq/$_")->to(
			namespace => "ZixWeb::Yspzq::Yspz",
			action    => 'list',
			ys_id     => substr( $_, 1 )
		);

		#		  ->to( namespace => "ZixWeb::Yspzq::\u$_", action => $_ );
	}

	# 凭证撤销
	$r->any("/yspz/revoke")
	  ->to( namespace => "ZixWeb::Pzlr::Revoke", action => 'revoke' );

	# 凭证录入
	for (
		qw/i0000 i0001 i0006 i0008 i0009 i0013
		i0014 i0015 i0018 i0028 i0029 i0054 i0101
		i0148 i0149
		/
	  )
	{
		$r->any("/pzlr/$_")
		  ->to( namespace => "ZixWeb::Pzlr::\u$_", action => $_ );
	}

	# 凭证录入-富汇易达
	for (qw/f0000/) {
		$r->any("/pzlr/$_")
		  ->to( namespace => "ZixWeb::Pzlr::\u$_", action => $_ );
	}

	# 凭证导入
	$r->any("/pzlr/mission")
	  ->to( namespace => "ZixWeb::Pzlr::Mission", action => 'mission' );
	$r->any("/pzlr/action")
	  ->to( namespace => "ZixWeb::Pzlr::Action", action => 'action' );
	$r->any("/pzlr/job")
	  ->to( namespace => "ZixWeb::Pzlr::Job", action => 'job' );

	# 基础数据维护
	for (qw/list check add edit query/) {
		$r->any("/jcsjwh/bfjacct/$_")
		  ->to( namespace => "ZixWeb::Jcsjwh::bfjacct", action => $_ );
	}
}
1;
