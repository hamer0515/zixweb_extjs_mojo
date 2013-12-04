package ZixWeb::Yspz::Action;

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
		$res = $self->ua->post(
			$self->configure->{mgr_url},
			encode_json {
				action => $opt,
				param  => {
					job_id    => $id,
					date      => $date,
					type      => $type,
					oper_user => $self->session->{uid},
				}
			}
		)->res->json;
		if ( $opt eq 'get_log' ) {
			unless ($res) {
				$self->render( json => { success => false } );
				return;
			}
			my $r = "";
			$r .= "$res->{errmsg} <br/>" if $res->{errmsg};
			$r .= join "<br/>", @{ $res->{ret} };
			$self->render( json => { text => $self->my_decode($r) } );
			return;
		}
		else {
			$res = $res->{status};
		}
	}
	else {
		$res = $self->ua->post(
			$self->configure->{mgr_url},
			encode_json {
				action => $opt,
				param  => {
					mission_id => $id,
					date       => $date,
					type       => $type,
					oper_user  => $self->session->{uid},
				}
			}
		)->res->json->{status};
	}
	if ( defined $res && $res == 0 ) {
		$result->{success} = true;
	}
	$self->render( json => $result );
}

1;
