package ZixWeb::Book::Detail::nctxamt_dqr_oyf_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub nctxamt_dqr_oyf_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fch_ssn
	my $fch_ssn = $self->param('fch_ssn');

	# fs_rate
	my $fs_rate = $self->param('fs_rate');

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fc
	my $fc = $self->param('fc');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

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
		$fir = 'fch_ssn';
		$sec = 'fs_rate';
		$thi = 'fhw_type';
		$fou = 'fc';
		$fiv = 'ftx_date';
		$six = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			fch_ssn => $fch_ssn && $self->quote($fch_ssn),
			fs_rate => $fs_rate && $self->quote($fs_rate),
			fhw_type => $fhw_type,
			fc       => $fc && $self->quote($fc),
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_nctxamt_dqr_oyf_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub nctxamt_dqr_oyf_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fch_ssn
	my $fch_ssn = $self->param('fch_ssn');

	# fs_rate
	my $fs_rate = $self->param('fs_rate');

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# fc
	my $fc = $self->param('fc');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

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
		$fir = 'fch_ssn';
		$sec = 'fs_rate';
		$thi = 'fhw_type';
		$fou = 'fc';
		$fiv = 'ftx_date';
		$six = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			fch_ssn => $fch_ssn && $self->quote($fch_ssn),
			fs_rate => $fs_rate && $self->quote($fs_rate),
			fhw_type => $fhw_type,
			fc       => $fc && $self->quote($fc),
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
"select $fields, sum(j) as j, sum(d) as d from sum_nctxamt_dqr_oyf_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}
1;
