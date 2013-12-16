package ZixWeb::Pzlr::Action;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub action {
	my $self = shift;
	my $opt  = $self->param('action');
	my $id   = $self->param('id');
	my $date = $self->param('date');
	my $type = $self->param('type');
	my $res;
	my $result = { success => false };
	if ( $opt eq 'run_job' || $opt eq 'get_log' ) {
		$res = $self->post_url(
			$self->configure->{mgr_url},
			encode_json(
				{
					action => $opt,
					param  => {
						job_id    => $id,
						date      => $date,
						type      => $type,
						oper_user => $self->session->{uid},
					}
				}
			),
			true
		);

		#		$res = $self->ua->post(
		#			$self->configure->{mgr_url},
		#			encode_json {
		#				action => $opt,
		#				param  => {
		#					job_id    => $id,
		#					date      => $date,
		#					type      => $type,
		#					oper_user => $self->session->{uid},
		#				}
		#			}
		#		)->res;
		if ( $opt eq 'get_log' ) {

			#			if ( exists $res->{success} ) {
			#				$self->render( json => $res );
			#				return;
			#			}
			my $r = "";
			$r .= "$res->{errmsg} <br/>" if $res->{errmsg};
			$r .= join "<br/>", @{ $res->{ret} };
			$self->render( json => { text => $self->my_decode($r) } );
			return;
		}
		else {
			my $status = $res->{status};
			if ( $status == 0 ) {
				$res = { success => true };
			}
			else {
				$res = { success => false };
			}
		}
	}
	else {
		$res = $self->post_url(
			$self->configure->{mgr_url},
			encode_json(
				{
					action => $opt,
					param  => {
						mission_id => $id,
						date       => $date,
						type       => $type,
						oper_user  => $self->session->{uid},
					}
				}
			)
		);

		#		$res = $self->ua->post(
		#			$self->configure->{mgr_url},
		#			encode_json {
		#				action => $opt,
		#				param  => {
		#					mission_id => $id,
		#					date       => $date,
		#					type       => $type,
		#					oper_user  => $self->session->{uid},
		#				}
		#			}
		#		)->res->json->{status};
	}
	$self->render( json => $res );
}

1;
