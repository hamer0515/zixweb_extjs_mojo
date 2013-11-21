package ZixWeb::Book::Detail::yfamt_m_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yfamt_m_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fm
	my $fm = $self->param('fm');

	# fcg_date
	my $fcg_date_from = $self->param('fcg_date_from');
	my $fcg_date_to   = $self->param('fcg_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fm';
		$sec = 'fcg_date';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			fm => $fm && $self->quote($fm),
			fcg_date => [
				0,
				$fcg_date_from && $self->quote($fcg_date_from),
				$fcg_date_to   && $self->quote($fcg_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yfamt_m_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub yfamt_m_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fm
	my $fm = $self->param('fm');

	# fcg_date
	my $fcg_date_from = $self->param('fcg_date_from');
	my $fcg_date_to   = $self->param('fcg_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fm';
		$sec = 'fcg_date';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			fm => $fm && $self->quote($fm),
			fcg_date => [
				0,
				$fcg_date_from && $self->quote($fcg_date_from),
				$fcg_date_to   && $self->quote($fcg_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_yfamt_m_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
