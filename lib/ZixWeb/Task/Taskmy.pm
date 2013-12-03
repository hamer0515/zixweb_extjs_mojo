package ZixWeb::Task::Taskmy;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub list {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $id = $self->param('id');

	my $params = {};
	for (qw/from to status type/) {
		my $p = $self->param($_);
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}

	my $p->{condition} = '';
	$p = $self->params(
		{
			ys_type => [ 4, '0%' ],
			id      => $id,
			ts_c    => [
				0,
				$params->{from} && $self->quote( $params->{from} ),
				$params->{to}   && $self->quote( $params->{to} )
			],
			status => $params->{status},
			c_user => $self->session->{uid},
			type   => $params->{type}
		}
	);

	my $sql =
"select type as shtype, ys_type, ys_id, content, ts_c, status as shstatus, rownumber() over(order by id desc) as rowid from verify $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );

	for my $d ( @{ $data->{data} } ) {
		my $content = decode_json delete $d->{content};
		$d->{cause} = $content->{cause}        if $content->{cause};
		$d->{cause} = $content->{revoke_cause} if $content->{revoke_cause};
	}
	$data->{success} = true;

	$self->render( json => $data );
}

1;
