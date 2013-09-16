package ZixWeb::BookMgr::Hist::bfee_zqqr_zg;

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
#  book => "\x{6210}\x{672C}-\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}\x{652F}\x{51FA}",
#  c => undef,
#  count => 700,
#  d_from => undef,
#  d_to => undef,
#  data => [
#    {
#      bi => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#      c => 51.20121114018,
#      d => 0,
#      id => 1,
#      j => "1.00",
#      p => "\x{57FA}\x{91D1}\x{6536}\x{6B3E}",
#      period => "2013-03-25",
#      rowid => 1,
#      ys_id => 4,
#      ys_type => "0002",
#    },
#    ...
#  ],
#  id => undef,
#  index => 1,
#  items => {
#    bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#    c  => "\x{5BA2}\x{6237}id",
#    p  => "\x{4EA7}\x{54C1}id",
#  },
#  j_from => undef,
#  j_to => undef,
#  next_page => 2,
#  p => undef,
#  p_dict => {
#    1 => "\x{57FA}\x{91D1}\x{6536}\x{6B3E}",
#    ...
#  },
#  params => undef,
#  period_from => undef,
#  period_to => undef,
#  prev_page => 1,
#  total_page => 35,
#  ys_id => undef,
#  ys_type => undef,
#  ys_type_dict => {
#    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#    ...
#  },
#}
sub bfee_zqqr_zg {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'bfee_zqqr_zg';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, [ 'c', 'p', 'bi', 'fp', 'tx_date' ] );
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    p       => $data->{p},
                    bi      => $data->{bi},
                    fp      => $data->{fp},
                    tx_date => [
                        0,
                        $data->{tx_date_from}
                          && $self->quote( $data->{tx_date_from} ),
                        'tx_date_from',
                        $data->{tx_date_to}
                          && $self->quote( $data->{tx_date_to} ),
                        'tx_date_to'
                    ],

                    c => $data->{c} && $self->quote( $data->{c} ),
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
    "select id, c, p, bi,fp,tx_date, ys_id, ys_type, j, d, period, rownumber() over() as rowid from book_$book $p->{condition}";
        my $pager = $self->page_data( $sql, $data->{index} );
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    $data->{bi_dict} = $self->bi;
    $data->{'p_dict' } = $self->p;

    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;

    $self->stash( 'pd' => $data );
}

# input:
#{
#  book => "\x{6210}\x{672C}-\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}\x{652F}\x{51FA}",
#}
# result:
#{
#  bi => undef,
#  bi_dict => {
#    1  => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#    ...
#  },
#  book => "\x{6210}\x{672C}-\x{94F6}\x{884C}\x{624B}\x{7EED}\x{8D39}\x{652F}\x{51FA}",
#  c => undef,
#  d_from => undef,
#  d_to => undef,
#  id => undef,
#  index => 1,
#  items => {
#    bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#    c  => "\x{5BA2}\x{6237}id",
#    p  => "\x{4EA7}\x{54C1}id",
#  },
#  j_from => undef,
#  j_to => undef,
#  p => undef,
#  p_dict => {
#    1 => "\x{57FA}\x{91D1}\x{6536}\x{6B3E}",
#    ...
#  },
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

    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data)
      if DEBUG;

    my $dim = shift;
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

    warn "package: ", __FILE__, "\ndata [after init]:", Data::Dump->dump($data)
      if DEBUG;
}

1;
