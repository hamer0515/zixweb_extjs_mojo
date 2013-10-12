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
    for (qw/id flag period_from period_to /) {
        $data->{$_} = $self->param($_);
    }
    
    my $p = $self->params(
        {
            period => [
                $self->quote( $data->{period_from} ),
                $self->quote( $data->{period_to} ),
            ],
            status      => 1,
            id          => $data->{id},
            flag        => $data->{flag},
        }
    );
    my $sql =
        "select id, flag, period, rownumber() over(order by id desc) as rowid from yspz_0012 $p->{condition}";
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
