package ZixWeb::BookMgr::Hist::wlzj_yfbf;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant {
    DEBUG  => $ENV{BOOKHISTORY_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  book         => "\x{5F80}\x{6765}-\x{5E94}\x{4ED8}\x{5907}\x{4ED8}",
#  count        => 547,
#  d_from       => undef,
#  d_to         => undef,
#  data         => [
#                    {
#                      d => "1.00",
#                      id => 547,
#                      j => 0,
#                      period => "2013-03-25",
#                      rowid => 1,
#                      ys_id => 701,
#                      ys_type => "0002",
#                    },
#                    ...
#                  ],
#  id           => undef,
#  index        => 1,
#  j_from       => undef,
#  j_to         => undef,
#  next_page    => 2,
#  params       => undef,
#  period_from  => undef,
#  period_to    => undef,
#  prev_page    => 1,
#  total_page   => 28,
#  ys_id        => undef,
#  ys_type      => undef,
#  ys_type_dict => {
#                    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                    ...
#                  },
#}
sub wlzj_yfbf {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'wlzj_yfbf';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    
    for (qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to/) {
        $data->{$_} = $self->param($_);
    }
    $data->{'index'} = $self->param('index') || 1;
    $data->{'ys_type_dict'} = $self->ys_type;
    
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    ys_type => $data->{ys_type}
                      && $self->quote( $data->{ys_type} ),
                    ys_id => $data->{ys_id},
                    j =>
                      [ 0, $data->{j_from}, 'j_from', $data->{j_to}, 'j_to' ],
                    d =>
                      [ 0, $data->{d_from}, 'd_from', $data->{d_to}, 'd_to' ],
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
    "select id, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_$book $p->{condition}";
        my $pager = $self->page_data( $sql, $data->{index} );
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( 'pd' => $data );
}

1;