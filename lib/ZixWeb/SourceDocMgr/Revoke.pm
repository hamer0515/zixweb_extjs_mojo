package ZixWeb::SourceDocMgr::Revoke;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;
use boolean;
use URI::Escape;

use constant {
  DEBUG  => $ENV{SOURCEDOC_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
#模块名称:原始凭证撤销
#
#param: ys_type 原始凭证类型
#       ys_id 原始凭证id
#       revoke_cause 撤销原因
#       period 会计期间
#
#return :hash数据集{"0"=>撤销提交成功或失败,"1"=>该原始凭证的类型（用于刷新父页面）}
#      {"0"=>0,"1"=>1}
#

sub revoke {
    my $self     = shift;
    my $ys_type         = $self->param('ys_type');#参数1
    my $ys_id           = $self->param('ys_id');#参数3
    my $period          = $self->param('period');#参数4
    my $revoke_cause    = $self->param('revoke_cause');#参数2
    
    my $uid      = $self->session->{uid};
    
    my $res={};

    my $data = {
        'ys_type'      => $ys_type,
        'ys_id'        => $ys_id,
        'rk_user'      => $uid,
        'period'       => $period,
        'revoke_cause' => $revoke_cause,
    };

    my $res = $self->ua->post (
        $self->configure->{svc_url}, encode_json {
            data => {
                type    => 2,         # 审核类型（1.特种调账单  2.凭证撤销）
                content => $data,
            },
            svc  => "add_verify",
            sys  => { oper_user => $uid },
        })->res->json->{status};
    my $result = false;
    $result = true if $res == 0;
    $self->render(json => {success => $result});
}

1;
