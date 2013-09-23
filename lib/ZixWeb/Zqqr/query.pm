package ZixWeb::Zqqr::query;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;
use JSON::XS;

use constant {
    DEBUG  => $ENV{ZQQR_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub query {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $params = {};
    for (qw/sm_date status/) {
        my $p = $self->param($_);
        undef $p if $p eq '';
        $params->{$_} = $p;
    }
    my $p->{condition} = '';
    
    $p = $self->params(
        {
            sm_date     => $params->{sm_date} && $self->quote($params->{sm_date}),
            status      => $params->{status},
        }
    );

    my $sql =
"select id, sm_date, status as zqqrstatus, rownumber() over(order by sm_date desc, status asc) as rowid from pack_mission $p->{condition}";
    my $data = $self->page_data( $sql, $page, $limit );
    $data->{success} = true;
   
    $self->render(json => $data);
}

1;
