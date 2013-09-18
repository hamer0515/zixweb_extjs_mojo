package ZixWeb::BookMgr::Book::fee_jrjg;

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
#  acct       => undef,
#  acct_dict  => {
#                  1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                  ...
#                },
#  count      => 3,
#  data       => [
#                  {
#                    acct => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                    d => 0,
#                    j => 0,
#                    period => "2013-05-06",
#                    rowid => 1,
#                  },
#                  ...
#                ],
#  fir        => "acct",
#  header     => [
#                  "\x{8D44}\x{91D1}\x{8D26}\x{53F7}\x{FF0C} \x{5305}\x{62EC}\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{4E0E}\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}",
#                  ...
#                ],
#  index      => 1,
#  items      => {
#                  acct   => "\x{8D44}\x{91D1}\x{8D26}\x{53F7}\x{FF0C} \x{5305}\x{62EC}\x{81EA}\x{6709}\x{8D44}\x{91D1}\x{4E0E}\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}",
#                  period => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                },
#  next_page  => 1,
#  params     => "&fir=acct&sec=period",
#  period     => undef,
#  prev_page  => 1,
#  sec        => "period",
#  total_page => 1,
#}
sub fee_jrjg {
    my $self = shift;
    my $data;
    $data->{index} = $self->param('index') || 1;
    my $tag  = $self->param('tag');

    #acct
    my $acct = $self->param('acct');
    $data->{acct} = $acct;

    #period
    $data->{period_from} = $self->param('period_from');
    $data->{period_to} = $self->param('period_to');

    my ( $fir, $sec );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    unless ( $fir || $sec ) {
        $fir = 'acct';
        $sec = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec );
    $data->{fir} = $fir;
    $data->{sec} = $sec;
    $data->{params} = '';
    unless ($tag) {
        my $p = $self->params( { acct => $acct, 
                                 period    => [0,
                                    $self->quote( $data->{period_from} ),
                                    'period_from',
                                    $self->quote( $data->{period_to} ),
                                    'period_to'],
                                    } );
        my $condition = $p->{condition};
        $data->{params} = $p->{params};
    
        my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_fee_jrjg $condition group by $fields";
        my $pager = $self->page_data( $sql, $data->{index} );
        $data->{data} = delete $pager->{data};
        for my $key ( keys %$pager ) {
            $data->{$key} = $pager->{$key};
        }
    }
    $data->{items} = {
        acct      => $self->dict->{dim}->{acct},
        period    => $self->dict->{dim}->{period}
    };
    $data->{header} = [
        grep { $_ } (
            $self->dict->{dim}->{$fir}, $self->dict->{dim}->{$sec},
            '借方金额',             '贷方金额'
        )
    ];
    $data->{params} .= "&fir=$fir&sec=$sec";
    $data->{params} .= "&tag=1" if $tag;
    $data->{acct_dict} = $self->dict->{types}->{acct};
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
   
    $self->stash( pd => $data );
}

1;