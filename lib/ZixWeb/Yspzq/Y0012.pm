package ZixWeb::Yspzq::Y0012;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;

use constant {
    DEBUG  => $ENV{SOURCEDOC_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0012 {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $data = {};
    for (qw/id bfj_acct zyzj_acct bfj_zjbd_type zyzj_zjbd_type e_date_bfj_from  e_date_bfj_to zjbd_date_out_bfj_from zjbd_date_out_bfj_to zjbd_date_in_bfj_from zjbd_date_in_bfj_to e_date_zyzj_from e_date_zyzj_to zjbd_date_out_zyzj_from zjbd_date_out_zyzj_to zjbd_date_in_zyzj_from zjbd_date_in_zyzj_to yhys_txamt_from yhys_txamt_to yhyf_txamt_from yhyf_txamt_to yhys_bamt_from yhys_bamt_to yhyf_bamt_from yhyf_bamt_to yhys_bfee_from yhys_bfee_to yhyf_bfee_from yhyf_bfee_to bfj_bsc_from bfj_bsc_to zyzj_bsc_from zyzj_bsc_to flag period_from period_to revoke_user ts_revoke/) {
        $data->{$_} = $self->param($_);
    }
    if ( $data->{revoke_user} ) {
        $data->{revoker} = $self->uids->{ $data->{revoke_user} } || -1;
    }
    if ( $data->{ts_revoke} ) {
        $data->{ts_revoke_from} = $data->{ts_revoke} . ' 00:00:00';
        $data->{ts_revoke_to}   = $data->{ts_revoke} . ' 23:59:59';
    }
    my $p = $self->params(
        {
            period => [
                $self->quote( $data->{period_from} ),
                $self->quote( $data->{period_to} ),
            ],
            status      => 1,
            id          => $data->{id},
            bfj_acct    => $data->{bfj_acct},
            zyzj_acct   => $data->{zyzj_acct},
            bfj_zjbd_type  => $data->{bfj_zjbd_type},
            zyzj_zjbd_type  => $data->{zyzj_zjbd_type},
            e_date_bfj   => [
                0,
                $data->{e_date_bfj_from} && $self->quote( $data->{e_date_bfj_from} ),
                $data->{e_date_bfj_to} && $self->quote( $data->{e_date_bfj_to} )
            ],
            zjbd_date_out_bfj   => [
                0,
                $data->{zjbd_date_out_bfj_from} && $self->quote( $data->{zjbd_date_out_bfj_from} ),
                $data->{zjbd_date_out_bfj_to} && $self->quote( $data->{zjbd_date_out_bfj_to} )
            ],
            zjbd_date_in_bfj   => [
                0,
                $data->{zjbd_date_in_bfj_from} && $self->quote( $data->{zjbd_date_in_bfj_from} ),
                $data->{zjbd_date_in_bfj_to} && $self->quote( $data->{zjbd_date_in_bfj_to} )
            ],
            e_date_zyzj   => [
                0,
                $data->{e_date_zyzj_from} && $self->quote( $data->{e_date_zyzj_from} ),
                $data->{e_date_zyzj_to} && $self->quote( $data->{e_date_zyzj_to} )
            ],
            zjbd_date_out_zyzj   => [
                0,
                $data->{zjbd_date_out_zyzj_from} && $self->quote( $data->{zjbd_date_out_zyzj_from} ),
                $data->{zjbd_date_out_zyzj_to} && $self->quote( $data->{zjbd_date_out_zyzj_to} )
            ],
            zjbd_date_in_zyzj   => [
                0,
                $data->{zjbd_date_in_zyzj_from} && $self->quote( $data->{zjbd_date_in_zyzj_from} ),
                $data->{zjbd_date_in_zyzj_to} && $self->quote( $data->{zjbd_date_in_zyzj_to} )
            ],
            yhys_txamt   => [
                2,
                $data->{yhys_txamt_from} && $self->quote( $data->{yhys_txamt_from} ),
                $data->{yhys_txamt_to} && $self->quote( $data->{yhys_txamt_to} )
            ],
            yhyf_txamt   => [
                2,
                $data->{yhyf_txamt_from} && $self->quote( $data->{yhyf_txamt_from} ),
                $data->{yhyf_txamt_to} && $self->quote( $data->{yhyf_txamt_to} )
            ],
            yhys_bamt   => [
                2,
                $data->{yhys_bamt_from} && $self->quote( $data->{yhys_bamt_from} ),
                $data->{yhys_bamt_to} && $self->quote( $data->{yhys_bamt_to} )
            ],
            yhyf_bamt   => [
                2,
                $data->{yhyf_bamt_from} && $self->quote( $data->{yhyf_bamt_from} ),
                $data->{yhyf_bamt_to} && $self->quote( $data->{yhyf_bamt_to} )
            ],
            yhys_bfee   => [
                2,
                $data->{yhys_bfee_from} && $self->quote( $data->{yhys_bfee_from} ),
                $data->{yhys_bfee_to} && $self->quote( $data->{yhys_bfee_to} )
            ],
            yhyf_bfee   => [
                2,
                $data->{yhyf_bfee_from} && $self->quote( $data->{yhyf_bfee_from} ),
                $data->{yhyf_bfee_to} && $self->quote( $data->{yhyf_bfee_to} )
            ],
            bfj_bsc   => [
                2,
                $data->{bfj_bsc_from} && $self->quote( $data->{bfj_bsc_from} ),
                $data->{bfj_bsc_to} && $self->quote( $data->{bfj_bsc_to} )
            ],
            zyzj_bsc   => [
                2,
                $data->{zyzj_bsc_from} && $self->quote( $data->{zyzj_bsc_from} ),
                $data->{zyzj_bsc_to} && $self->quote( $data->{zyzj_bsc_to} )
            ],
            flag        => $data->{flag},
            revoke_user => $data->{revoker},
            ts_revoke   => [
                0,
                $data->{ts_revoke_from} && $self->quote( $data->{ts_revoke_from} ),
                $data->{ts_revoke_to} && $self->quote( $data->{ts_revoke_to} )
            ]
        }
    );
    my $sql =
        "select id, bfj_acct, zyzj_acct, flag, crt_id, period, rownumber() over(order by id desc) as rowid from yspz_0012 $p->{condition}";
    warn $sql;
    my $pager = $self->page_data( $sql, $page, $limit );

    # id
    for (@{$pager->{data}}){
        $_->{crt_user} = $self->usernames->{ delete $_->{crt_id} } if $_->{crt_id};
    }
    $pager->{success} = true;
    
    $self->render(json => $pager);
}

1;
