package ZixWeb::Book::Detail::yp_acct_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yp_acct_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fyp_acct
	my $fyp_acct = $self->param('fyp_acct');

	# fio_date
	my $fio_date_from = $self->param('fio_date_from');
	my $fio_date_to   = $self->param('fio_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fyp_acct';
		$sec = 'period';
		$thi = 'fio_date';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			fyp_acct => $fyp_acct,
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yp_acct_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub yp_acct_fhyd_excel {
	my $self = shift;
	
	# Excel Header
	my $header = decode_json $self->param('header');

	# fyp_acct
	my $fyp_acct = $self->param('fyp_acct');

	# fio_date
	my $fio_date_from = $self->param('fio_date_from');
	my $fio_date_to   = $self->param('fio_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fyp_acct';
		$sec = 'period';
		$thi = 'fio_date';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pp = $self->params(
		{
			fyp_acct => $fyp_acct,
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
"select $fields, sum(j) as j, sum(d) as d from sum_yp_acct_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
