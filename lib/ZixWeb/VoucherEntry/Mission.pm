package ZixWeb::VoucherEntry::Mission;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;

use constant {
    DEBUG  => $ENV{VOUCHERENTRY_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  count               => 15,
#  data                => [
#                           {
#                             date => "2013-05-10",
#                             fail => 0,
#                             id => 22,
#                             mission_status => "\x{4E0B}\x{8F7D}\x{5931}\x{8D25}",
#                             rowid => 1,
#                             succ => 0,
#                             total => 0,
#                             type => "0002",
#                           },
#                           ...
#                         ],
#  date                => "",
#  index               => 1,
#  mission_status_dict => {
#                           -3 => "\x{8FD0}\x{884C}\x{5931}\x{8D25}",
#                           ...
#                         },
#  next_page           => 1,
#  params              => "",
#  prev_page           => 1,
#  status              => "",
#  total_page          => 1,
#  type                => "",
#}
sub mission {
    my $self = shift;
    
    my $page = $self->param('page');
    my $limit = $self->param('limit');
    
    my $params = {};
    for (qw/type status date/) {
        my $p = $self->param($_);
        $p = undef if $p eq '';
        $params->{$_} = $p;
    }
    
    my $p->{condition} = '';
    $p = $self->params(
            {
                type    =>  $params->{type} && $self->quote($params->{type}),
                status  =>  $params->{status},
                date    =>  $params->{date} && $self->quote($params->{date}),
            }
    );

    my $condition = $p->{condition};

    my $sql =
"select id, type, date, total, fail, succ, status as mstatus, rownumber() over(order by date desc, type, status) as rowid from load_mission $condition";
    my $data = $self->page_data( $sql, $page, $limit );
    $data->{success} = true;
    $self->render(json => $data);
}

1;