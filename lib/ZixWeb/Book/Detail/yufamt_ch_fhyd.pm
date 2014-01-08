package ZixWeb::Book::Detail::yufamt_ch_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yufamt_ch_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# fc
	my $fc = $self->param('fc');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fyw_type';
		$sec = 'fc';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
			fyw_type => $fyw_type,
			period   => [ $self->quote($period_from), $self->quote($period_to) ]
			,
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yufamt_ch_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub yufamt_ch_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	# fc
	my $fc = $self->param('fc');

	# fio_date
	my $fio_date_from = $self->param('fio_date_from');
	my $fio_date_to   = $self->param('fio_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fyw_type';
		$sec = 'fc';
		$thi = 'period';
		$fou = 'fio_date';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
			fyw_type => $fyw_type,
			fio_date => [
				0,
				$fio_date_from && $self->quote($fio_date_from),
				$fio_date_to   && $self->quote($fio_date_to)
			],

			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_yufamt_ch_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
