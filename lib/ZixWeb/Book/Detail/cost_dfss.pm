package ZixWeb::Book::Detail::cost_dfss;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_dfss {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'p';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $pp = $self->params(
		{
			p      => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_dfss $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
