package ZixWeb::Pzlr::Mission;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub mission {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/type status date/) {
		my $p = $self->param($_);
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}

	my $p->{condition} = '';
	$p = $self->params(
		{
			type => $params->{type} && $self->quote( $params->{type} ),
			status => $params->{status},
			date   => $params->{date} && $self->quote( $params->{date} ),
		}
	);

	my $condition = $p->{condition};

	my $sql =
"select id, type, date, total, fail, succ, status as mstatus, rownumber() over(order by date desc, type, status) as rowid from load_mission $condition";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;
