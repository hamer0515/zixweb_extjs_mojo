package ZixWeb::Ack::ack;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use JSON::XS;

use constant {
    DEBUG  => $ENV{ACK_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub index {
    my $self = shift;
    my $data;
    my $index = $self->param('index') || 1;

    #sm_date
    my $sm_date = $self->param('date');
    $data->{date} = $sm_date;
    $sm_date = $self->quote($sm_date) if $sm_date;

    #status
    my $status = $self->param('status');
    $data->{status} = $status;
    
    my $p = $self->params(
        {
            sm_date     => $sm_date,
            status      => $status,
        }
    );
    my $condition = $p->{condition};

    my $sql =
"select id, sm_date, status as pack_status, rownumber() over(order by sm_date desc, status asc) as rowid from pack_mission $condition";
    my $pager = $self->page_data( $sql, $index );
    $data->{data} = delete $pager->{data};
    for my $key ( keys %$pager ) {
        $data->{$key} = $pager->{$key};
    }
    $data->{params} = $p->{params};
    $data->{pack_status_dict} = $self->dict->{types}{pack_status};
   
    $self->stash( pd => $data );
}

sub submit {
    my $self = shift;
    my $sm_date = $self->param('sm_date');
    # {
    #    action => 'pack',
    #    param  => {
    #        date    => $sm_date,        # 扫描日期 < 当前日期
    #    }
    #
    # }
    my $res = $self->ua->post(
        $self->configure->{mgr_url}, encode_json {
            action  => 'pack',
            param   => {
                date => $sm_date,
                oper_user  => $self->session->{uid},
            }
        })->res->json->{status};
    $self->redirect_to( '/ack/index' );   
}

1;
