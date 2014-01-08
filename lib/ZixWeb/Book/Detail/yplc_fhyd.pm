package ZixWeb::Book::Detail::yplc_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yplc_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fyp_acct
	my $fyp_acct = $self->param('fyp_acct');

	# fe_date
	my $fe_date_from = $self->param('fe_date_from');
	my $fe_date_to   = $self->param('fe_date_to');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fyp_acct';
		$sec = 'period';
		$thi = 'fe_date';
		$fou = 'fyw_type';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fyp_acct => $fyp_acct && $self->quote($fyp_acct),
			fyw_type => $fyw_type,
			fe_date  => [
				0,
				$fe_date_from && $self->quote($fe_date_from),
				$fe_date_to   && $self->quote($fe_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yplc_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub yplc_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# fyp_acct
	my $fyp_acct = $self->param('fyp_acct');

	# fe_date
	my $fe_date_from = $self->param('fe_date_from');
	my $fe_date_to   = $self->param('fe_date_to');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fyp_acct';
		$sec = 'period';
		$thi = 'fe_date';
		$fou = 'fyw_type';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fyp_acct => $fyp_acct && $self->quote($fyp_acct),
			fyw_type => $fyw_type,
			fe_date  => [
				0,
				$fe_date_from && $self->quote($fe_date_from),
				$fe_date_to   && $self->quote($fe_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_yplc_fhyd $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
