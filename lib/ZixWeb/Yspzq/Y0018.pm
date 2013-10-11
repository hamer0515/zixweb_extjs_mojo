package ZixWeb::Yspzq::Y0018;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;
use boolean;
use URI::Escape;
use Data::Dump;

use constant { DEBUG => $ENV{SOURCEDOC_DEBUG} || 0, };

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0018 {
    my $self = shift;

    my $page  = $self->param('page');
    my $limit = $self->param('limit');

    my $data = {};

    for (qw/ bfj_acct_bj zjbd_type zjbd_date_in_to zjbd_date_in_from c tx_amt_from tx_amt_to/)
    {
        $data->{$_} = $self->param($_);
    }

    for (qw/id flag period_from period_to revoke_user ts_revoke/) {
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
            bfj_acct_bj => $data->{bfj_acct_bj},
            zjbd_type   => $data->{zjbd_type},
            c           => $data->{c}
              && $self->quote( $data->{c} ),
            zjbd_date_in => [
                0,
                $data->{zjbd_date_in_from}
                  && $self->quote( $data->{zjbd_date_in_from} ),
                $data->{zjbd_date_in_to}
                  && $self->quote( $data->{zjbd_date_in_to} )
            ],
            tx_amt => [
                0,
                $data->{tx_amt_from} && $self->quote( $data->{tx_amt_from} ),
                $data->{tx_amt_to} && $self->quote( $data->{tx_amt_to} )
            ],

            period => [
                $self->quote( $data->{period_from} ),
                $self->quote( $data->{period_to} )
            ],
            status      => 1,
            id          => $data->{id},
            flag        => $data->{flag},
            revoke_user => $data->{revoker},
            ts_revoke   => [
                0,
                $data->{ts_revoke_from}
                  && $self->quote( $data->{ts_revoke_from} ),
                $data->{ts_revoke_to} && $self->quote( $data->{ts_revoke_to} )
            ]
        }
    );

    my $sql =
"select id, zjbd_date_in,  flag,  period, rownumber() over(order by id desc) as rowid from yspz_0018 $p->{condition}";

    # print "$sql>>>>>>>\n";
    my $pager = $self->page_data( $sql, $page, $limit );
    
    $pager->{success} = true;

    $self->render( json => $pager );
}

1;
