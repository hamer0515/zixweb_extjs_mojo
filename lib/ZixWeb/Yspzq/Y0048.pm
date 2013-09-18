package ZixWeb::SourceDocMgr::Y0048;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant { DEBUG => $ENV{SOURCEDOC_DEBUG} || 0, };

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0048 {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $code = '0048';
    $data->{ys_type} = $code;
    $data->{book}    = $code . $self->ys_type->{$code};
    my $fields = [
        'bfj_acct_bj',      'bfj_acct_1',
        'bfj_acct_2',       'bfj_acct_3',
        'bi',               'tx_type',
        'p',                'fp',
        'zjbd_date_out',    'zjbd_date_in_1',
        'zjbd_date_in_2',   'zjbd_date_in_3',
        'tx_date',          'ssn',
        'wqr_c',             'bfee_1_back',
        'bfee_2_back',      'bfee_3_back',
        'cwwf_bfee_1_back', 'cwwf_bfee_2_back',
        'cwwf_bfee_3_back', 'zg_bfee_1_back',
        'zg_bfee_2_back',   'zg_bfee_3_back',
        'tx_amt'
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
                    bfj_acct_bj   => $data->{bfj_acct_bj},
                    bfj_acct_1    => $data->{bfj_acct_1},
                    bfj_acct_2    => $data->{bfj_acct_2},
                    bfj_acct_3    => $data->{bfj_acct_3},
                    bi            => $data->{bi},
                    tx_type       => $data->{tx_type},
                    fp            => $data->{fp},
                    p             => $data->{p},
                    ssn           => $data->{ssn}&& $self->quote( $data->{ssn}),
                    wqr_c         => $data->{wqr_c}&&$self->quote($data->{wqr_c}),
                    zjbd_date_out => [
                        0,
                        $data->{zjbd_date_out_from}
                          && $self->quote( $data->{zjbd_date_out_from} ),
                        'zjbd_date_out_from',
                        $data->{zjbd_date_out_to}
                          && $self->quote( $data->{zjbd_date_out_to} ),
                        'zjbd_date_out_to'
                    ],
                    zjbd_date_in_1 => [
                        0,
                        $data->{zjbd_date_in_1_from}
                          && $self->quote( $data->{zjbd_date_in_1_from} ),
                        'zjbd_date_in_1_from',
                        $data->{zjbd_date_in_1_to}
                          && $self->quote( $data->{zjbd_date_in_1_to} ),
                        'zjbd_date_in_1_to'
                    ],
                    zjbd_date_in_2 => [
                        0,
                        $data->{zjbd_date_in_2_from}
                          && $self->quote( $data->{zjbd_date_in_2_from} ),
                        'zjbd_date_in_2_from',
                        $data->{zjbd_date_in_2_to}
                          && $self->quote( $data->{zjbd_date_in_2_to} ),
                        'zjbd_date_in_2_to'
                    ],
                    zjbd_date_in_3 => [
                        0,
                        $data->{zjbd_date_in_3_from}
                          && $self->quote( $data->{zjbd_date_in_3_from} ),
                        'zjbd_date_in_3_from',
                        $data->{zjbd_date_in_3_to}
                          && $self->quote( $data->{zjbd_date_in_3_to} ),
                        'zjbd_date_in_3_to'
                    ],
                    tx_date => [
                        0,
                        $data->{tx_date_from}
                          && $self->quote( $data->{tx_date_from} ),
                        'tx_date_from',
                        $data->{tx_date_to}
                          && $self->quote( $data->{tx_date_to} ),
                        'tx_date_to'
                    ],
                    bfee_1_back => [
                        0,                  $data->{bfee_1_back_from},
                        'bfee_1_back_from', $data->{bfee_1_back_to},
                        'bfee_1_back_to'
                    ],
                    bfee_2_back => [
                        0,                  $data->{bfee_2_back_from},
                        'bfee_2_back_from', $data->{bfee_2_back_to},
                        'bfee_2_back_to'
                    ],
                    bfee_3_back => [
                        0,                  $data->{bfee_3_back_from},
                        'bfee_3_back_from', $data->{bfee_3_back_to},
                        'bfee_3_back_to'
                    ],
                    cwwf_bfee_1_back => [
                        0,
                        $data->{cwwf_bfee_1_back_from},
                        'cwwf_bfee_1_back_from',
                        $data->{cwwf_bfee_1_back_to},
                        'cwwf_bfee_1_back_to'
                    ],
                    cwwf_bfee_2_back => [
                        0,
                        $data->{cwwf_bfee_2_back_from},
                        'cwwf_bfee_2_back_from',
                        $data->{cwwf_bfee_2_back_to},
                        'cwwf_bfee_2_back_to'
                    ],
                    cwwf_bfee_3_back => [
                        0,
                        $data->{cwwf_bfee_3_back_from},
                        'cwwf_bfee_3_back_from',
                        $data->{cwwf_bfee_3_back_to},
                        'cwwf_bfee_3_back_to'
                    ],
                    zg_bfee_1_back => [
                        0,                     $data->{zg_bfee_1_back_from},
                        'zg_bfee_1_back_from', $data->{zg_bfee_1_back_to},
                        'zg_bfee_1_back_to'
                    ],
                    zg_bfee_2_back => [
                        0,                     $data->{zg_bfee_2_back_from},
                        'zg_bfee_2_back_from', $data->{zg_bfee_2_back_to},
                        'zg_bfee_2_back_to'
                    ],
                    zg_bfee_3_back => [
                        0,                     $data->{zg_bfee_3_back_from},
                        'zg_bfee_3_back_from', $data->{zg_bfee_3_back_to},
                        'zg_bfee_3_back_to'
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
    $data->{bfj_acct_dict}            = $self->bfj_acct;
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
