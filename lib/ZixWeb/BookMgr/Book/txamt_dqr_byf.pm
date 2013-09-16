package ZixWeb::BookMgr::Book::txamt_dqr_byf;

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
#                },
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
sub txamt_dqr_byf {
    my $self = shift;
    my $data;
    my $index = $self->param('index') || 1;

    #bi
    my $bi = $self->param('bi');
    $data->{bi} = $bi;

    #period
    my $period = $self->param('period');
    $data->{period} = $period;
    $period = $self->quote($period) if $period;

    #from
    my $from = $self->param('from');
    $data->{from} = $from;
    $from = $self->quote($from) if $from;

    #to
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
    my $p = $self->params(
        {
            bi      => $bi,
            period  => $period,
            tx_date => [ 0, $from, 'from', $to, 'to' ]
        }
    );
    my $condition = $p->{condition};

    my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_txamt_dqr_byf $condition group by $fields";
    my $pager = $self->page_data( $sql, $index );
    $data->{data} = delete $pager->{data};
    for my $key ( keys %$pager ) {
        $data->{$key} = $pager->{$key};
    }
    $data->{items} = {
        bi      => $self->dict->{dim}->{bi},
        period  => $self->dict->{dim}->{period},
        tx_date => $self->dict->{dim}->{tx_date}
    };
    $data->{header} = [
        $self->dict->{dim}->{$fir}, $self->dict->{dim}->{$sec},
        $self->dict->{dim}->{$thi}, '借方金额',
        '贷方金额'
    ];
    $data->{params}  = $p->{params} . "&fir=$fir&sec=$sec&thi=$thi";
    $data->{bi_dict} = $self->bi;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;
