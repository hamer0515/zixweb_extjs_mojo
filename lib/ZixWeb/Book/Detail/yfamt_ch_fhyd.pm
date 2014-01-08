package ZixWeb::Book::Detail::yfamt_ch_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yfamt_ch_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fc
	my $fc = $self->param('fc');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fc';
		$sec = 'fyw_type';
		$thi = 'ftx_date';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
			fyw_type => $fyw_type,
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yfamt_ch_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub yfamt_ch_fhyd_excel {
	my $self = shift;
	
	# Excel Header
	my $header = decode_json $self->param('header');

	# fc
	my $fc = $self->param('fc');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fc';
		$sec = 'fyw_type';
		$thi = 'ftx_date';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
			fyw_type => $fyw_type,
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
"select $fields, sum(j) as j, sum(d) as d from sum_yfamt_ch_fhyd $condition group by $fields order by $fields";
	my $file =
	  $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
