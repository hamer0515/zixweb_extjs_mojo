package ZixWeb;

use Mojo::Base 'Mojolicious';
use DBI;
use Env qw/ZIXWEB_HOME/;
use Encode qw/decode/;
use Cache::Memcached;
use ZixWeb::Utils
  qw/_updateAcct _transform _updateBfjacct _updateFypacct _updateFhydacct _updateFhwtype  _updateZyzjacct _updateYstype _updateBi _updateP _updateUsers _updateRoutes _uf _nf _initDict _decode_ch _page_data _select _update _errhandle _params/;

# This method will run once at server start
sub startup {
	my $self   = shift;
	my $dict   = {};
	my $config = do "$ZIXWEB_HOME/conf/conf.pl";
	my $dbh    = &connect_db($config);
	my $memd   = new Cache::Memcached {
		'servers'            => $config->{mem_server},
		'debug'              => 0,
		'compress_threshold' => 10_000,
	};

# 设置session签名的验证码（随机生成，每次重启后台的时候，session失效）
	my $secret = '';
	for ( 1 .. 10 ) {
		$secret .= ${ $config->{di} }[ rand(62) ];
	}
	$self->secret($secret);

	# 设置session过期时间
	$self->session( expiration => $config->{expire} );

#my $logdir = "$ZIXWEB_HOME/log";
#unless (-e $logdir && -d $logdir){
#    `mkdir $logdir`;
#}
#my $logfile = "$ZIXWEB_HOME/log/zixweb.log";
#unless (-e $logfile){
#    `touch $logfile`;
#}
#my $log = Mojo::Log->new(path => "$ZIXWEB_HOME/log/zixweb.log", level => 'info');
# hypnoload
	$self->config(
		hypnotoad => { listen => [ 'http://*:' . $config->{port} ] } );

	# plugin
	$self->plugin( Charset => { charset => 'utf-8' } );

	# helper
	$self->helper(
		dbh => sub {
			$dbh = &connect_db( $self->configure )
			  unless $dbh;
			return $dbh;
		}
	);
	$self->helper( memd => sub { return $memd; } );

	#$self->helper( log          => sub { return $log; } );
	$self->helper( configure    => sub { return $config; } );
	$self->helper( quote        => sub { return $self->dbh->quote( $_[1] ); } );
	$self->helper( dict         => sub { return $dict; } );
	$self->helper( transform    => sub { &_transform(@_); } );
	$self->helper( my_decode    => sub { return &decode( 'utf8', $_[1] ); } );
	$self->helper( decode_ch    => sub { &_decode_ch(@_); } );
	$self->helper( page_data    => sub { &_page_data(@_); } );
	$self->helper( select       => sub { &_select(@_); } );
	$self->helper( update       => sub { &_update(@_); } );
	$self->helper( errhandle    => sub { &_errhandle(@_); } );
	$self->helper( uf           => sub { &_uf( $_[1] ); } );
	$self->helper( nf           => sub { &_nf( $_[1] ); } );
	$self->helper( params       => sub { &_params(@_); } );
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
	$self->helper( routes         => sub { $self->memd->get('routes'); } );
	$self->helper( users          => sub { $self->memd->get('users'); } );
	$self->helper( usernames      => sub { $self->memd->get('usernames'); } );
	$self->helper( uids           => sub { $self->memd->get('uids'); } );
	$self->helper( p              => sub { $self->memd->get('p'); } );
	$self->helper( p_id           => sub { $self->memd->get('p_id'); } );
	$self->helper( zjbd_type      => sub { $self->memd->get('zjbd_type'); } );
	$self->helper( zjbd_id        => sub { $self->memd->get('zjbd_id'); } );
	$self->helper( bi             => sub { $self->memd->get('bi'); } );
	$self->helper( bi_id          => sub { $self->memd->get('bi_id'); } );
	$self->helper( ys_type        => sub { $self->memd->get('ys_type'); } );
	$self->helper( bfj_acct       => sub { $self->memd->get('bfj_acct'); } );
	$self->helper( bfj_id         => sub { $self->memd->get('bfj_id'); } );
	$self->helper( zyzj_acct      => sub { $self->memd->get('zyzj_acct'); } );
	$self->helper( zyzj_id        => sub { $self->memd->get('zyzj_id'); } );
	$self->helper( acct           => sub { $self->memd->get('acct'); } );
	$self->helper( acct_id        => sub { $self->memd->get('acct_id'); } );
	$self->helper( fyp_acct       => sub { $self->memd->get('fyp_acct'); } );
	$self->helper( fyp_id         => sub { $self->memd->get('fyp_id'); } );
	$self->helper( fhyd_acct      => sub { $self->memd->get('fhyd_acct'); } );
	$self->helper( fhyd_id        => sub { $self->memd->get('fhyd_id'); } );
	$self->helper( fhw_type       => sub { $self->memd->get('fhw_type'); } );
	$self->helper( fhw_id         => sub { $self->memd->get('fhw_id'); } );

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
	return 1 if $path =~ /^\/$/;                      # 登陆页面可以访问
	return 1 if $path =~ /(js|jpg|gif|css|png|ico)$/; # 静态文件可以访问
	return 1 if $path =~ /html$/;                     # login

	my $sess = $self->session;

	# 没有登陆不让访问
	return 1 if $path =~ /^\/login/;                  # 可以访问主菜单
	return 1 if $path =~ /^\/base/;                   # 可以访问主菜单

	if ( $path =~ /^index.html$/ ) {
		unless ( exists $sess->{uid} ) {
			$self->redirect_to('/');
			return;
		}
	}
	my $uid  = $sess->{uid};
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

#
#
#
sub connect_db {
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
		die "can not connect $config->{dsn}";
		return;
	}

	$dbh->do("set current schema $config->{schema}")
	  or die "can not set current schema $config->{schema}";

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
		qw/routes roles allroles account bfjacct zyzjacct product ystype books zjbdtype wlzjtype fhwtype fywtype fypacct fhydacct bi_dict c fp cust_proto/
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

	# 凭证撤销审核
	$r->any("/taskpzcx/$_")
	  ->to( namespace => "ZixWeb::Task::Taskpzcx", action => $_ )
	  for (qw/list detail pass deny/);

	# 我的任务
	$r->any("/taskmy/$_")
	  ->to( namespace => "ZixWeb::Task::Taskmy", action => $_ )
	  for (qw/list detail/);

	# 资金对账
	$r->any("/zjdz/$_")->to( namespace => "ZixWeb::Zjdz::Zjdz", action => $_ )
	  for (qw/bfj bfjcheck bfjcheckdone bfjgzcx/);

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
		qw/deposit_bfj bamt_yhys deposit_zyzj txamt_dgd
		txamt_yhys bfee_yhys cfee_dqhf bsc bsc_zyzj
		txamt_yhyf bamt_yhyf bfee_yhyf bfj_cust blc
		blc_zyzj txamt_dqr_oyf wlzj_ysbf wlzj_yszy
		wlzj_yfbf wlzj_yfzy income_cfee cost_bfee
		cost_dfss income_zhlx fee_jrjg bfee_cwwf
		txamt_dqr_oys txamt_dqr_byf cost_bfee_zg
		lfee_psp income_in cost_in
		bfee_zqqr bfee_zqqr_zg ckrsp_fhyd 
		camt_fhyd income_main_fhyd income_add_fhyd /
	  )
	{
		$r->any("/book/hist/$_")
		  ->to( namespace => "ZixWeb::Book::Hist::$_", action => $_ );
		$r->any("/book/detail/$_")
		  ->to( namespace => "ZixWeb::Book::Detail::$_", action => $_ );
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
		detail/
	  )
	{
		$r->any("/yspzq/$_")
		  ->to( namespace => "ZixWeb::Yspzq::\u$_", action => $_ );
	}

	# 凭证撤销
	$r->any("/yspz/revoke")
	  ->to( namespace => "ZixWeb::Yspz::Revoke", action => 'revoke' );

	# 凭证录入
	for (
		qw/i0000 i0001 i0006 i0008 i0009 i0013
		i0014 i0015 i0018 i0028 i0029 i0054 i0101
		/
	  )
	{
		$r->any("/pzlr/$_")
		  ->to( namespace => "ZixWeb::Yspz::\u$_", action => $_ );
	}

	# 凭证导入
	$r->any("/pzlr/mission")
	  ->to( namespace => "ZixWeb::Yspz::Mission", action => 'mission' );
	$r->any("/pzlr/action")
	  ->to( namespace => "ZixWeb::Yspz::Action", action => 'action' );
	$r->any("/pzlr/job")
	  ->to( namespace => "ZixWeb::Yspz::Job", action => 'job' );
}

1;
