package ZixWeb::Book::Detail::bsc_zyzj;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub bsc_zyzj {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#zyzj_acct
	my $zyzj_acct = $self->param('zyzj_acct');

	#e_date
	my $e_date_from = $self->param('e_date_from');
	my $e_date_to   = $self->param('e_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'zyzj_acct';
		$sec = 'e_date';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, );
	my $p = $self->params(
		{
			zyzj_acct => $zyzj_acct,
			e_date    => [
				0,
				$e_date_from && $self->quote($e_date_from),
				$e_date_to   && $self->quote($e_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_bsc_zyzj $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub bsc_zyzj_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	#zyzj_acct
	my $zyzj_acct = $self->param('zyzj_acct');

	#e_date
	my $e_date_from = $self->param('e_date_from');
	my $e_date_to   = $self->param('e_date_to');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'zyzj_acct';
		$sec = 'e_date';
		$thi = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, );
	my $p = $self->params(
		{
			zyzj_acct => $zyzj_acct,
			e_date    => [
				0,
				$e_date_from && $self->quote($e_date_from),
				$e_date_to   && $self->quote($e_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_bsc_zyzj $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
