package ZixWeb::BookMgr::Book::cfee_dqhf;

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
#  c               => undef,
#  count           => 5,
#  cust_proto      => undef,
#  cust_proto_dict => undef,
#  data            => [
#                       {
#                         c => 51.20121114018,
#                         cust_proto => "1_20121114018",
#                         d => 0,
#                         j => 1.18,
#                         period => "2013-03-24",
#                         rowid => 1,
#                         tx_date => "2013-03-24",
#                       },
#                       ...
#                     ],
#  fir             => "c",
#  fou             => "period",
#  from            => undef,
#  header          => [
#                       "\x{5BA2}\x{6237}id",
#                       ...
#                     ],
#  index           => 1,
#  items           => {
#                       c => "\x{5BA2}\x{6237}id",
#                       cust_proto => "\x{5BA2}\x{6237}\x{534F}\x{8BAE}",
#                       period => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                       tx_date => "\x{4EA4}\x{6613}\x{65E5}\x{671F}",
#                     },
#  next_page       => 1,
#  params          => "&fir=c&sec=cust_proto&thi=tx_date&fou=period",
#  period          => undef,
#  prev_page       => 1,
#  sec             => "cust_proto",
#  thi             => "tx_date",
#  to              => undef,
#  total_page      => 1,
#}
sub cfee_dqhf {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    # c
    my $c = $self->param('c');
    $data->{c} = $c;
    $c = $self->quote($c) if $c;

    # cust_proto
    my $cust_proto = $self->param('cust_proto');
    $data->{cust_proto} = $cust_proto;
    $cust_proto = $self->quote($cust_proto) if $cust_proto;

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');

    #from
    my $from = $self->param('from');
    $data->{from} = $from;
    $from = $self->quote($from) if $from;

    #to
    my $to = $self->param('to');
    $data->{to} = $to;
    $to = $self->quote($to) if $to;

    my ( $fir, $sec, $thi, $fou );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    $thi = $self->param('thi');
    $fou = $self->param('fou');
    unless ( $fir || $sec || $thi || $fou ) {
        $fir = 'c';
        $sec = 'cust_proto';
        $thi = 'tx_date';
        $fou = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{thi} = $thi;
    $data->{fou} = $fou;
    $data->{params} = '';
    unless ($tag) {
        my $pa = $self->params(
            {
                c          => $c,
                cust_proto => $cust_proto,
                period    => [0,
                            $self->quote( $data->{period_from} ),
                            'period_from',
                            $self->quote( $data->{period_to} ),
                            'period_to'],
                tx_date    => [ 0, $from, 'from', $to, 'to' ]
            }
        );
        my $condition = $pa->{condition};
        $data->{params} = $pa->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_cfee_dqhf $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        c          => $self->dict->{dim}->{c},
        cust_proto => $self->dict->{dim}->{cust_proto},
        tx_date    => $self->dict->{dim}->{tx_date},
        period     => $self->dict->{dim}->{period}
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
    $data->{cust_proto_dict} = $self->dict->{types}->{cust_proto};
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;