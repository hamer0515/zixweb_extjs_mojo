package ZixWeb;

use Mojo::Base 'Mojolicious';
use DBI;
use Env qw/ZIXWEB_HOME/;
use Encode qw/decode/;
use Cache::Memcached;
use Mojolicious::Plugin::WWWSession;
use ZixWeb::Utils qw/_updateAcct _transform _updateBfjacct _updateZyzjacct _updateYstype _updateBi _updateP _updateUsers _updateRoutes _uf _nf _initDict _decode_ch _page_data _select _update _errhandle _params/;
use constant {
    DEBUG  => $ENV{ZIXWEB_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}
# This method will run once at server start
sub startup {
    my $self    = shift;
    my $dict = {};
    my $config  = do "$ZIXWEB_HOME/conf/conf.pl";
    my $dbh     = &connect_db($config);
    my $memd = new Cache::Memcached {
        'servers' => $config->{mem_server},
        'debug' => 0,
        'compress_threshold' => 10_000,
    };
    #$self->sessions(WWW::Session->new('zixweb', {}));
    # hypnoload
    $self->config(hypnotoad => {
        listen => [ 'http://*:'.$config->{port} ] 
        });
    
    # plugin
    $self->plugin( Charset => { charset => 'utf-8' } );
    $self->plugin('RenderFile');
    $self->plugin(
        WWWSession => {
               storage => [ 
                            'Memcached' => { servers => $config->{mem_server} }
                          ],
               serialization => 'JSON',
               expires => $config->{expire},
            }
    );
    
    # helper
    $self->helper( dbh          => sub { $dbh = &connect_db($self->configure) unless $dbh; return $dbh; } );
    $self->helper( memd         => sub { return $memd; } );
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
    $self->helper( uf           => sub { &_uf($_[1]); } );
    $self->helper( nf           => sub { &_nf($_[1]); } );
    $self->helper( params       => sub { &_params(@_); } );
    $self->helper( updateUsers  => sub { $self->_updateUsers; } );
    $self->helper( updateRoutes => sub { $self->_updateRoutes; } );
    $self->helper( updateP      => sub { $self->_updateP; } );
    $self->helper( updateBi     => sub { $self->_updateBi; } );
    $self->helper( updateYstype => sub { $self->_updateYstype; } );
    $self->helper( updateAcct   => sub { $self->_updateAcct; } );
    $self->helper( updateBfjacct => sub { $self->_updateBfjacct; } );
    $self->helper( updateZyzjacct => sub { $self->_updateZyzjacct; } );
    $self->helper( routes       => sub { $self->memd->get('routes'); } );
    $self->helper( users        => sub { $self->memd->get('users'); } );
    $self->helper( usernames    => sub { $self->memd->get('usernames'); } );
    $self->helper( uids         => sub { $self->memd->get('uids'); } );
    $self->helper( p            => sub { $self->memd->get('p'); } );
    $self->helper( p_id         => sub { $self->memd->get('p_id'); } );
    $self->helper( zjbd_type    => sub { $self->memd->get('zjbd_type'); } );
    $self->helper( zjbd_id      => sub { $self->memd->get('zjbd_id'); } );
    $self->helper( bi           => sub { $self->memd->get('bi'); } );
    $self->helper( bi_id        => sub { $self->memd->get('bi_id'); } );
    $self->helper( ys_type      => sub { $self->memd->get('ys_type'); } );
    $self->helper( bfj_acct     => sub { $self->memd->get('bfj_acct'); } );
    $self->helper( bfj_id       => sub { $self->memd->get('bfj_id'); } );
    $self->helper( zyzj_acct    => sub { $self->memd->get('zyzj_acct'); } );
    $self->helper( zyzj_id      => sub { $self->memd->get('zyzj_id'); } ); 
    $self->helper( acct         => sub { $self->memd->get('acct'); } );
    $self->helper( acct_id      => sub { $self->memd->get('acct_id'); } );  

    # hook
    #$self->hook( before_dispatch => \&before_dispatch );

    # Router
    $self->set_route;
    
    # init
    $self->_initDict;
    $self->dbh->rollback;
    $self->dbh->disconnect;
    $dbh = undef;
}

sub before_dispatch {
    my $self = shift;
    
    my $path = $self->req->url->path;
    return 1 if $path =~ /^\/login\/(login|logout)/;    # 登陆退出可以访问
    return 1 if $path =~ /^\/$/;                        # 登陆页面可以访问
    return 1 if $path =~ /[js|jpg|gif|css|json]$/;        # 静态文件可以访问
    return 1 if $path =~ /^\/fail.html$/;               # fail
    return 1 if $path =~ /^\/login.html$/;              # login

    my $sess = $self->session;
    # 没有登陆不让访问
    
    unless ( exists $sess->{uid} ) {
        $self->redirect_to("/");
        return;
    }
    
    return 1 if $path =~ /^\/login/;    # 可以访问主菜单
    return 1 if $path =~ /^\/base/;    # 可以访问主菜单
    
    if ( $path =~ /\.html$/ ) {
        return 1;
    }    
    my $uid = $sess->{uid};
    my $role = $self->users->{ $uid };
    for my $role( @$role ) {
        for my $route( @{$self->routes->{$role}} ) {
            if ( $path =~ m{$route$} ) {
                return 1;
            }
        }
    } 
    $self->redirect_to("/denied.html");
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
    unless($dbh) {
        die "can not connect $config->{dsn}";
        return;
    }

    $dbh->do("set current schema $config->{schema}")
      or die "can not set current schema $config->{schema}";
    
    return $dbh;
}

sub set_route {
    my $self = shift;
    my $r = $self->routes;
    
    # login controller
    $r->any('/')->to(namespace => 'ZixWeb::SystemMgr::Login', action => 'show', template => 'login');
    $r->any("/base/$_")->to(namespace => "ZixWeb::Basic::Base", action => $_)   for (qw/routes roles allroles account bfjacct zyzjacct product ystype books zjbdtype bi_dict c fp cust_proto/);
    $r->any("/login/$_")->to(namespace => "ZixWeb::SystemMgr::Login", action => $_, template => "systemmgr/login/$_")   for (qw/menu passwordreset login logout/);
    $r->any("/role/$_")->to(namespace => "ZixWeb::SystemMgr::Role", action => $_)      for (qw/list add check update delete/);
    $r->any("/user/$_")->to(namespace => "ZixWeb::SystemMgr::User", action => $_)      for (qw/list add check update/);
    $r->any("/yspz/itztz")->to(namespace => "ZixWeb::VoucherEntry::Specialbills", action => 'add');
    $r->get("/specialbills/$_")->to(namespace => "ZixWeb::VoucherEntry::Specialbills", action => $_, template => "voucherentry/specialbills/$_")      for (qw/input add check_c check_custproto/);
    $r->get("/cocert/$_")->to(namespace => "ZixWeb::CocertMgr::Cocert", action => $_, template => "cocertmgr/$_")      for (qw/cocert detail detail_pz operate examresult/);  
    $r->any("/task0000/$_")->to(namespace => "ZixWeb::Task::Task0000", action => $_) for (qw/list detail pass deny/);
    $r->any("/taskpzcx/$_")->to(namespace => "ZixWeb::Task::Taskpzcx", action => $_) for (qw/list detail pass deny/);
    $r->any("/taskmy/$_")->to(namespace => "ZixWeb::Task::Taskmy", action => $_) for (qw/list detail pass deny/);
    $r->any("/zjdz/$_")->to(namespace => "ZixWeb::ReconciliationMgr::Reconciliation", action => $_, template => "reconciliationmgr/$_")     for (qw/bfj bfjcheck checkdone gzcx/);
    
    # BookMgr
    for ( qw/all bfj zyzj/) {
        $r->get("/book/$_")->to(namespace => "ZixWeb::BookMgr::index", action => $_);
    }
    
    # 周期确认
    for ( qw/select index submit/ ) {
        $r->get("/ack/$_")->to(namespace => "ZixWeb::Ack::ack", action => $_, template => "ack/$_");
    }
    
    # hist book
    for ( qw/deposit_bfj bamt_yhys deposit_zyzj txamt_dgd 
            txamt_yhys bfee_yhys cfee_dqhf bsc bsc_zyzj 
            txamt_yhyf bamt_yhyf bfee_yhyf bfj_cust blc 
            blc_zyzj txamt_dqr_oyf wlzj_ysbf wlzj_yszy 
            wlzj_yfbf wlzj_yfzy income_cfee cost_bfee 
            cost_dfss income_zhlx fee_jrjg bfee_cwwf
            txamt_dqr_oys txamt_dqr_byf cost_bfee_zg
            lfee_psp income_in cost_in
	    bfee_zqqr bfee_zqqr_zg/) { 
        $r->get("/book/hist/$_")->to(namespace => "ZixWeb::BookMgr::Hist::$_", action => $_, template => "bookmgr/hist/$_");
        $r->get("/book/detail/$_")->to(namespace => "ZixWeb::BookMgr::Book::$_", action => $_, template => "bookmgr/book/$_");
    }

    
    for ( qw/y0000 y0001 y0002 y0003 y0004 y0005 
             y0006 y0007 y0008 y0009 y0010 y0011 
             y0012 y0013 y0014 y0015 y0016 y0017
             y0018 y0019 y0020 y0021 y0022 y0023
             y0024 y0025 y0026 y0027 y0028 y0029
             y0030 y0031 y0032 y0033 y0034 y0035
             y0036 y0037 y0038 y0039 y0040 y0041
             y0042 y0043 y0044 y0045 y0046 y0047
             y0048 y0049 y0050 y0051 y0052 y0053
             y0054
             detail/) { 
        $r->any("/yspzq/$_")->to(namespace => "ZixWeb::SourceDocMgr::\u$_", action => $_);
    }     
    $r->any("/yspz/revoke")->to(namespace => "ZixWeb::SourceDocMgr::Revoke", action => 'revoke');
    for (qw/i0001 i0006 i0008 i0009 i0013 i0014 i0015
            i0018 i0028 i0029 i0054
         /) {
        $r->get("/yspzgl/$_")->to(namespace => "ZixWeb::VoucherEntry::\u$_", action => $_, template => "voucherentry/$_");
    }
    $r->get("/yspzgl/add")->to(namespace => 'ZixWeb::VoucherEntry::Action', action => 'add', template => 'voucherentry/add');
    for (qw/tbsp adjust_tbsp add_task list_task commit_task/) {
        $r->get("/management/$_")->to(namespace => "ZixWeb::MaintenanceMgr::TBSP", action => $_, template => "maintenancemgr/$_");
    }
    $r->any("/pzlr/mission")->to(namespace => "ZixWeb::VoucherEntry::Mission", action => 'mission');
    $r->any("/pzlr/action")->to(namespace => "ZixWeb::VoucherEntry::Action", action => 'action');
    $r->any("/pzlr/job")->to(namespace => "ZixWeb::VoucherEntry::Job", action => 'job');
    for (qw/index input add delete edit submit/) {
        $r->get("/bip/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Bip", action => $_, template => "basicinfomgr/bip/$_");
        $r->get("/dictyspz/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Dictyspz", action => $_, template => "basicinfomgr/dictyspz/$_");
        $r->get("/dimbi/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Dimbi", action => $_, template => "basicinfomgr/dimbi/$_");
        $r->get("/dimp/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Dimp", action => $_, template => "basicinfomgr/dimp/$_");
        $r->get("/acct/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Acct", action => $_, template => "basicinfomgr/acct/$_");
        $r->get("/acctbfj/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Acctbfj", action => $_, template => "basicinfomgr/acctbfj/$_");
        $r->get("/acctzyzj/$_")->to(namespace => "ZixWeb::BasicInfoMgr::Acctzyzj", action => $_, template => "basicinfomgr/acctzyzj/$_");
    }
    $r->get("/holi/index")->to(namespace => "ZixWeb::BasicInfoMgr::Holi", template => "basicinfomgr/holi/index");
    $r->post("/holi/upload")->to(namespace => "ZixWeb::BasicInfoMgr::Holi", action => 'upload', template => "basicinfomgr/holi/upload");
}


1;
