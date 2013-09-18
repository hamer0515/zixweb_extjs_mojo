package ZixWeb::SourceDocMgr::Y0016;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant {
    DEBUG  => $ENV{SOURCEDOC_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0016 {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $code = '0016';
    $data->{ys_type} = $code;
    $data->{book}    = $code . $self->ys_type->{$code};
    my $fields = [
        'bfj_acct_1',   'bfj_acct_2',   'bfj_acct_3',       'bfj_acct_bj',      'wlzj_type',        'bi','p',
        'cust_proto',   'zjbd_date_in', 'zjbd_date_out_1',  'zjbd_date_out_2',  'zjbd_date_out_3',  'tx_date',
        'bfee','bfee_1','bfee_2',       'bfee_3',           'lfee',             'psp_lfee','cfee',  'psp_amt',
        'c',            'psp_c',        'ssn',              '(bfee+lfee-(bfee_1+bfee_2+bfee_3)) as valid'
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
                    ssn => $data->{ssn} && $self->quote( $data->{ssn} ),
                    bfj_acct_1   => $data->{bfj_acct_1},
                    bfj_acct_2   => $data->{bfj_acct_2},
                    bfj_acct_3   => $data->{bfj_acct_3},
                    bfj_acct_bj  => $data->{bfj_acct_bj},
                    wlzj_type    => $data->{wlzj_type},
                    bi           => $data->{bi},
                    p            => $data->{p},
                    c            => $data->{c}&&$self->quote($data->{c}),
                    psp_c        => $data->{psp_c}&&$self->quote($data->{psp_c}),
                    cust_proto   => $data->{cust_proto}&&$self->quote($data->{cust_proto}),
                    zjbd_date_in => [
                        0,
                        $data->{zjbd_date_in_from}
                          && $self->quote( $data->{zjbd_date_in_from} ),
                        'zjbd_date_in_from',
                        $data->{zjbd_date_in_to}
                          && $self->quote( $data->{zjbd_date_in_to} ),
                        'zjbd_date_in_to'
                    ],
                    zjbd_date_out_1 => [
                        0,
                        $data->{zjbd_date_out_1_from}
                          && $self->quote( $data->{zjbd_date_out_1_from} ),
                        'zjbd_date_out_1_from',
                        $data->{zjbd_date_out_1_to}
                          && $self->quote( $data->{zjbd_date_out_1_to} ),
                        'zjbd_date_out_1_to'
                    ],
                    zjbd_date_out_2 => [
                        0,
                        $data->{zjbd_date_out_2_from}
                          && $self->quote( $data->{zjbd_date_out_2_from} ),
                        'zjbd_date_out_2_from',
                        $data->{zjbd_date_out_2_to}
                          && $self->quote( $data->{zjbd_date_out_2_to} ),
                        'zjbd_date_out_2_to'
                    ],                   
                    zjbd_date_out_3 => [
                        0,
                        $data->{zjbd_date_out_3_from}
                          && $self->quote( $data->{zjbd_date_out_3_from} ),
                        'zjbd_date_out_3_from',
                        $data->{zjbd_date_out_3_to}
                          && $self->quote( $data->{zjbd_date_out_3_to} ),
                        'zjbd_date_out_3_to'
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
                    
                    bfee => [
                        0,           $data->{bfee_from},
                        'bfee_from', $data->{bfee_to},
                        'bfee_to'
                    ],
                    bfee_1 => [
                        0,            $data->{bfee_1_from},
                        'bfee_1_from', $data->{bfee_1_to},
                        'bfee_1_to'
                    ],
                    bfee_2=> [
                        0,            $data->{bfee_2_from},
                        'bfee_2_from', $data->{bfee_2_to},
                        'bfee_2_to'
                    ],
                    bfee_3 => [
                        0,            $data->{bfee_3_from},
                        'bfee_3_from', $data->{bfee_3_to},
                        'bfee_3_to'
                    ],
                    lfee => [
                        0,           $data->{lfee_from},
                        'lfee_from', $data->{lfee_to},
                        'lfee_to'
                    ],
                    psp_lfee => [
                        0,           $data->{psp_lfee_from},
                        'psp_lfee_from', $data->{psp_lfee_to},
                        'psp_lfee_to'
                    ],
                    cfee => [
                        0,           $data->{cfee_from},
                        'cfee_from', $data->{cfee_to},
                        'cfee_to'
                    ],
                    psp_amt => [
                        0,           $data->{psp_amt_from},
                        'psp_amt_from', $data->{psp_amt_to},
                        'psp_amt_to'
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
                    ],
                   '(bfee+lfee)'=> [3,$self->param('valid'),'(bfee_1+bfee_2+bfee_3)'],
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
    $data->{bi_dict} = $self->bi;
    $data->{'p_dict' } = $self->p;
    $data->{bfj_acct_dict} = $self->bfj_acct;
    $data->{items}  = $self->dict->{types}->{ 'yspz_' . $code };
    $data->{valid} = $self->param('valid');
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
