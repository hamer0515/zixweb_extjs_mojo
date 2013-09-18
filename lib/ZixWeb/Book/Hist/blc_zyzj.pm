package ZixWeb::BookMgr::Hist::blc_zyzj;

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
#  book           => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{94F6}\x{884C}\x{957F}\x{6B3E}",
#  count          => 0,
#  d_from         => undef,
#  d_to           => undef,
#  data           => [...],
#  e_date_from    => undef,
#  e_date_to      => undef,
#  id             => undef,
#  index          => 1,
#  items          => {
#                      e_date    => "\x{5DEE}\x{9519}\x{65E5}\x{671F}",
#                      zyzj_acct => "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
#                    },
#  j_from         => undef,
#  j_to           => undef,
#  next_page      => 1,
#  params         => undef,
#  period_from    => undef,
#  period_to      => undef,
#  prev_page      => 1,
#  total_page     => 1,
#  ys_id          => undef,
#  ys_type        => undef,
#  ys_type_dict   => {
#                      "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                      ...
#  zyzj_acct      => undef,
#  zyzj_acct_dict => {
#                      1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                      ...
#                    },
#}
sub blc_zyzj {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'blc_zyzj';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, [ 'zyzj_acct', 'e_date' ] );
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    zyzj_acct => $data->{zyzj_acct},
                    e_date    => [
                        0,
                        $data->{e_date_from}
                          && $self->quote( $data->{e_date_from} ),
                        'e_date_from',
                        $data->{e_date_to}
                          && $self->quote( $data->{e_date_to} ),
                        'e_date_to'
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
    "select id, zyzj_acct, e_date, ys_id, ys_type, j, d, period, rownumber() over() as rowid from book_$book $p->{condition}";
        my $pager = $self->page_data( $sql, $data->{index} );
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    $data->{zyzj_acct_dict} = $self->zyzj_acct;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( 'pd' => $data );
}
# input:
#{
#  book => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{94F6}\x{884C}\x{957F}\x{6B3E}",
#}
# result:
#{
#  book           => "\x{5E94}\x{4ED8}\x{8D26}\x{6B3E}-\x{94F6}\x{884C}-\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{94F6}\x{884C}\x{957F}\x{6B3E}",
#  d_from         => undef,
#  d_to           => undef,
#  e_date_from    => undef,
#  e_date_to      => undef,
#  id             => undef,
#  index          => 1,
#  items          => {
#                      e_date    => "\x{5DEE}\x{9519}\x{65E5}\x{671F}",
#                      zyzj_acct => "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
#                    },
#  j_from         => undef,
#  j_to           => undef,
#  period_from    => undef,
#  period_to      => undef,
#  ys_id          => undef,
#  ys_type        => undef,
#  ys_type_dict   => {
#                      "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                      ...
#                    },
#  zyzj_acct      => undef,
#  zyzj_acct_dict => {
#                      1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                      ...
#                    },
#}
sub init {
    my $self = shift;
    my $data = shift;
    
    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data) if DEBUG;
   
    my $dim  = shift;
    for (@$dim) {
        if (/e_date/) {
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
    
    warn "package: ", __FILE__, "\ndata [after init]:", Data::Dump->dump($data) if DEBUG;
}

1;