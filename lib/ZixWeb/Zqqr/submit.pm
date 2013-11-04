package ZixWeb::Zqqr::submit;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;
use JSON::XS;

use constant {
    DEBUG  => $ENV{ZQQR_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub submit {
    my $self = shift;
    my $sm_date = $self->param('sm_date');
    my $result = { success => false };
    my $res = $self->ua->post(
        $self->configure->{mgr_url}, encode_json {
            action  => 'pack',
            param   => {
                date => $sm_date,
                oper_user  => $self->session->{uid},
            }
        })->res->json->{status};
    $result->{success} = true if $res == 0;
    $self->render(json => { success => $result });  
}

1;
