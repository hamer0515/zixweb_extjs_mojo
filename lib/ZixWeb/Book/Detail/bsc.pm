package ZixWeb::Book::Detail::bsc;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub bsc {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#bfj_acct
	my $bfj_acct = $self->param('bfj_acct');

	#zjbd_type
	my $zjbd_type = $self->param('zjbd_type');

	#e_date
	my $e_date_from = $self->param('e_date_from');
	my $e_date_to   = $self->param('e_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'bfj_acct';
		$sec = 'zjbd_type';
		$thi = 'e_date';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $p = $self->params(
		{
			bfj_acct  => $bfj_acct,
			zjbd_type => $zjbd_type,
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
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_bsc $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
