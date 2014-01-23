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
		if ( $opt eq 'get_log' ) {
			if ( delete $res->{status} == 0 ) {
				my $r = "";
				$r .= "$res->{errmsg} <br/>" if $res->{errmsg};
				$r .= join "<br/>", @{ $res->{ret} };
				$self->render(
					json => { text => $self->my_decode($r), success => true } );
				return;
			}
		}
		else {
			if ( delete $res->{status} == 0 ) {
				$res = { success => true };
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
	}
	$self->render( json => $res );
}

1;
