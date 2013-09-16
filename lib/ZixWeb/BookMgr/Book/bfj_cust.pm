package ZixWeb::BookMgr::Book::bfj_cust;

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
#    c => undef,
#    count => 5,
#    data => [
#      { c => 51.20121114018, d => "200.00", j => 0, period => "2013-03-24", rowid => 1 },
#      ...
#    ],
#    fir => "c",
#    header => [
#      "\x{5BA2}\x{6237}id",
#      ...
#    ],
#    index => 1,
#    items => {
#      c => "\x{5BA2}\x{6237}id",
#      period => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#    },
#    next_page => 1,
#    params => "&fir=c&sec=period",
#    period => undef,
#    prev_page => 1,
#    sec => "period",
#    total_page => 1,
#  }
sub bfj_cust {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #c
    my $c = $self->param('c');
    $data->{c} = $c;
    $c = $self->quote($c) if $c;

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');

    my ( $fir, $sec );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    unless ( $fir || $sec ) {
        $fir = 'c';
        $sec = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{params} = '';
    unless ($tag) {
        my $p = $self->params( { c => $c, 
                                 period    => [0,
                                    $self->quote( $data->{period_from} ),
                                    'period_from',
                                    $self->quote( $data->{period_to} ),
                                    'period_to'], } );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_bfj_cust $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} =
      { c => $self->dict->{dim}->{c}, period => $self->dict->{dim}->{period} };
    $data->{header} = [
        grep { $_ } (
            $self->dict->{dim}->{$fir}, $self->dict->{dim}->{$sec},
            '借方金额',             '贷方金额'
        )
    ];
    $data->{params} .= "&fir=$fir&sec=$sec";
    $data->{params} .= "&tag=1" if $tag;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;