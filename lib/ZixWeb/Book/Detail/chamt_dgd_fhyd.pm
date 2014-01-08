package ZixWeb::Book::Detail::chamt_dgd_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub chamt_dgd_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# f_ssn
	my $f_ssn = $self->param('f_ssn');

	# fch_rate
	my $fch_rate = $self->param('fch_rate');

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	#fc
	my $fc = $self->param('fc');

	my ( $fir, $sec, $thi, $fou, $fiv, $six, $sev );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	$sev = $self->param('sev');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six || $sev ) {
		$fir = 'f_ssn';
		$sec = 'fch_rate';
		$thi = 'fhw_type';
		$fou = 'fyw_type';
		$fiv = 'ftx_date';
		$six = 'period';
		$sev = 'fc';
	}
	my $fields = join ',',
	  grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six, $sev );
	my $pp = $self->params(
		{
			f_ssn    => $f_ssn    && $self->quote($f_ssn),
			fch_rate => $fch_rate && $self->quote($fch_rate),
			fhw_type => $fhw_type,
			fyw_type => $fyw_type,
			ftx_date => [
				0,
				$ftx_date_from && $self->quote($ftx_date_from),
				$ftx_date_to   && $self->quote($ftx_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
			fc => $fc && $self->quote($fc),
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_chamt_dgd_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub chamt_dgd_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# f_ssn
	my $f_ssn = $self->param('f_ssn');

	# fch_rate
	my $fch_rate = $self->param('fch_rate');

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	#fc
	my $fc = $self->param('fc');

	my ( $fir, $sec, $thi, $fou, $fiv, $six, $sev );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	$sev = $self->param('sev');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six || $sev ) {
		$fir = 'f_ssn';
		$sec = 'fch_rate';
		$thi = 'fhw_type';
		$fou = 'fyw_type';
		$fiv = 'ftx_date';
		$six = 'period';
		$sev = 'fc';
	}
	my $fields = join ',',
	  grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six, $sev );
	my $pp = $self->params(
		{
			f_ssn    => $f_ssn    && $self->quote($f_ssn),
			fch_rate => $fch_rate && $self->quote($fch_rate),
			fhw_type => $fhw_type,
			fyw_type => $fyw_type,
			ftx_date => [
				0,
				$ftx_date_from && $self->quote($ftx_date_from),
				$ftx_date_to   && $self->quote($ftx_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
			fc => $fc && $self->quote($fc),
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_chamt_dgd_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
