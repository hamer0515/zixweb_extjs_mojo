package ZixWeb::Book::Detail::blc_zyzj;

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
#  zyzj_acct      => undef,
#  zyzj_acct_dict => {
#                     1  => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                     ...
#                   },
#  count         => 2,
#  data          => [
#                     {
#                       zyzj_acct => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                       d => 0,
#                       j => "65,8063.28",
#                       period => "2013-03-25",
#                       rowid => 1,
#                     }, ...
#                   ],
#  fir           => "zyzj_acct",
#  header        => [
#                     "\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}id",
#                     ...
#                   ],
#  index         => 1,
#  items         => {
#                     zyzj_acct => "\x{5907}\x{4ED8}\x{91D1}\x{8D26}\x{53F7}id",
#                     period   => "\x{671F}\x{95F4}\x{65E5}\x{671F}",
#                   },
#  next_page     => 1,
#  params        => "&fir=zyzj_acct&sec=period",
#  period        => undef,
#  prev_page     => 1,
#  sec           => "period",
#  total_page    => 1,
#}

sub blc_zyzj {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');

    # zyzj_acct
    my $zyzj_acct = $self->param('zyzj_acct');

    #period
    my $period_from = $self->param('period_from');
    my $period_to = $self->param('period_to');

    #e_date 
    my $e_date_from = $self->param('e_date_form')||'';
    my $e_date_to = $self->param('e_date_to')||'';

    my ( $fir, $sec, $thi, );
    $fir = $self->param('fir');
    $sec = $self->param('sec');
    $thi = $self->param('thi');
    unless ( $fir || $sec || $thi ) {
        $fir = 'zyzj_acct';
        $sec = 'e_date';
        $thi = 'period';
    }
    my $fields = join ',', grep { $_ } ( $fir, $sec, $thi);
    
    
    my $p = $self->params( { zyzj_acct     => $zyzj_acct, 
                             period => [
                                $self->quote( $period_from ),
                                $self->quote( $period_to )
                             ],
                             e_date => [
                                0,
                                $e_date_from && $self->quote( $e_date_from ),
                                $e_date_to && $self->quote( $e_date_to )
                             ], } );
    my $condition = $p->{condition};

    my $sql =
    "select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_blc_zyzj $condition group by $fields";

    warn $sql;
    my $data = $self->page_data( $sql, $page, $limit );
    $data->{success} = true;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->render(json => $data);
}

1;
