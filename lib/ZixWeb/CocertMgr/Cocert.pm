package ZixWeb::CocertMgr::Cocert;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;
use boolean;
use URI::Escape;
use constant {
  DEBUG  => $ENV{COCERT_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}
#
#模块名称:待审核任务列表
#
#param:tag 
#      index 第几页
#      id   任务编号
#      status 审核状态
#      type 类型
#      c_user 创建人
#      from 创建时间起始
#      to   创建时间终止
#return: hash 数据集
#{
#  c_user => ,
#  count => 5,
#  data => [
#    {
#      exc_user  => 1,
#      exid      => 5,
#      exstatus  => 2,
#      rowid     => 5,
#      ts_c      => "2013-05-07 17:36:16",
#      type      => 2,
#      uusername => "admin",
#    },
#    {
#      exc_user  => 1,
#      exid      => 4,
#      exstatus  => 1,
#      rowid     => 4,
#      ts_c      => "2013-05-07 17:34:51",
#      type      => 2,
#      uusername => "admin",
#    },
#  ],
#  from => ,
#  id => ,
#  index => 1,
#  next_page => 1,
#  prev_page => 1,
#  status => undef,
#  to => ,
#  total_page => 1,
#  type => ,
#}
sub cocert {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $id = $self->param('id');
    
    my $params = {};
    for (qw/c_user from to status type/) {
        my $p = $self->param($_);
        $p = undef if $p eq '';
        $params->{$_} = $p;
    }
    
    my $p->{condition} = '';
    if ( $id ) {
        $p = $self->params( { 
                id => $id
                } );
    }
    else {
        $p = $self->params(
            {
                ts_c    => [0, $params->{from} && $self->quote($params->{from}), $params->{to} && $self->quote($params->{to}) ],
                status  => $params->{status},
                type    => $params->{type},
                c_user  => $params->{c_user} && $self->uids->{$params->{c_user}}
            }
        );
    }
    
    my $sql =
        "select id, content, c_user, ts_c, status as sh_status, type as sh_type, rownumber() over(order by id desc) as rowid from verify $p->{condition}";
    my $data = $self->page_data( $sql, $page, $limit );
    
    for my $d (@{$data->{data}}){
        my $content = decode_json delete $d->{content};
        $d->{cause} = $content->{cause} if $content->{cause};
        $d->{cause} = $content->{revoke_cause} if $content->{revoke_cause};
    }
    $data->{success} = true;
    
    $self->render(json => $data);
}

#
#模块名称:审核任务的详细 -->特种调账单
#
#param:id  任务编号
#
#return :hash 数据集
#{
#  acct => "{\"6\":\"\x{6CB3}\x{5317}\x{94F6}\x{884C}\x{671D}\x{9633}\x{8DEF}\x{652F}\x{884C}-01541100000425\",\"11\":\"\x{6D66}\x{53D1}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5317}\x{6C99}\x{6EE9}\x{652F}\x{884C}-91350154800005063\",\"3\":\"\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300023518\",\"7\":\"\x{5EFA}\x{8BBE}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5EFA}\x{56FD}\x{652F}\x{884C}-11001042500053001473\",\"9\":\"\x{5E73}\x{5B89}\x{94F6}\x{884C}\x{4E0A}\x{6D77}\x{5F20}\x{6C5F}\x{652F}\x{884C}-2000004743525\",\"12\":\"\x{6D66}\x{53D1}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5317}\x{6C99}\x{6EE9}\x{652F}\x{884C}-91350154800005071\",\"2\":\"\x{5317}\x{4EAC}\x{94F6}\x{884C}\x{4E0A}\x{6D77}\x{5206}\x{884C}\x{8425}\x{4E1A}\x{90E8}-00130630500120109167292\",\"14\":\"\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010\",\"8\":\"\x{519C}\x{4E1A}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{4E0A}\x{6B65}\x{652F}\x{884C}-41-004300040017055\",\"1\":\"\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010\",\"4\":\"\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300055838\",\"13\":\"\x{4E0A}\x{6D77}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-017014908-03001762876\",\"10\":\"\x{5E73}\x{5B89}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{5206}\x{884C}-2000007916325\",\"5\":\"\x{5149}\x{5927}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{4EAC}\x{5E7F}\x{6865}\x{652F}\x{884C}-35310188000063804\"}",
#  bfj_acct => "{\"11\":\"\x{6D66}\x{53D1}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5317}\x{6C99}\x{6EE9}\x{652F}\x{884C}-91350154800005063\",\"7\":\"\x{5EFA}\x{8BBE}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5EFA}\x{56FD}\x{652F}\x{884C}-11001042500053001473\",\"2\":\"\x{5317}\x{4EAC}\x{94F6}\x{884C}\x{4E0A}\x{6D77}\x{5206}\x{884C}\x{8425}\x{4E1A}\x{90E8}-00130630500120109167292\",\"1\":\"\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010\",\"16\":\"\x{4E2D}\x{56FD}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{5EFA}\x{5B89}\x{8DEF}\x{652F}\x{884C}-774459222622\",\"13\":\"\x{4E0A}\x{6D77}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-017014908-03001762876\",\"6\":\"\x{6CB3}\x{5317}\x{94F6}\x{884C}\x{671D}\x{9633}\x{8DEF}\x{652F}\x{884C}-01541100000425\",\"3\":\"\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300023518\",\"9\":\"\x{5E73}\x{5B89}\x{94F6}\x{884C}\x{4E0A}\x{6D77}\x{5F20}\x{6C5F}\x{652F}\x{884C}-2000004743525\",\"12\":\"\x{6D66}\x{53D1}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5317}\x{6C99}\x{6EE9}\x{652F}\x{884C}-91350154800005071\",\"14\":\"\x{6E29}\x{5DDE}\x{94F6}\x{884C}\x{4E0A}\x{6D77}\x{5206}\x{884C}\x{8425}\x{4E1A}\x{90E8}-905000120190019139\",\"15\":\"\x{4E2D}\x{56FD}\x{90AE}\x{653F}\x{50A8}\x{84C4}\x{94F6}\x{884C}\x{5E7F}\x{5DDE}\x{8354}\x{6E7E}\x{652F}\x{884C}-100527227860010004\",\"8\":\"\x{519C}\x{4E1A}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{4E0A}\x{6B65}\x{652F}\x{884C}-41-004300040017055\",\"4\":\"\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300055838\",\"10\":\"\x{5E73}\x{5B89}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{5206}\x{884C}-2000007916325\",\"5\":\"\x{5149}\x{5927}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{4EAC}\x{5E7F}\x{6865}\x{652F}\x{884C}-35310188000063804\"}",
#  bi => "{\"6\":\"\x{4E0A}\x{6D77}\x{94F6}\x{8054}\x{4EE3}\x{6536}\x{901A}\x{9053}        \",\"3\":\"\x{519C}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"7\":\"\x{6C11}\x{751F}\x{94F6}\x{8054}\x{4EE3}\x{6536}\x{901A}\x{9053}        \",\"9\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{8D4E}\x{56DE}\x{672C}\x{6253}        \",\"2\":\"\x{5EFA}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"8\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{4EE3}\x{7ED3}              \",\"1\":\"\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"4\":\"\x{5149}\x{5927}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"10\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{8D4E}\x{56DE}\x{5B83}\x{6253}        \",\"5\":\"\x{6E29}\x{5DDE}\x{94F6}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}        \"}",
#  p => "{\"4\":\"\x{57FA}\x{91D1}\x{59D4}\x{6258}\x{51FA}\x{6B3E}\x{6C47}\x{5165}\",\"1\":\"\x{57FA}\x{91D1}\x{6536}\x{6B3E}\",\"3\":\"\x{57FA}\x{91D1}\x{59D4}\x{6258}\x{51FA}\x{6B3E}\",\"2\":\"\x{57FA}\x{91D1}\x{7ED3}\x{7B97}\"}",
#  wlzj_type => "{\"1\":\"\x{5BA2}\x{6237}\x{624B}\x{7EED}\x{8D39}\",\"2\":\"\x{5229}\x{606F}\x{6536}\x{5165}\"}",
#  ys_data => {
#    c_user => 1,
#    content => "{\"jd_books\":{\"0\":{\"j_book\":{\"_type\":\"3\",\"bfj_acct\":\"11\",\"zjbd_type\":\"6\",\"zjbd_date\":\"2013-05-05\",\"j\":\"10000\",\"fid\":\"1\"},\"d_book\":{\"_type\":\"1\",\"zyzj_acct\":\"1\",\"zjbd_type\":\"6\",\"zjbd_date\":\"2013-05-06\",\"d\":\"10000\",\"fid\":\"1\"}}},\"cause\":\"\x{7C89}\x{4E1D}\x{53D1}\",\"period\":\"2013-05-06\"}",
#    exam_ts => ,
#    exam_user => ,
#    exstatus => 1,
#    id => 2,
#    ts_c => "2013-05-06 11:06:31",
#    type => 1,
#  },
#  zjbd_type => "{\"6\":\"\x{4E0A}\x{6D77}\x{94F6}\x{8054}\x{4EE3}\x{6536}\x{901A}\x{9053}        \",\"3\":\"\x{519C}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"7\":\"\x{6C11}\x{751F}\x{94F6}\x{8054}\x{4EE3}\x{6536}\x{901A}\x{9053}        \",\"9\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{8D4E}\x{56DE}\x{672C}\x{6253}        \",\"-4\":\"\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}\",\"2\":\"\x{5EFA}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"8\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{4EE3}\x{7ED3}              \",\"4\":\"\x{5149}\x{5927}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"1\":\"\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              \",\"0\":\"\x{5176}\x{4ED6}\",\"-2\":\"\x{8D26}\x{6237}\x{7BA1}\x{7406}\x{8D39}\",\"10\":\"\x{5DE5}\x{884C}\x{76D1}\x{7BA1}\x{8D4E}\x{56DE}\x{5B83}\x{6253}        \",\"5\":\"\x{6E29}\x{5DDE}\x{94F6}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}        \",\"-1\":\"\x{8D26}\x{6237}\x{5229}\x{606F}\",\"-3\":\"\x{8D44}\x{91D1}\x{8C03}\x{62E8}\"}",
#  zyzj_acct => "{\"1\":\"\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010\"}",
#}
sub detail {
    my $self = shift;
    my $data;

    #id
    my $id = $self->param('id');#参数1

    #chinese -bfj_acct/zyzj_acct/zjbd_type
    my $bfj_acct =$self->bfj_acct||{};
    my $zyzj_acct =$self->zyzj_acct||{};
    my $zjbd_type=$self->zjbd_type||{};
    my $wlzj_type=$self->dict->{types}->{wlzj_type}||{};
    my $bi=$self->bi||{};
    my $p=$self->p||{}; 
    my $acct = $self->dict->{types}->{acct}||{};

    $data ->{zjbd_type} = $self->my_decode(encode_json($zjbd_type));
    $data ->{wlzj_type} = $self->my_decode(encode_json($wlzj_type));
    $data ->{zyzj_acct} = $self->my_decode(encode_json($zyzj_acct));
    $data ->{bfj_acct} = $self->my_decode(encode_json($bfj_acct));
    $data ->{bi} = $self->my_decode(encode_json($bi));
    $data ->{p} = $self->my_decode(encode_json($p));
    $data ->{acct} = $self->my_decode(encode_json($acct));

    #详细信息
    my $ex_sql =
        "select id,ys_id,content,status as exstatus,v_user,v_ts,type,c_user,ts_c from verify where id=$id";

    my $ex = $self->select($ex_sql)->[0];
    $ex->{c_user} = $self->usernames->{ $ex->{c_user} } || $ex->{c_user};
    $ex->{content} = $self->my_decode($ex->{content});
    $data->{ys_data} = $ex;
    $self->stash( 'pd', $data );

}

#
#模块名称: 待审核任务的详细 -->凭证撤销
#
#param:id  任务编号
#
#return :hash 数据集 
#{
#  c_user => 1,
#  exstatus => 2,
#  id => 5,
#  period => "2013-05-03",
#  revoke_cause => "ceshi",
#  ts_c => "2013-05-07 17:36:16",
#  type => 2,
#  uri => "/yspzgl/detail?ys_type=0001&id=3",
#}
sub detail_pz {
    my $self = shift;
    my $data;

    #exid
    my $id = $self->param('id') || "";#参数1

    #详细信息
    my $sql =
        "select id,content,status as exstatus,v_user,v_ts,type,c_user,ts_c from verify where id=$id";
    my $recoder = $self->select($sql)->[0];
    
    #my $json    = $recoder->{content};
    my $content = decode_json $recoder->{content};

    my $ys_type      = $content->{ys_type};
    my $ys_id        = $content->{ys_id};
    my $period       = $content->{period};
    my $revoke_cause = $content->{revoke_cause};

    $data->{uri} = "/yspzgl/detail?ys_type=" . $ys_type . "&id=" . $ys_id;
    $data->{revoke_cause} = $revoke_cause;
    $data->{id}           = $id;
    $data->{period}       = $period;
    $data->{exstatus}     = $recoder->{exstatus};
    $data->{type}         = $recoder->{type};
    $data->{c_user}       = $self->usernames->{ $recoder->{c_user} } || $recoder->{c_user};
    $data->{ts_c}         = $recoder->{ts_c};
    $self->stash( 'pd', $data );
}

#
#模块名称: 审核操作
#
#param:  type  任务类型(1加特种调账单;2凭证撤销)
#          
#return 0:审核成功，1:审核失败
sub operate {

    my $self = shift;#参数1
    my $data;
    my $res = -1;

    #id
    my $id = $self->param('id');#参数2
    my $status = $self->param('status');#参数3
    if ( $status == 1 ) {    #审核通过        
        $res = $self->ua->post(
              $self->configure->{svc_url}, encode_json {
                data => {
                    id           => $id,
                },
                svc  => "verify",
                sys  => { oper_user => $self->session->{uid} },
            })->res->json->{status};
    }elsif($status == 2) {                           #审核不通过
        $res = $self->ua->post(
              $self->configure->{svc_url}, encode_json {
                data => {
                    id           => $id,
                },
                svc  => "refuse_verify",
                sys  => { oper_user => $self->session->{uid} },
            })->res->json->{status};
    }
    
    $self->stash( 'pd', $res );
}

1;
