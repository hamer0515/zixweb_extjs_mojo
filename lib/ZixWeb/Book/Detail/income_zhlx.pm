package ZixWeb::Book::Detail::income_zhlx;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub income_zhlx {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#acct
	my $acct = $self->param('acct');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'acct';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $p = $self->params(
		{
			acct   => $acct,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_income_zhlx $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
