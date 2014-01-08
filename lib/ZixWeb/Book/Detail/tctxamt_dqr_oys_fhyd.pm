package ZixWeb::Book::Detail::tctxamt_dqr_oys_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub tctxamt_dqr_oys_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fc
	my $fc = $self->param('fc');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fch_ssn
	my $fch_ssn = $self->param('fch_ssn');

	# f_rate
	my $f_rate = $self->param('f_rate');

	my ( $fir, $sec, $thi, $fou, $fiv, $six );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six ) {
		$fir = 'fhw_type';
		$sec = 'fc';
		$thi = 'period';
		$fou = 'ftx_date';
		$fiv = 'fch_ssn';
		$six = 'f_rate';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			fc      => $fc      && $self->quote($fc),
			fch_ssn => $fch_ssn && $self->quote($fch_ssn),
			f_rate  => $f_rate  && $self->quote($f_rate),
			fhw_type => $fhw_type,
			ftx_date => [
				0,
				$ftx_date_from && $self->quote($ftx_date_from),
				$ftx_date_to   && $self->quote($ftx_date_to)
			],

			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_tctxamt_dqr_oys_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub tctxamt_dqr_oys_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fc
	my $fc = $self->param('fc');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fch_ssn
	my $fch_ssn = $self->param('fch_ssn');

	# f_rate
	my $f_rate = $self->param('f_rate');

	my ( $fir, $sec, $thi, $fou, $fiv, $six );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six ) {
		$fir = 'fhw_type';
		$sec = 'fc';
		$thi = 'period';
		$fou = 'ftx_date';
		$fiv = 'fch_ssn';
		$six = 'f_rate';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			fc      => $fc      && $self->quote($fc),
			fch_ssn => $fch_ssn && $self->quote($fch_ssn),
			f_rate  => $f_rate  && $self->quote($f_rate),
			fhw_type => $fhw_type,
			ftx_date => [
				0,
				$ftx_date_from && $self->quote($ftx_date_from),
				$ftx_date_to   && $self->quote($ftx_date_to)
			],

			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_tctxamt_dqr_oys_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
