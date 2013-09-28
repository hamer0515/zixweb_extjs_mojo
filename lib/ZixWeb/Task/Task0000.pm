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

    my $data = [];
    my $detail = {};
    
    #id
    my $id = $self->param('id');#参数1

    #详细信息
    my $ex_sql =
        "select id as shid, content, status as shstatus, v_user, v_ts,type as shtype, c_user, v_ts, ts_c from verify where id=$id";

    my $ex = $self->select($ex_sql)->[0];
    $ex->{content} = decode_json $self->my_decode($ex->{content});
    $detail->{isdetail} = true;
    $detail->{title} = '0000'.$self->ys_type->{'0000'}."审核信息";
    $detail->{cause} = $ex->{content}{cause};
    $detail->{period} = $ex->{content}{period};
    $detail->{shid} = $ex->{shid};
    $detail->{shstatus} = $ex->{shstatus};
    $detail->{shtype} = $ex->{shtype};
    $detail->{c_user} = $ex->{c_user_name};
    $detail->{ts_c} = $ex->{ts_c};
    $detail->{v_user} = $ex->{v_user_name};
    $detail->{v_ts} = $ex->{v_ts};
    # 从我的任务菜单进入传入readonly参数
    $detail->{rdonly} = $self->param('rdonly');
    
    push @$data, $detail;
    for (keys %{$ex->{content}{jd_books}}){
        my $j_book = $ex->{content}{jd_books}{$_}{j_book};
        my $d_book = $ex->{content}{jd_books}{$_}{d_book};
        my $fl = {};
        $fl->{isdetail} = false;
        $fl->{j_book} = [];
        $fl->{d_book} = [];
        $fl->{title} = '分录'.$_;
        my $property = {};   
        #j_book
        my $jbook_name=$self->dict->{book}->{$j_book->{_type}}->[0];
        # 组成借方科目的表头部分
        $property->{key} = '借方科目';
        $property->{value} = $jbook_name;
        push @{$fl->{j_book}}, $property;
        
        #jbook的核算项
        my $h = $self->configure->{headers}->{$j_book->{_type}};
        for(@$h){
            next unless exists $j_book->{$_}; 
            $property = {};
            $property->{key} = $self->dict->{dim}{$_};      
            my $co = $j_book->{$_};
            if($_ eq "zjbd_type") {
                $property->{value} = $self->zjbd_type->{$co};
            }elsif($_ eq "zyzj_acct"){
                $property->{value} = $self->zyzj_acct->{$co};
            }elsif($_ eq "bfj_acct"){
                $property->{value} = $self->bfj_acct->{$co};
            }elsif($_ eq "wlzj_type"){
                $property->{value} = $self->dict->{types}{wlzj_type}->{$co};
            }elsif($_ eq "p"){
                $property->{value} = $self->p->{$co};
            }elsif($_ eq "bi"){
                $property->{value} = $self->bi->{$co};
            }elsif($_ eq "acct"){
                $property->{value} = $self->dict->{types}{acct}->{$co};
            }
            push @{$fl->{j_book}}, $property if $property;
        }
        $fl->{j_amt} = $self->nf($j_book->{amt});
        #d_book
        $property = {};    
        my $dbook_name    =$self->dict->{book}->{$d_book->{_type}}->[0];
        # 组成贷方科目的表头部分
        $property->{key} = '贷方科目';
        $property->{value} = $dbook_name;
        push @{$fl->{d_book}}, $property;
        #dbook的核算项
        my $h1 = $self->configure->{headers}->{$d_book->{_type}};
        for (@$h1){
            next unless exists $d_book->{$_};
            $property = {};
            $property->{key} = $self->dict->{dim}{$_};
            my $co = $d_book->{$_};
            if($_ eq "zjbd_type") {
                $property->{value} = $self->zjbd_type->{$co};
            }elsif($_ eq "zyzj_acct"){
                $property->{value} = $self->zyzj_acct->{$co};
            }elsif($_ eq "bfj_acct"){
                $property->{value} = $self->bfj_acct->{$co};
            }elsif($_ eq "wlzj_type"){
                $property->{value} = $self->dict->{types}{wlzj_type}{$co};
            }elsif($_ eq "bi"){
                $property->{value} = $self->bi->{$co};
            }elsif($_ eq "p"){
                $property->{value} = $self->p->{$co};                
            }elsif($_ eq "acct"){
                $property->{value} = $self->dict->{types}{acct}{$co};
            } 
            push @{$fl->{d_book}}, $property if $property;        
        }
        $fl->{d_amt} = $self->nf($d_book->{amt});
        push @$data, $fl;    
    }
    $self->render(json => $data);
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
