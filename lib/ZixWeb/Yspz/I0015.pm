package ZixWeb::Yspz::I0015;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Data::Dump qw/dump/;
use JSON::XS;
use boolean;
use URI::Escape;
use Encode qw/encode/;

use constant {
    DEBUG  => $ENV{VOUCHERENTRY_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#    bfj_acct_dict  => {
#                        1 => "\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300023518",
#                        ...
#                      }
#  }
sub i0015 {
    my $self = shift;
    my $res;
    
    my $data = {};
    $data->{_type} = "0015";
    $data->{bfj_bfee} = $self->param('bfj_bfee') * 100;
    $data->{zjhb_amt} = $self->param('zjhb_amt') * 100;
    for (qw/bfj_acct_in bfj_acct_out zjbd_date_in zjbd_date_out memo/) {
        my $p = $self->param($_);
        undef $p if $p eq '';
        $data->{$_} = $p;
    }
    
    $res = $self->ua->post (
        $self->configure->{svc_url}, encode_json {   
            data => $data,
            svc  => "yspz_0015",
            sys  => { oper_user => $self->session->{uid} },
        })->res->json->{status};
    my $result->{success} = false;
    if (defined $res && $res == 0){
        $result->{success} = true;
    }
    $self->render(json => $result);
}


1;
