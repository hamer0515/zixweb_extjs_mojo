package ZixWeb::Pzlr::I0015;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub i0015 {
	my $self = shift;
	my $res;

	my $data = {};
	$data->{_type}    = "0015";
	$data->{bfj_bfee} = $self->param('bfj_bfee') * 100;
	$data->{zjhb_amt} = $self->param('zjhb_amt') * 100;
	for (qw/bfj_acct_in bfj_acct_out zjbd_date_in zjbd_date_out memo/) {
		my $p = $self->param($_);
		undef $p if $p eq '';
		$data->{$_} = $p;
	}

	#	$res = $self->ua->post(
	#		$self->configure->{svc_url},
	#		encode_json {
	#			data => $data,
	#			svc  => "yspz_0015",
	#			sys  => { oper_user => $self->session->{uid} },
	#		}
	#	)->res->json->{status};
	#	my $result->{success} = false;
	#	if ( defined $res && $res == 0 ) {
	#		$result->{success} = true;
	#	}
	#	$self->render( json => $result );

	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json(
				{
					data => $data,
					svc  => "yspz_0015",
					sys  => { oper_user => $self->session->{uid} },
				}
			)
		)
	);
}

1;
