package ZixWeb::SourceDocMgr::Y0046;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant { DEBUG => $ENV{SOURCEDOC_DEBUG} || 0, };

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0046 {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $code = '0046';
    $data->{ys_type} = $code;
    $data->{book}    = $code . $self->ys_type->{$code};
    my $fields = [
        'bi',          'tx_type',     'wlzj_type',   'p',
        'tx_date',     'ssn',         'c',           'wqr_c',
        'cust_proto',  'bfee_1',      'bfee_2',      'bfee_3',
        'cwwf_bfee_1', 'cwwf_bfee_2', 'cwwf_bfee_3', 'zg_bfee_1',
        'zg_bfee_2',   'zg_bfee_3',   'cfee',        'cwws_cfee',
        'tx_amt',      'fp'
    ];
    $self->init( $data, $fields );
    my $p->{condition} = 'where status = 1';

    unless ($tag) {
        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id}, status => 1 } );
        }
        else {
            $p = $self->params(
                {
                    bi         => $data->{bi},
                    tx_type    => $data->{tx_type},
                    wlzj_type  => $data->{wlzj_type},
                    p          => $data->{p},
                    fp         => $data->{fp}&&$self->quote($data->{fp}),
                    ssn        => $data->{ssn}&& $self->quote( $data->{ssn}),
                    c          => $data->{c}&&$self->quote($data->{c}),
                    wqr_c      => $data->{wqr_c}&&$self->quote($data->{wqr_c}),
                    cust_proto => $data->{cust_proto},
                    tx_date    => [
                        0,
                        $data->{tx_date_from}
                          && $self->quote( $data->{tx_date_from} ),
                        'tx_date_from',
                        $data->{tx_date_to}
                          && $self->quote( $data->{tx_date_to} ),
                        'tx_date_to'
                    ],
                    bfee_1 => [
                        0,             $data->{bfee_1_from},
                        'bfee_1_from', $data->{bfee_1_to},
                        'bfee_1_to'
                    ],
                    bfee_2 => [
                        0,             $data->{bfee_2_from},
                        'bfee_2_from', $data->{bfee_2_to},
                        'bfee_2_to'
                    ],
                    bfee_3 => [
                        0,             $data->{bfee_3_from},
                        'bfee_3_from', $data->{bfee_3_to},
                        'bfee_3_to'
                    ],
                    cwwf_bfee_1 => [
                        0,                  $data->{cwwf_bfee_1_from},
                        'cwwf_bfee_1_from', $data->{cwwf_bfee_1_to},
                        'cwwf_bfee_1_to'
                    ],
                    cwwf_bfee_2 => [
                        0,                  $data->{cwwf_bfee_2_from},
                        'cwwf_bfee_2_from', $data->{cwwf_bfee_2_to},
                        'cwwf_bfee_2_to'
                    ],
                    cwwf_bfee_3 => [
                        0,                  $data->{cwwf_bfee_3_from},
                        'cwwf_bfee_3_from', $data->{cwwf_bfee_3_to},
                        'cwwf_bfee_3_to'
                    ],
                    zg_bfee_1 => [
                        0,                $data->{zg_bfee_1_from},
                        'zg_bfee_1_from', $data->{zg_bfee_1_to},
                        'zg_bfee_1_to'
                    ],
                    zg_bfee_2 => [
                        0,                $data->{zg_bfee_2_from},
                        'zg_bfee_2_from', $data->{zg_bfee_2_to},
                        'zg_bfee_2_to'
                    ],
                    zg_bfee_3 => [
                        0,                $data->{zg_bfee_3_from},
                        'zg_bfee_3_from', $data->{zg_bfee_3_to},
                        'zg_bfee_3_to'
                    ],
                    cfee => [
                        0,           $data->{cfee_from},
                        'cfee_from', $data->{cfee_to},
                        'cfee_to'
                    ],
                    cwws_cfee => [
                        0,                $data->{cwws_cfee_from},
                        'cwws_cfee_from', $data->{cwws_cfee_to},
                        'cwws_cfee_to'
                    ],
                    tx_amt => [
                        0,             $data->{tx_amt_from},
                        'tx_amt_from', $data->{tx_amt_to},
                        'tx_amt_to'
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
        %$data = ( %$data, %$pager );
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    $data->{bi_dict} = $self->bi;
    $data->{p_dict} = $self->p;
    $data->{items}  = $self->dict->{types}->{ 'yspz_' . $code };
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
            $data->{items}{$_} = $dict->{dim}{$_};
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
