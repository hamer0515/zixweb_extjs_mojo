package ZixWeb::Book::Detail::tctxamt_dqr_oyf_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub tctxamt_dqr_oyf_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# f_ssn 
	my $f_ssn = $self->param('f_ssn');

	# f_rate 
	my $f_rate = $self->param('f_rate');

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
		$fir = 'f_ssn';
        $sec = 'f_rate';
		$thi = 'fhw_type';
		$fou = 'fc';
		$fiv = 'ftx_date';
		$six = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv, $six );
	my $pp = $self->params(
		{
			f_ssn => $f_ssn && $self->quote($f_ssn),
			f_rate => $f_rate && $self->quote($f_rate),
			fhw_type   => $fhw_type,
			fc      => $fc && $self->quote($fc), 
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_tctxamt_dqr_oyf_fhyd $condition group by $fields";
	warn $sql;
    my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;