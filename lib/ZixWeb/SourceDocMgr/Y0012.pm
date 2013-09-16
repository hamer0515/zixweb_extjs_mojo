package ZixWeb::SourceDocMgr::Y0012;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant {
    DEBUG  => $ENV{SOURCEDOC_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0012 {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $code = '0012';
    $data->{ys_type} = $code;
    $data->{book}    = $code . $self->ys_type->{$code};
    my $fields = [
        'bfj_acct',          'zyzj_acct',
        'bfj_zjbd_type',     'zyzj_zjbd_type',
                             'zjbd_date_out_bfj',
        'zjbd_date_in_bfj',  'e_date_bfj',
        'zjbd_date_in_zyzj', 'zjbd_date_out_zyzj',
        'e_date_zyzj',       'yhys_txamt',
        'yhys_bamt',         'yhys_bfee',
        'yhyf_txamt',        'yhyf_bamt',
        'yhyf_bfee',         'bfj_bsc',
        'zyzj_bsc'
    ];
    $self->init( $data, $fields );
    my $p->{condition} = 'where status = 1';

    unless ($tag) {
        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id}, status => 1} );
        }
        else {
            $p = $self->params(
                {
                    bfj_acct          => $data->{bfj_acct},
                    zyzj_acct         => $data->{zyzj_acct},
                    bfj_zjbd_type     => $data->{bfj_zjbd_type},
                    zyzj_zjbd_type    => $data->{zyzj_zjbd_type},
                    cust_proto        => $data->{cust_proto},
                    zjbd_date_out_bfj => [
                        0,
                        $data->{zjbd_date_out_bfj_from}
                          && $self->quote( $data->{zjbd_date_out_bfj_from} ),
                        'zjbd_date_out_bfj_from',
                        $data->{zjbd_date_out_bfj_to}
                          && $self->quote( $data->{zjbd_date_out_bfj_to} ),
                        'zjbd_date_out_bfj_to'
                    ],
                    zjbd_date_in_bfj => [
                        0,
                        $data->{zjbd_date_in_bfj_from}
                          && $self->quote( $data->{zjbd_date_in_bfj_from} ),
                        'zjbd_date_in_bfj_from',
                        $data->{zjbd_date_in_bfj_to}
                          && $self->quote( $data->{zjbd_date_in_bfj_to} ),
                        'zjbd_date_in_bfj_to'
                    ],
                    e_date_bfj => [
                        0,
                        $data->{e_date_bfj_from}
                          && $self->quote( $data->{e_date_bfj_from} ),
                        'e_date_bfj_from',
                        $data->{e_date_bfj_to}
                          && $self->quote( $data->{e_date_bfj_to} ),
                        'e_date_bfj_to'
                    ],
                    zjbd_date_out_zyzj => [
                        0,
                        $data->{zjbd_date_out_zyzj_from}
                          && $self->quote( $data->{zjbd_date_out_zyzj_from} ),
                        'zjbd_date_out_zyzj_from',
                        $data->{zjbd_date_out_zyzj_to}
                          && $self->quote( $data->{zjbd_date_out_zyzj_to} ),
                        'zjbd_date_out_zyzj_to'
                    ],
                    zjbd_date_in_zyzj => [
                        0,
                        $data->{zjbd_date_in_zyzj_from}
                          && $self->quote( $data->{zjbd_date_in_zyzj_from} ),
                        'zjbd_date_in_zyzj_from',
                        $data->{zjbd_date_in_zyzj_to}
                          && $self->quote( $data->{zjbd_date_in_zyzj_to} ),
                        'zjbd_date_in_zyzj_to'
                    ],
                    e_date_zyzj => [
                        0,
                        $data->{e_date_zyzj_from}
                          && $self->quote( $data->{e_date_zyzj_from} ),
                        'e_date_zyzj_from',
                        $data->{e_date_zyzj_to}
                          && $self->quote( $data->{e_date_zyzj_to} ),
                        'e_date_zyzj_to'
                    ],
                    yhys_txamt => [
                        0,                 $data->{yhys_txamt_from},
                        'yhys_txamt_from', $data->{yhys_txamt_to},
                        'yhys_txamt_to'
                    ],
                    yhys_bamt => [
                        0,                $data->{yhys_bamt_from},
                        'yhys_bamt_from', $data->{yhys_bamt_to},
                        'yhys_bamt_to'
                    ],
                    yhys_bfee => [
                        0,                $data->{yhys_bfee_from},
                        'yhys_bfee_from', $data->{yhys_bfee_to},
                        'yhys_bfee_to'
                    ],
                    yhyf_txamt => [
                        0,                 $data->{yhyf_txamt_from},
                        'yhyf_txamt_from', $data->{yhyf_txamt_to},
                        'yhyf_txamt_to'
                    ],
                    yhyf_bamt => [
                        0,                $data->{yhyf_bamt_from},
                        'yhyf_bamt_from', $data->{yhyf_bamt_to},
                        'yhyf_bamt_to'
                    ],
                    yhyf_bfee => [
                        0,                $data->{yhyf_bfee_from},
                        'yhyf_bfee_from', $data->{yhyf_bfee_to},
                        'yhyf_bfee_to'
                    ],
                    bfj_bsc => [
                        0,              $data->{bfj_bsc_from},
                        'bfj_bsc_from', $data->{bfj_bsc_to},
                        'bfj_bsc_to'
                    ],
                    zyzj_bsc => [
                        0,               $data->{zyzj_bsc_from},
                        'zyzj_bsc_from', $data->{zyzj_bsc_to},
                        'zyzj_bsc_to'
                    ],
                    status      => 1,
                    flag        => $data->{flag},
                    revoke_user => [
                        1,                'revoke_user',
                        $data->{revoker}, $data->{revoke_user}
                    ],
                    ts_revoke => [
                        2,
                        $data->{ts_revoke_from}
                          && $self->quote( $data->{ts_revoke_from} ),
                        $data->{ts_revoke_to}
                          && $self->quote( $data->{ts_revoke_to} ),
                        'ts_revoke',
                        $data->{ts_revoke}
                    ],
                    period => [
                        0,
                        $self->quote( $data->{period_from} ),
                        'period_from',
                        $self->quote( $data->{period_to} ),
                        'period_to'
                    ]
                }
            );
        }
        my $sql =
            "select id, "
          . join( ', ', @$fields )
          . ", flag, revoke_user, ts_revoke, period, rownumber() over(order by id desc) as rowid from yspz_$code $p->{condition}";
        my $pager = $self->page_data( $sql, $data->{index} );
        %$data=(%$data, %$pager);
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    $data->{zyzj_acct_dict} = $self->zyzj_acct;
    $data->{bfj_acct_dict} = $self->bfj_acct;
    $data->{items}  = $self->dict->{types}->{ 'yspz_' . $code };
    $data->{zjbd_type_dict} = $self->zjbd_type;
    $self->stash( 'pd' => $data );
}

