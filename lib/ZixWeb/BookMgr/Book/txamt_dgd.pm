package ZixWeb::BookMgr::Book::txamt_dgd;

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
#  bi         => undef,
#  bi_dict    => {
#                  1  => "\x{4E2D}\x{884C}\x{4EE3}\x{6536}\x{901A}\x{9053}              ",
#                  ...
#  count      => 0,
#  data       => [],
#  fir        => "bi",
#  from       => undef,
#  header     => [
#                  "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#                  ...
#                ],
#  index      => 1,
#  items      => {
#                  bi => "\x{94F6}\x{884C}\x{63A5}\x{53E3}\x{7F16}\x{53F7}",
#                  period => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                  tx_date => "\x{4EA4}\x{6613}\x{65E5}\x{671F}",
#                },
#  next_page  => 1,
#  params     => "&fir=bi&sec=tx_date&thi=period",
#  period     => undef,
#  prev_page  => 1,
#  sec        => "tx_date",
#  thi        => "period",
#  to         => undef,
#  total_page => 1,
#}
sub txamt_dgd {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    # bi
    my $bi = $self->param('bi');
    $data->{bi} = $bi;

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');

    # from
    my $from = $self->param('from');
    $data->{from} = $from;
    $from = $self->quote($from) if $from;

    # to
    my $to = $self->param('to');
    $data->{to} = $to;
    $to = $self->quote($to) if $to;

    my ( $fir, $sec, $thi );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    $thi = $self->param('thi');
    unless ( $fir || $sec || $thi ) {
        $fir = 'bi';
        $sec = 'tx_date';
        $thi = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{thi} = $thi;
    $data->{params} = '';
    unless($tag) { 
        my $p = $self->params(
            {
                bi      => $bi,
                period  => [
                            0,
                            $self->quote( $data->{period_from} ),
                            'period_from',
                            $self->quote( $data->{period_to} ),
                            'period_to'
                            ],
                tx_date => [ 0, $from, 'from', $to, 'to' ]
            }
        );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_txamt_dgd $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        bi      => $self->dict->{dim}->{bi},
        tx_date => $self->dict->{dim}->{tx_date},
        period  => $self->dict->{dim}->{period}
    };
    $data->{header} = [
        grep { $_ } (
            $self->dict->{dim}->{$fir}, $self->dict->{dim}->{$sec},
            $self->dict->{dim}->{$thi}, '借方金额',
            '贷方金额'
        )
    ];
    $data->{params} .= "&fir=$fir&sec=$sec&thi=$thi";
    $data->{params} .= "&tag=1" if $tag;
    $data->{bi_dict} = $self->bi;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( pd => $data );
}

1;