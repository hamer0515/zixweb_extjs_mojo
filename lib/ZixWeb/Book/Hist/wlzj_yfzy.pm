package ZixWeb::Book::Hist::wlzj_yfzy;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;
use JSON::XS;

use constant {
    DEBUG  => $ENV{BOOKHISTORY_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  wlzj_type      => undef,
#  wlzj_type_dict => {
#                     1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                     ...
#                   },
#  book          => "\x{94F6}\x{884C}\x{5B58}\x{6B3E}-\x{5907}\x{4ED8}\x{91D1}\x{5B58}\x{6B3E}",
#  count         => 2,
#  d_from        => undef,
#  d_to          => undef,
#  data          => [
#                     {
#                       wlzj_type => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                       d => 0,
#                       id => 2,
#                       j => "65,8063.28",
#                       period => "2013-03-25",
#                       rowid => 1,
#                       ys_id => 2,
#                       ys_type => "0010",
#                     },
#                     ...
#                   ],
#  id            => undef,
#  index         => 1,
#  items         => { wlzj_type => "\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}id" },
#  j_from        => undef,
#  j_to          => undef,
#  next_page     => 1,
#  params        => undef,
#  period_from   => undef,
#  period_to     => undef,
#  prev_page     => 1,
#  total_page    => 1,
#  ys_id         => undef,
#  ys_type       => undef,
#  ys_type_dict  => {
#                     "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                     ...
#                   },
#}
sub wlzj_yfzy {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $id = $self->param('id');
    my $params = {};
    for (qw/ys_type ys_id j_from j_to d_from d_to period_from period_to wlzj_type/) {
        my $p = $self->param($_);
        undef $p if $p eq '';
        $params->{$_} = $p;
    }
    my $p->{condition} = '';
    $p = $self->params(
        {
            id => $id,
            wlzj_type => $params->{wlzj_type},
            ys_type  => $params->{ys_type}
              && $self->quote( $params->{ys_type} ),
            ys_id => $params->{ys_id},
            j =>
              [ 0, $params->{j_from}, $params->{j_to} ],
            d =>
              [ 0, $params->{d_from}, $params->{d_to} ],
            period => [
                $self->quote( $params->{period_from} ),
                $self->quote( $params->{period_to} ),
            ]
        }
    );
    my $sql =
"select id, wlzj_type, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_wlzj_yfzy $p->{condition}";
    my $data = $self->page_data( $sql, $page, $limit );
    $data->{success} = true;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->render(json => $data);
}

1;