sub init {
    my $self = shift;
    my $data = shift;
    my $dim  = shift;
    my $dict = $self->dict;
    
    for (@$dim) {
        if ( exists $dict->{types}{range_fields}{$_} )
        {
            $data->{ $_ . '_from' } = $self->param( $_ . '_from' );
            $data->{ $_ . '_to' }   = $self->param( $_ . '_to' );
        }
        else {
            $data->{$_} = $self->param($_);
            $data->{ $_ . '_dict' } = $dict->{types}{$_}
              if $dict->{types}{$_};
            $data->{items}->{$_} = $dict->{dim}{$_};
        }
    }
    for (qw/id flag period_from period_to revoke_user ts_revoke/) {
        $data->{$_} = $self->param($_);
    }
    if ( $data->{revoke_user} ) {
        #my $u =
#         $self->select( "select user_id from tbl_user_inf where username="
#              . $self->quote( $data->{revoke_user} ) );
#        $data->{revoker} = $u->[0]{user_id};
        $data->{revoker} = $self->uids->{ $data->{revoke_user} } || -1;
    }
    if ( $data->{ts_revoke} ) {
        $data->{ts_revoke_from} = $data->{ts_revoke} . ' 00:00:00';
        $data->{ts_revoke_to}   = $data->{ts_revoke} . ' 23:59:59';
    }
    $data->{'index'} = $self->param('index') || 1;
    $data->{ys_type_dict} = $dict->{types}{ys_type};
    $data->{flag_dict}    = $dict->{types}{flag};
}

1;