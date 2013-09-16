package ZixWeb::BookMgr::Book::wlzj_yfbf;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant {
    DEBUG  => $ENV{BOOK_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  count      => 4,
#  data       => [
#                  { d => "0.60", j => 0, period => "2013-03-24", rowid => 1 },
#                  ...
#                ],
#  header     => [
#                  "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                  ...
#                ],
#  index      => 1,
#  next_page  => 1,
#  params     => "",
#  period     => undef,
#  prev_page  => 1,
#  total_page => 1,
#}
sub wlzj_yfbf {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');
    $data->{params} = '';
    unless ($tag) {
        my $p = $self->params( { period    => [0,
                                $self->quote( $data->{period_from} ),
                                'period_from',
                                $self->quote( $data->{period_to} ),
                                'period_to'],
                                } );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
        my $sql =
    "select period, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_wlzj_yfbf $condition group by period";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        period  => $self->dict->{dim}->{period},
    };
    $data->{header} =
      [ $self->dict->{dim}->{period}, '借方金额', '贷方金额' ];
    $data->{params} .= "&tag=1" if $tag;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;