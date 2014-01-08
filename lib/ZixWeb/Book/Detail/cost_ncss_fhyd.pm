package ZixWeb::Book::Detail::cost_ncss_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub cost_ncss_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fc
	my $fc = $self->param('fc');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# f_ssn
	my $f_ssn = $self->param('f_ssn');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fc';
		$sec = 'period';
		$thi = 'fhw_type';
		$fou = 'f_ssn';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc    => $fc    && $self->quote($fc),
			f_ssn => $f_ssn && $self->quote($f_ssn),
			fhw_type => $fhw_type,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_ncss_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub cost_ncss_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fc
	my $fc = $self->param('fc');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	# fhw_type
	my $fhw_type = $self->param('fhw_type');

	# f_ssn
	my $f_ssn = $self->param('f_ssn');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fc';
		$sec = 'period';
		$thi = 'fhw_type';
		$fou = 'f_ssn';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc    => $fc    && $self->quote($fc),
			f_ssn => $f_ssn && $self->quote($f_ssn),
			fhw_type => $fhw_type,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_cost_ncss_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
