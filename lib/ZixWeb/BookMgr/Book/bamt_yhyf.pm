package ZixWeb::BookMgr::Book::bamt_yhyf;

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
#    count => 2,
#    data => [
#      {
#        d => 0,
#        j => 0,
#        period => "2013-05-06",
#        rowid => 1,
#        zjbd_date => "2013-05-06",
#        zjbd_type => "\x{8D44}\x{91D1}\x{8C03}\x{62E8}",
#        zyzj_acct => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#      },
#      ...
#    ],
#    fir => "zyzj_acct",
#    fou => "period",
#    from => undef,
#    header => [
#      "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
#      ...
#    ],
#    index => 1,
#    items => {
#      period    => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#      zjbd_date => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{65E5}\x{671F}",
#      zjbd_type => "\x{8D44}\x{91D1}\x{53D8}\x{52A8}\x{7C7B}\x{578B}",
#      zyzj_acct => "\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{8D26}\x{53F7}id",
#    },
#    next_page => 1,
#    params => "&fir=zyzj_acct&sec=zjbd_type&thi=zjbd_date&fou=period",
#    period => undef,
#    prev_page => 1,
#    sec => "zjbd_type",
#    thi => "zjbd_date",
#    to => undef,
#    total_page => 1,
#    zjbd_type => undef,
#    zjbd_type_dict => {
#      "-4" => "\x{94F6}\x{884C}\x{8F6C}\x{8D26}\x{5145}\x{503C}",
#      ...
#    },
#    zyzj_acct => undef,
#    zyzj_acct_dict => {
#      1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#    },
# }
sub bamt_yhyf {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #zyzj_acct
    my $zyzj_acct = $self->param('zyzj_acct');
    $data->{zyzj_acct} = $zyzj_acct;

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
        $fir = 'zyzj_acct';
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
                zyzj_acct => $zyzj_acct,
                zjbd_type => $zjbd_type,
                period => [
                            0,
                            $self->quote( $data->{period_from} ),
                            'period_from',
                            $self->quote( $data->{period_to} ),
                            'period_to'
                        ],
                zjbd_date => [ 0, $from, 'from', $to, 'to' ],
            }
        );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_bamt_yhyf $condition group by $fields";
            my $pager = $self->page_data( $sql, $data->{index} );
            $data->{data} = delete $pager->{data};
            for my $key ( keys %$pager ) {
                $data->{$key} = $pager->{$key};
            }
    }
    $data->{items} = {
        zyzj_acct => $self->dict->{dim}->{zyzj_acct},
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
    $data->{zyzj_acct_dict} = $self->zyzj_acct;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;