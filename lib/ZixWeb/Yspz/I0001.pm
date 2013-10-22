package ZixWeb::VoucherEntry::I0001;

use Mojo::Base 'Mojolicious::Controller';

sub i0001 {
	my $self = shift;
	my $data;
	$data->{bfj_acct_dict}  = $self->bfj_acct;
	$data->{zyzj_acct_dict} = $self->zyzj_acct;
	$self->stash( 'pd' => $data );
}

1;
