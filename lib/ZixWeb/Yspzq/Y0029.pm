package ZixWeb::Yspzq::Y0029;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;

use constant {
    DEBUG  => $ENV{SOURCEDOC_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub y0029 {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $data = {};
    for (qw/id bi bfj_acct_bj p c flag period_from period_to revoke_user ts_revoke/) {
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
            bi          => $data->{bi},
            bfj_acct_bj => $data->{bfj_acct_bj},
            p           => $data->{p},
            c           => $data->{c},
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
        "select id, bfj_acct_bj, tx_amt, flag, period, rownumber() over(order by id desc) as rowid from yspz_0029 $p->{condition}";

    my $pager = $self->page_data( $sql, $page, $limit );

    $pager->{success} = true;
    
    $self->render(json => $pager);
}

1;