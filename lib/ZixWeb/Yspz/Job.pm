package ZixWeb::Yspz::Job;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

use constant {
    DEBUG  => $ENV{VOUCHERENTRY_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

# result:
#{
#  data => [
#    {
#      date       => "2013-03-26",
#      fail       => 0,
#      id         => 1,
#      index      => 0,
#      job_status => "\x{8FD0}\x{884C}\x{6210}\x{529F}",
#      succ       => 119,
#      total      => 119,
#      ts_c       => "2013-05-09 12:27:30",
#      ts_u       => "2013-05-09 12:27:30",
#      type       => "0002",
#    },
#    ...
#  ],
#  id => 1,
#}
sub job {
    my $self = shift;
    my $data;
    my $id = $self->param('id');
    my $sql =
"select id, type, date,index, total, fail, succ, ts_u, ts_c, status as jstatus from load_job where mission_id = $id order by index";
    $data->{data} = $self->select( $sql);
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->render(json => $data);
}

1;