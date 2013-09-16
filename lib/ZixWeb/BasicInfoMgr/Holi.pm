package ZixWeb::BasicInfoMgr::Holi;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

################################
# show index list
################################
sub upload {
    my $self = shift;
    my $file = $self->param('upfile');
    use Data::Dump;
    my $data->{data} = $file->asset->slurp;
    $data->{filename} = $file->filename;
    #my $res = $self->ua->post(
    #    $self->config->{svc_url} => json => {
    #        'data'  => $data,
    #        'sys'   => { 'oper_user' => $self->session->{uid}, },
    #    })->res->json->{status};
    $data->{result} = 0;
    $self->stash( 'pd' => $data );
}

1;

