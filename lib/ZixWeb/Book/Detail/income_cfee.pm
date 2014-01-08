package ZixWeb::Book::Detail::income_cfee;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub income_cfee {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# c
	my $c = $self->param('c');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'c';
		$sec = 'period';
		$thi = 'p';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pa = $self->params(
		{
			c => $c && $self->quote($c),
			p => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pa->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_income_cfee $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

sub income_cfee_excel {
	my $self = shift;
	
	# Excel Header
	my $header = decode_json $self->param('header');

	# c
	my $c = $self->param('c');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec, $thi );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'c';
		$sec = 'period';
		$thi = 'p';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $pa = $self->params(
		{
			c => $c && $self->quote($c),
			p => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pa->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_income_cfee $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;
	$self->render( json => $data );
}

1;
