package ZixWeb::BookMgr::Book::txamt_yhys;

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
#  bfj_acct       => undef,
#  bfj_acct_dict  => {
#                      1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                      ...
#                    },
#  count          => 11,
#  data           => [
#                      {
#                        bfj_acct => "\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300055838",
#                        d => 0,
#                        j => "100.00",
#                        period => "2013-05-03",
#                        rowid => 1,
#                        zjbd_date => "2013-05-03",
#                        zjbd_type => "\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}",
#                      },
#                      ...
#                    ],
#  fir            => "bfj_acct",
#  fou            => "period",
#  from           => undef,
#  header         => [
#                      "\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}id",
#                      ...
#                    ],
#  index          => 1,
#  items          => {
#                      bfj_acct  => "\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}id",
#                      period    => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                      zjbd_date => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{65E5}\x{671F}",
#                      zjbd_type => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{7C7B}\x{578B}",
#                    },
#  next_page      => 1,
#  params         => "&fir=bfj_acct&sec=zjbd_type&thi=zjbd_date&fou=period",
#  period         => undef,
#  prev_page      => 1,
#  sec            => "zjbd_type",
#  thi            => "zjbd_date",
#  to             => undef,
#  total_page     => 1,
#  zjbd_type      => undef,
#  zjbd_type_dict => {
#                      "-4" => "\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}",
#                      ...
#                    },
#}
sub txamt_yhys {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #bfj_acct
    my $bfj_acct = $self->param('bfj_acct');
    $data->{bfj_acct} = $bfj_acct;

    #zjbd_type
    my $zjbd_type = $self->param('zjbd_type');
    $data->{zjbd_type} = $zjbd_type;

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
        $fir = 'bfj_acct';
        $sec = 'zjbd_type';
        $thi = 'zjbd_date';
        $fou = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{thi} = $thi;
    $data->{fou} = $fou;
    $data->{params} = '';
    unless ($tag) {
        my $p = $self->params(
            {
                bfj_acct  => $bfj_acct,
                zjbd_type => $zjbd_type,
                period => [
                            0,
                            $self->quote( $data->{period_from} ),
                            'period_from',
                            $self->quote( $data->{period_to} ),
                            'period_to'
                        ],
                zjbd_date => [ 0, $from, 'from', $to, 'to' ]
            }
        );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_txamt_yhys $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        bfj_acct  => $self->dict->{dim}->{bfj_acct},
        zjbd_type => $self->dict->{dim}->{zjbd_type},
        zjbd_date => $self->dict->{dim}->{zjbd_date},
        period    => $self->dict->{dim}->{period}
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
    $data->{zjbd_type_dict} = $self->zjbd_type;
    $data->{bfj_acct_dict}  = $self->bfj_acct;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( pd => $data );
}

1;