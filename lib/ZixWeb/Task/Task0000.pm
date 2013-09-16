package ZixWeb::Task::Task0000;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;
use boolean;
use URI::Escape;
use constant {
  DEBUG  => $ENV{TASK_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
#模块名称:特种调帐审核任务列表
#
sub list {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $id = $self->param('id');
    
    my $params = {};
    for (qw/c_user from to status/) {
        my $p = $self->param($_);
        $p = undef if $p eq '';
        $params->{$_} = $p;
    }
    
    my $p->{condition} = '';
    if ( $id ) {
        $p = $self->params( { 
                id      => $id,
                type    => 1
                } );
    }
    else {
        $p = $self->params(
            {
                ts_c    => [0, $params->{from} && $self->quote($params->{from}), $params->{to} && $self->quote($params->{to}) ],
                status  => $params->{status},
                c_user  => $params->{c_user} && $self->uids->{$params->{c_user}},
                type    => 1
            }
        );
    }
    
    my $sql =
        "select id, content, c_user, ts_c, status as shstatus, rownumber() over(order by id desc) as rowid from verify $p->{condition}";
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
#模块名称:特种调帐审核任务详细
#
sub detail {
    my $self = shift;
    my $data;

    #id
    my $id = $self->param('id');#参数1

    #详细信息
    my $ex_sql =
        "select id,ys_id,content,status as shstatus,v_user,v_ts,type as shtype,c_user,ts_c from verify where id=$id";

    my $ex = $self->select($ex_sql)->[0];
    $ex->{content} = decode_json $self->my_decode($ex->{content});
    # 从我的任务菜单进入传入readonly参数
    $ex->{rdonly} = $self->param('rdonly');
    for (keys %{$ex->{content}{jd_books}}){
        my $j_book = $ex->{content}{jd_books}{$_}{j_book};
        my $header = $self->configure->{headers}->{$j_book->{_type}};
        for (@$header){
            next unless exists $j_book->{$_};
            my $co = $j_book->{$_};
            if($_ eq "zjbd_type") {
                $j_book->{$_} = $self->zjbd_type->{$co};
            }elsif($_ eq "zyzj_acct"){
                $j_book->{$_} = $self->zyzj_acct->{$co};
            }elsif($_ eq "bfj_acct"){
                $j_book->{$_} = $self->bfj_acct->{$co};
            }elsif($_ eq "wlzj_type"){
                $j_book->{$_} = $self->dict->{types}{wlzj_type}{$co};
            }elsif($_ eq "bi"){
                $j_book->{$_} = $self->bi->{$co};
            }elsif($_ eq "p"){
                $j_book->{$_} = $self->p->{$co};                
            }elsif($_ eq "acct"){
                $j_book->{$_} = $self->dict->{types}{acct}{$co};
            }else{
                $j_book->{$_} = $co || "";
            }
            $j_book->{amt} = $self->nf($j_book->{amt});
        }  
        my $d_book = $ex->{content}{jd_books}{$_}{d_book};
        $header = $self->configure->{headers}->{$d_book->{_type}};
        for (@$header){
            next unless exists $d_book->{$_};
            my $co = $d_book->{$_};
            if($_ eq "zjbd_type") {
                $d_book->{$_} = $self->zjbd_type->{$co};
            }elsif($_ eq "zyzj_acct"){
                $d_book->{$_} = $self->zyzj_acct->{$co};
            }elsif($_ eq "bfj_acct"){
                $d_book->{$_} = $self->bfj_acct->{$co};
            }elsif($_ eq "wlzj_type"){
                $d_book->{$_} = $self->dict->{types}{wlzj_type}{$co};
            }elsif($_ eq "bi"){
                $d_book->{$_} = $self->bi->{$co};
            }elsif($_ eq "p"){
                $d_book->{$_} = $self->p->{$co};                
            }elsif($_ eq "acct"){
                $d_book->{$_} = $self->dict->{types}{acct}{$co};
            }else{
                $d_book->{$_} = $co || "";
            }
            $d_book->{amt} = $self->nf($d_book->{amt});
        } 
    }
        
    $self->render(json => $ex);
}

#
#模块名称: 特种调帐审核任务审核通过
#
sub pass{
    my $self = shift;#参数1
    my $id = $self->param('id');#参数2
    my $result = false;
    my $res = 1;
    $res = $self->ua->post(
              $self->configure->{svc_url}, encode_json {
                data => {
                    id => $id,
                },
                svc  => "verify",
                sys  => { oper_user => $self->session->{uid} },
            })->res->json->{status};
    if ($res == 0){
        $result = true;
    }
    $self->render(json => {success => $result});
}

#
#模块名称: 特种调帐审核任务审核不通过
#
sub deny{
    my $self = shift;#参数1
    my $id = $self->param('id');#参数2
    my $result = false;
    my $res = 1;
    $res = $self->ua->post(
              $self->configure->{svc_url}, encode_json {
                data => {
                    id => $id,
                },
                svc  => "refuse_verify",
                sys  => { oper_user => $self->session->{uid} },
            })->res->json->{status};
    if ($res == 0){
        $result = true;
    }
    $self->render(json => {success => $result});
}


1;
