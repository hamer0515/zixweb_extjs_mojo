package ZixWeb::BookMgr::Hist::lfee_psp;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant { DEBUG => $ENV{BOOKHISTORY_DEBUG} || 0, };

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  bi => undef,
#  bi_dict => {
#    1  => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#    ...
#  },
#  book => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{8D22}\x{52A1}\x{5916}\x{4ED8}\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}",
#  count => 157,
#  d_from => undef,
#  d_to => undef,
#  data => [
#    {
#      bi => "\x{519C}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#      d => "0.60",
#      id => 1,
#      j => 0,
#      period => "2013-03-25",
#      rowid => 1,
#      tx_date => "2013-03-25",
#      ys_id => 1,
#      ys_type => "0002",
#    },
#    ...
#  ],
#  id => undef,
#  index => 1,
#  items => {
#    bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#    tx_date => "\x{4EA4}\x{6613}\x{65E5}\x{671F}",
#  },
#  j_from => undef,
#  j_to => undef,
#  next_page => 2,
#  params => undef,
#  period_from => undef,
#  period_to => undef,
#  prev_page => 1,
#  total_page => 8,
#  tx_date_from => undef,
#  tx_date_to => undef,
#  ys_id => undef,
#  ys_type => undef,
#  ys_type_dict => {
#    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#    ...
#  },
#}
sub lfee_psp {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'lfee_psp';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, [ 'c', 'cust_proto', 'tx_date' ] );
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    c          => $data->{c}&& $self->quote($data->{c}),
                    cust_proto => $data->{cust_proto}&& $self->quote($data->{cust_proto}),
                    tx_date    => [
                        0,
                        $data->{tx_date_from}
                          && $self->quote( $data->{tx_date_from} ),
                        'tx_date_from',
                        $data->{tx_date_to}
                          && $self->quote( $data->{tx_date_to} ),
                        'tx_date_to'
                    ],
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
    "select id, c, cust_proto, tx_date, ys_id, ys_type, j, d, period, rownumber() over() as rowid from book_$book $p->{condition}";
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
#  book => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{8D22}\x{52A1}\x{5916}\x{4ED8}\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}",
#}
# result:
#{
#  bi => undef,
#  bi_dict => {
#    1  => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#    ...
#  },
#  book => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{8D22}\x{52A1}\x{5916}\x{4ED8}\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}",
#  d_from => undef,
#  d_to => undef,
#  id => undef,
#  index => 1,
#  items => {
#    bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#    tx_date => "\x{4EA4}\x{6613}\x{65E5}\x{671F}",
#  },
#  j_from => undef,
#  j_to => undef,
#  period_from => undef,
#  period_to => undef,
#  tx_date_from => undef,
#  tx_date_to => undef,
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

    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data)
      if DEBUG;

    my $dim = shift;
    for (@$dim) {
        if (/tx_date/) {
            $data->{ $_ . '_from' } = $self->param( $_ . '_from' );
            $data->{ $_ . '_to' }   = $self->param( $_ . '_to' );
        }
        else {
            $data->{$_} = $self->param($_);
        }
        $data->{ $_ . '_dict' } = $self->dict->{types}->{$_}
          if $self->dict->{types}->{$_};
        $data->{items}->{$_} = $self->dict->{dim}->{$_};
    }
    for (qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to/) {
        $data->{$_} = $self->param($_);
    }
    $data->{'index'} = $self->param('index') || 1;
    $data->{'ys_type_dict'} = $self->ys_type;

    warn "package: ", __FILE__, "\ndata [after init]:", Data::Dump->dump($data)
      if DEBUG;
}

1;
