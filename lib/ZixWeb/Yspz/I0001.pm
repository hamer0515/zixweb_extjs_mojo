package ZixWeb::VoucherEntry::I0001;

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
#    bfj_acct_dict  => {
#                        1 => "\x{5DE5}\x{5546}\x{94F6}\x{884C}\x{5E7F}\x{897F}\x{94A6}\x{5DDE}\x{5206}\x{884C}-2107590019300023518",
#                        ...
#                      },
#    zyzj_acct_dict => {
#                        1 => "\x{5305}\x{5546}\x{94F6}\x{884C}\x{5317}\x{4EAC}\x{5206}\x{884C}-002477419700010",
#                        ...
#                      },
#  }
sub i0001 {
    my $self = shift;
    my $data;
    $data->{bfj_acct_dict} = $self->bfj_acct;
    $data->{zyzj_acct_dict} = $self->zyzj_acct;
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( 'pd' => $data );
}

1;