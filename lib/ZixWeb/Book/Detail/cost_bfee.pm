package ZixWeb::Book::Detail::cost_bfee;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_bfee {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# bi
	my $bi = $self->param('bi');

	# c
	my $c = $self->param('c');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'bi', $sec = 'c';
		$thi = 'period';
		$fou = 'p';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			c => $c && $self->quote($c),
			p => $p,
			bi     => $bi,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_bfee $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
