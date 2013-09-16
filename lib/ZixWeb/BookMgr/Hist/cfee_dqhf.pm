package ZixWeb::BookMgr::Hist::cfee_dqhf;

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
#  book         => "\x{5E94}\x{6536}\x{8D26}\x{6B3E}-\x{5BA2}\x{6237}-\x{5B9A}\x{671F}\x{5212}\x{4ED8}\x{5BA2}\x{6237}\x{624B}\x{7EED}\x{8D39}",
#  c            => undef,
#  count        => 731,
#  cust_proto   => undef,
#  d_from       => undef,
#  d_to         => undef,
#  data         => [
#                    {
#                      c => "51.c1",
#                      cust_proto => "3_c1",
#                      d => 0,
#                      id => 1,
#                      j => "1.00",
#                      period => "2013-05-05",
#                      rowid => 1,
#                      ys_id => 1,
#                      ys_type => "0009",
#                    },
#                    ...
#                  ],
#  id           => undef,
#  index        => 1,
#  items        => {
#                    c => "\x{5BA2}\x{6237}id",
#                    cust_proto => "\x{5BA2}\x{6237}\x{534F}\x{8BAE}",
#                  },
#  j_from       => undef,
#  j_to         => undef,
#  next_page    => 2,
#  params       => undef,
#  period_from  => undef,
#  period_to    => undef,
#  prev_page    => 1,
#  total_page   => 37,
#  ys_id        => undef,
#  ys_type      => undef,
#  ys_type_dict => {
#                    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                    ...
#                  },
#}
sub cfee_dqhf {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'cfee_dqhf';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, [ 'c', 'cust_proto' ] );
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    cust_proto => $data->{cust_proto}&& $self->quote($data->{cust_proto}) ,
                    c          => $data->{c} && $self->quote( $data->{c} ),
                    ys_type    => $data->{ys_type}
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
    "select id, c, cust_proto, ys_id, ys_type, j, d, period, rownumber() over() as rowid from book_$book $p->{condition}";
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
# input:
#{
#  book => "\x{5E94}\x{6536}\x{8D26}\x{6B3E}-\x{5BA2}\x{6237}-\x{5B9A}\x{671F}\x{5212}\x{4ED8}\x{5BA2}\x{6237}\x{624B}\x{7EED}\x{8D39}",
#}
# result:
#{
#  book => "\x{5E94}\x{6536}\x{8D26}\x{6B3E}-\x{5BA2}\x{6237}-\x{5B9A}\x{671F}\x{5212}\x{4ED8}\x{5BA2}\x{6237}\x{624B}\x{7EED}\x{8D39}",
#  c => undef,
#  cust_proto => undef,
#  d_from => undef,
#  d_to => undef,
#  id => undef,
#  index => 1,
#  items => {
#    c => "\x{5BA2}\x{6237}id",
#    cust_proto => "\x{5BA2}\x{6237}\x{534F}\x{8BAE}",
#  },
#  j_from => undef,
#  j_to => undef,
#  period_from => undef,
#  period_to => undef,
#  ys_id => undef,
#  ys_type => undef,
#  ys_type_dict => {
#    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#    ...
#  },
#}
sub init {
    my $self = shift;
    my $data = shift;
    
    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data) if DEBUG;
    
    my $dim  = shift;
    for (@$dim) {
        $data->{$_} = $self->param($_);
        $data->{ $_ . '_dict' } = $self->dict->{types}->{$_}
          if $self->dict->{types}->{$_};
        $data->{items}->{$_} = $self->dict->{dim}->{$_};
    }
    for (qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to/) {
        $data->{$_} = $self->param($_);
    }
    $data->{'index'} = $self->param('index') || 1;
    $data->{'ys_type_dict'} = $self->ys_type;
    
    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data) if DEBUG;
}

1;