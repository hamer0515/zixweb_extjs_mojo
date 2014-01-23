package ZixWeb::Pzlr::I0101;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub i0101 {
	my $self = shift;
	my $res;
	my $data = {};
	$data->{_type}  = "0101";
	$data->{tx_amt} = $self->param('tx_amt') * 100;
	for (qw/bfj_acct_bj zjbd_date_out c memo/) {
		my $p = $self->param($_);
		undef $p if $p eq '';
		$data->{$_} = $p;
	}

	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json(
				{
					data => $data,
					svc  => "yspz_0101",
					sys  => { oper_user => $self->session->{uid} },
				}
			)
		)
	);
}

1;
