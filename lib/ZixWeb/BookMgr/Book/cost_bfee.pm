package ZixWeb::BookMgr::Book::cost_bfee;

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
#  bi => undef,
#  bi_dict => {
#    1  => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#    ...
#  },
#  c => undef,
#  count => 8,
#  data => [
#    {
#      bi => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#      c => 51.20121114018,
#      d => 0,
#      j => "171.00",
#      p => "\x{57FA}\x{91D1}\x{6536}\x{6B3E}",
#      period => "2013-03-25",
#      rowid => 1,
#    },
#    ...
#  ],
#  fir => "c",
#  fou => "period",
#  header => [
#    "\x{5BA2}\x{6237}id",
#    ...
#  ],
#  index => 1,
#  items => {
#    bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#    c => "\x{5BA2}\x{6237}id",
#    p => "\x{4EA7}\x{54C1}id",
#    period => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#  },
#  next_page => 1,
#  p => undef,
#  p_dict => {
#    1 => "\x{57FA}\x{91D1}\x{6536}\x{6B3E}",
#    ...
#  },
#  params => "&fir=c&sec=p&thi=bi&fou=period",
#  period => undef,
#  prev_page => 1,
#  sec => "p",
#  thi => "bi",
#  total_page => 1,
#}
sub cost_bfee {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #c
    my $c = $self->param('c');
    $data->{c} = $c;
    $c = $self->quote($c) if $c;

    #p
    my $p = $self->param('p');
    $data->{p} = $p;

    #bi
    my $bi = $self->param('bi');
    $data->{bi} = $bi;

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');
    
    my ( $fir, $sec, $thi, $fou );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    $thi = $self->param('thi');
    $fou = $self->param('fou');
    unless ( $fir || $sec || $thi || $fou ) {
        $fir = 'c';
        $sec = 'p';
        $thi = 'bi';
        $fou = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{thi} = $thi;
    $data->{fou} = $fou;
    $data->{params} = '';
    unless ($tag) {
        my $pa =
          $self->params( {  c => $c, 
                             period    => [0,
                                    $self->quote( $data->{period_from} ),
                                    'period_from',
                                    $self->quote( $data->{period_to} ),
                                    'period_to'],
                            p => $p, 
                            bi => $bi } );
        my $condition = $pa->{condition};
        $data->{params} = $pa->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_cost_bfee $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        c      => $self->dict->{dim}->{c},
        period => $self->dict->{dim}->{period},
        p      => $self->dict->{dim}->{p},
        bi     => $self->dict->{dim}->{bi}
    };
    $data->{header} = [
        grep { $_ } (
            $self->dict->{dim}->{$fir}, $self->dict->{dim}->{$sec},
            $self->dict->{dim}->{$thi}, $self->dict->{dim}->{$fou},
            '借方金额',             '贷方金额'
        )
    ];
    $data->{params} .= "&fir=$fir&sec=$sec&thi=$thi&fou=$fou";
    $data->{params} .= "&tag=1" if $tag;
    $data->{p_dict}  = $self->p;
    $data->{bi_dict} = $self->bi;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;