package ZixWeb::Yspz::I0000;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;
use Encode qw/encode/;

sub i0000 {
	my $self = shift;
	my $res;
	my $data = encode( 'utf8', $self->param('data') );
	$data = decode_json $data;
	$res  = $self->ua->post(
		$self->configure->{svc_url},
		encode_json(
			{             # 添加特种调账审核信息
				data => {
					type =>
					  1,   # 审核类型（1.特种调账单  2.凭证撤销）
					content => $data,
				},
				svc => "add_verify",
				sys => { oper_user => $self->session->{uid} },
			}
		)
	)->res->json->{status};
	my $result->{success} = false;
	if ( defined $res && $res == 0 ) {
		$result->{success} = true;
	}
	$self->render( json => $result );
}

1;
