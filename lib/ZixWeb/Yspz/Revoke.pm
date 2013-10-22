package ZixWeb::Yspz::Revoke;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub revoke {
	my $self         = shift;
	my $ys_type      = $self->param('ys_type');         #参数1
	my $ys_id        = $self->param('ys_id');           #参数3
	my $period       = $self->param('period');          #参数4
	my $revoke_cause = $self->param('revoke_cause');    #参数2

	my $uid = $self->session->{uid};

	my $res = 2;

	my $data = {
		'ys_type'      => $ys_type,
		'ys_id'        => $ys_id,
		'rk_user'      => $uid,
		'period'       => $period,
		'revoke_cause' => $revoke_cause,
	};

	$res = $self->ua->post(
		$self->configure->{svc_url},
		encode_json {
			data => {
				type => 2, # 审核类型（1.特种调账单  2.凭证撤销）
				content => $data,
			},
			svc => "add_verify",
			sys => { oper_user => $uid },
		}
	)->res->json->{status};
	my $result = false;
	$result = true if $res == 0;
	$self->render( json => { success => $result } );
}

1;
