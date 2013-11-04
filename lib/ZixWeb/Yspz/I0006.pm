package ZixWeb::VoucherEntry::I0006;

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
#       count => 0,
#       data => [...],
#       index => 1,
#       next_page => 1,
#       prev_page => 1,
#       total_page => 1
#}
sub i0006 {
    my $self = shift;
    my $data={};
    $data->{'index'} = $self->param('index') || 1;
    my $sql = "select period, id, bi, ssn, tx_date, tx_amt, bfj_bfee, rownumber() over(order by id desc) as rowid from yspz_0004";
    my $pager = $self->page_data( $sql, $data->{index} );
    %$data=(%$data, %$pager);
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $self->stash( 'pd' => $data );
}

1;