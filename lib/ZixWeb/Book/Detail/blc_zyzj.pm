package ZixWeb::Book::Detail::blc_zyzj;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub blc_zyzj {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# zyzj_acct
	my $zyzj_acct = $self->param('zyzj_acct');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	#e_date
	my $e_date_from = $self->param('e_date_form') || '';
	my $e_date_to   = $self->param('e_date_to')   || '';

	my ( $fir, $sec, $thi, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'zyzj_acct';
		$sec = 'e_date';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );

	my $p = $self->params(
		{
			zyzj_acct => $zyzj_acct,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
			e_date => [
				0,
				$e_date_from && $self->quote($e_date_from),
				$e_date_to   && $self->quote($e_date_to)
			],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over() as rowid from sum_blc_zyzj $condition group by $fields";

	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
