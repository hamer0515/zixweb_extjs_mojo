package ZixWeb::Book::Detail::cost_bfee_zg;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_bfee_zg {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# bi
	my $bi = $self->param('bi');

	# c
	my $c = $self->param('c');

	# p
	my $p = $self->param('p');

	# fp
	my $fp = $self->param('fp');

	# tx_date
	my $tx_date_from = $self->param('tx_date_from');
	my $tx_date_to   = $self->param('tx_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, $fou, $fiv, $six );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six ) {
		$fir = 'bi', $sec = 'c';
		$thi = 'p';
		$fou = 'fp';
		$fiv = 'tx_date';
		$six = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			c => $c && $self->quote($c),
			p => $p,
			bi      => $bi,
			fp      => $fp && $self->quote($fp),
			tx_date => [
				0,
				$tx_date_from && $self->quote($tx_date_from),
				$tx_date_to   && $self->quote($tx_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_bfee_zg $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
