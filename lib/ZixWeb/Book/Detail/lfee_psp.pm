package ZixWeb::Book::Detail::lfee_psp;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub lfee_psp {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#c
	my $c = $self->param('c');

	#cust_proto
	my $cust_proto = $self->param('cust_proto');

	#tx_date
	my $tx_date_from = $self->param('tx_date_from');
	my $tx_date_to   = $self->param('tx_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'c';
		$sec = 'cust_proto';
		$thi = 'tx_date';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $p = $self->params(
		{
			c          => $c          && $self->quote($c),
			cust_proto => $cust_proto && $self->quote($cust_proto),
			tx_date    => [
				0,
				$tx_date_from && $self->quote($tx_date_from),
				$tx_date_to   && $self->quote($tx_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_lfee_psp $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
