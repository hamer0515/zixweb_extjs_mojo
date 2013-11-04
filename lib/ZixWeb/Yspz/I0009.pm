package ZixWeb::VoucherEntry::I0009;

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
#  bi_dict => {
#    1  => "\x{57FA}\x{91D1}-\x{4E2D}\x{884C}\x{4EE3}\x{6536}",
#    ...
#  },
#}
sub i0009 {
    my $self = shift;
    my $data;
    $data->{bi_dict} = $self->bi;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( 'pd' => $data );
}

1;