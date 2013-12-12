package ZixWeb::Pzlr::I0014;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub i0014 {
	my $self = shift;
	my $res;

	my $data = {};
	$data->{_type}    = "0014";
	$data->{zhlx_amt} = $self->param('zhlx_amt') * 100;
	for (qw/bfj_acct zjbd_date_in memo/) {
		my $p = $self->param($_);
		undef $p if $p eq '';
		$data->{$_} = $p;
	}

	#	$res = $self->ua->post(
	#		$self->configure->{svc_url},
	#		encode_json {
	#			data => $data,
	#			svc  => "yspz_0014",
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
					svc  => "yspz_0014",
					sys  => { oper_user => $self->session->{uid} },
				}
			)
		)
	);
}

1;
