package ZixWeb::Book::Detail::cost_in;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_in {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# c
	my $c = $self->param('c');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'c';
		$sec = 'period';
		$thi = 'p';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			c => $c && $self->quote($c),
			p => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_in $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
