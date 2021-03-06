package ZixWeb::Book::Detail::bamt_yhyf;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub bamt_yhyf {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#zyzj_acct
	my $zyzj_acct = $self->param('zyzj_acct');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	# zjbd_date
	my $zjbd_date_from = $self->param('zjbd_date_from');
	my $zjbd_date_to   = $self->param('zjbd_date_to');

	# zjbd_type
	my $zjbd_type = $self->param('zjbd_type');

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'zyzj_acct';
		$sec = 'period';
		$thi = 'zjbd_date';
		$fou = 'zjbd_type';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $p = $self->params(
		{
			zyzj_acct => $zyzj_acct,
			zjbd_type => $zjbd_type,
			zjbd_date => [
				0,
				$zjbd_date_from && $self->quote($zjbd_date_from),
				$zjbd_date_to   && $self->quote($zjbd_date_to)
			],
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_bamt_yhyf $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;
