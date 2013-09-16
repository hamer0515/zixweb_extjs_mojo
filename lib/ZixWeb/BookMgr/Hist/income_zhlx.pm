package ZixWeb::BookMgr::Hist::income_zhlx;

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
#  acct         => undef,
#  acct_dict    => {
#                    1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                    ...
#                  },
#  book         => "\x{8D22}\x{52A1}\x{8D39}\x{7528}-\x{8D26}\x{6237}\x{5229}\x{606F}\x{6536}\x{5165}",
#  count        => 1,
#  d_from       => undef,
#  d_to         => undef,
#  data         => [
#                    {
#                      acct => "\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300055838",
#                      d => "1.00",
#                      id => 1,
#                      j => 0,
#                      period => "2013-05-06",
#                      rowid => 1,
#                      ys_id => 4,
#                      ys_type => "0014",
#                    },
#                    ...
#                  ],
#  id           => undef,
#  index        => 1,
#  items        => {
#                    acct => "\x{8D44}\x{91D1}\x{8D26}\x{53F7}\x{FF0C} \x{5305}\x{62EC}\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{4E0E}\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}",
#                  },
#  j_from       => undef,
#  j_to         => undef,
#  next_page    => 1,
#  params       => undef,
#  period_from  => undef,
#  period_to    => undef,
#  prev_page    => 1,
#  total_page   => 1,
#  ys_id        => undef,
#  ys_type      => undef,
#  ys_type_dict => {
#                    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                    ...
#                  },
#}
sub income_zhlx {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'income_zhlx';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, ['acct'] );
    my $p->{condition} = '';
    unless ($tag) {
        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    acct => $data->{acct},
                    ys_type   => $data->{ys_type}
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
    "select id, acct, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_$book $p->{condition}";
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
#  book => "\x{8D22}\x{52A1}\x{8D39}\x{7528}-\x{8D26}\x{6237}\x{5229}\x{606F}\x{6536}\x{5165}",
#}
# result:
#{
#  acct         => undef,
#  acct_dict    => {
#                    1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                    ...
#                  },
#  book         => "\x{8D22}\x{52A1}\x{8D39}\x{7528}-\x{8D26}\x{6237}\x{5229}\x{606F}\x{6536}\x{5165}",
#  d_from       => undef,
#  d_to         => undef,
#  id           => undef,
#  index        => 1,
#  items        => {
#                    acct => "\x{8D44}\x{91D1}\x{8D26}\x{53F7}\x{FF0C} \x{5305}\x{62EC}\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{4E0E}\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}",
#                  },
#  j_from       => undef,
#  j_to         => undef,
#  period_from  => undef,
#  period_to    => undef,
#  ys_id        => undef,
#  ys_type      => undef,
#  ys_type_dict => {
#                    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#                    ...
#                  },
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
    
    warn "package: ", __FILE__, "\ndata [after init]:", Data::Dump->dump($data) if DEBUG;
}

1;