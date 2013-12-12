package ZixWeb::Zqqr::submit;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub submit {
	my $self    = shift;
	my $sm_date = $self->param('sm_date');

	#	my $result  = { success => false };
	#	my $res     = $self->ua->post(
	#		$self->configure->{mgr_url},
	#		encode_json {
	#			action => 'pack',
	#			param  => {
	#				date      => $sm_date,
	#				oper_user => $self->session->{uid},
	#			}
	#		}
	#	)->res->json->{status};
	#	$result->{success} = true if $res == 0;
	#	$self->render( json => { success => $result } );

	$self->render(
		json => $self->post_url(
			$self->configure->{mgr_url},
			encode_json(
				{
					action => 'pack',
					param  => {
						date      => $sm_date,
						oper_user => $self->session->{uid},
					}
				}
			)
		)
	);
}

1;
