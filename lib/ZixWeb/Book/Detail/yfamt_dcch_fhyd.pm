package ZixWeb::Book::Detail::yfamt_dcch_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub yfamt_dcch_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# f_dcn 
	my $f_dcn = $self->param('f_dcn');

	# fm 
	my $fm = $self->param('fm');

	# fyw_type 
	my $fyw_type = $self->param('fyw_type');

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
	unless ( $fir || $sec || $thi || $fou || $fiv ) {
		$fir = 'f_dcn';
        $sec = 'fm';
		$thi = 'fyw_type';
		$fou = 'ftx_date';
		$fiv  = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou, $fiv );
	my $pp = $self->params(
		{
			f_dcn => $f_dcn && $self->quote($f_dcn),
			fm => $fm && $self->quote($fm),
			fyw_type   => $fyw_type,
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yfamt_dcch_fhyd $condition group by $fields";
	warn $sql;
    my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
