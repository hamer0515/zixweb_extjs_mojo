package ZixWeb::BookMgr::Hist::bamt_yhyf;

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
#  book => "\x{5E94}\x{4ED8}\x{94F6}\x{884C}-\x{5DF2}\x{6838}\x{5E94}\x{4ED8}\x{94F6}\x{884C}\x{6B3E}",
#  count => 5,
#  d_from => undef,
#  d_to => undef,
#  data => [
#    {
#      d => "100.00",
#      id => 5,
#      j => 0,
#      period => "2013-05-06",
#      rowid => 1,
#      ys_id => 1,
#      ys_type => "0000",
#      zjbd_date => "2013-05-06",
#      zjbd_type => "\x{4E0A}\x{6D77}\x{94F6}\x{8054}\x{4EE3}\x{6536}\x{901A}\x{9053}        ",
#      zyzj_acct => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#    },
#    ...
#  ],
#  id => undef,
#  index => 1,
#  items => {
#    zjbd_date => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{65E5}\x{671F}",
#    zjbd_type => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{7C7B}\x{578B}",
#    zyzj_acct => "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
#  },
#  j_from => undef,
#  j_to => undef,
#  next_page => 1,
#  params => undef,
#  period_from => undef,
#  period_to => undef,
#  prev_page => 1,
#  total_page => 1,
#  ys_id => undef,
#  ys_type => undef,
#  ys_type_dict => {
#    "0000" => "\x{7279}\x{79CD}\x{8C03}\x{8D26}\x{5355}",
#    ...
#  },
#  zjbd_date_from => undef,
#  zjbd_date_to => undef,
#  zjbd_type => undef,
#  zjbd_type_dict => {
#    "-4" => "\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}",
#    ...
#  },
#  zyzj_acct => undef,
#  zyzj_acct_dict => {
#    1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#  },
#}
sub bamt_yhyf {
    my $self = shift;
    my $tag  = $self->param('tag');
    my $data = {};
    my $book = 'bamt_yhyf';
    $data->{book} = $self->dict->{types}->{book}->{$book};
    $self->init( $data, [ 'zyzj_acct', 'zjbd_date', 'zjbd_type' ] );
    my $p->{condition} = '';
    unless ($tag) {

        if ( $data->{id} ) {
            $p = $self->params( { id => $data->{id} } );
        }
        else {
            $p = $self->params(
                {
                    zyzj_acct => $data->{zyzj_acct},
                    zjbd_type => $data->{zjbd_type},
                    zjbd_date => [
                        0,
                        $data->{zjbd_date_from}
                          && $self->quote( $data->{zjbd_date_from} ),
                        'zjbd_date_from',
                        $data->{zjbd_date_to}
                          && $self->quote( $data->{zjbd_date_to} ),
                        'zjbd_date_to'
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
    "select id, zyzj_acct, zjbd_type, zjbd_date, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_$book $p->{condition}";
        my $pager = $self->page_data( $sql, $data->{index} );
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
        $data->{params} = $p->{params};
        $data->{data}   = $pager->{data};
    }
    $data->{params} .= '&tag=1' if $tag;
    $data->{zjbd_type_dict} = $self->zjbd_type;
    $data->{zyzj_acct_dict} = $self->zyzj_acct;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( pd => $data );
}
# input:
#{
#  book => "\x{5E94}\x{4ED8}\x{94F6}\x{884C}-\x{5DF2}\x{6838}\x{5E94}\x{4ED8}\x{94F6}\x{884C}\x{6B3E}",
#}
# result:
#{
#  book => "\x{5E94}\x{4ED8}\x{94F6}\x{884C}-\x{5DF2}\x{6838}\x{5E94}\x{4ED8}\x{94F6}\x{884C}\x{6B3E}",
#  d_from => undef,
#  d_to => undef,
#  id => undef,
#  index => 1,
#  items => {
#    zjbd_date => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{65E5}\x{671F}",
#    zjbd_type => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{7C7B}\x{578B}",
#    zyzj_acct => "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
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
#  zjbd_date_from => undef,
#  zjbd_date_to => undef,
#  zjbd_type => undef,
#  zjbd_type_dict => {
#    "-4" => "\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}",
#    ...
#  },
#  zyzj_acct => undef,
#  zyzj_acct_dict => {
#    1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#  },
#}
sub init {
    my $self = shift;
    my $data = shift;
    
    warn "package: ", __FILE__, "\ndata [before init]:", Data::Dump->dump($data) if DEBUG;
    
    my $dim  = shift;
    for (@$dim) {
        if (/zjbd_date/) {
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