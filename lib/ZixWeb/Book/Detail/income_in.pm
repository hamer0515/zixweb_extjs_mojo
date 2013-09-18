package ZixWeb::BookMgr::Book::income_in;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;
use JSON::XS;

use constant {
    DEBUG  => $ENV{BOOK_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  c => undef,
#  count => 0,
#  data => [],
#  fir => "c",
#  header => [
#    "\x{5BA2}\x{6237}id",
#    ...
#  ],
#  index => 1,
#  items => {
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
#  params => "&fir=c&sec=p&thi=period",
#  period => undef,
#  prev_page => 1,
#  sec => "p",
#  thi => "period",
#  total_page => 1,
#}
sub income_in {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    my $sort = $self->param('sort');
    my $s_str = '';
    if ($sort) {
        $s_str = 'order by ';
        $sort = decode_json $sort;
        for my $s (@$sort) {
            $s_str .= $s->{property}.' '.$s->{direction};
        }
    }

    #c
    my $c = $self->param('c');
    $c = $self->quote($c) if $c;

    #p
    my $p = $self->param('p');

    #period
    my $period_from = $self->param('period_from');
    my $period_to = $self->param('period_to');

    my ( $fir, $sec, $thi );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    $thi = $self->param('thi');
    unless ( $fir || $sec || $thi ) {
        $fir = 'c';
        $sec = 'p';
        $thi = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
    my $pa = $self->params( { c         => $c, 
                              period    => [
                                $self->quote( $period_from ),
                                $self->quote( $period_to )],
                              p         => $p } );
    my $condition = $pa->{condition};

    my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over($s_str) as rowid from sum_income_in $condition group by $fields";
    my $data = $self->page_data( $sql, $page, $limit, $sort );
    $data->{success} = true;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->render(json => $data);
}

1;
