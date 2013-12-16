package ZixWeb::Book::Detail::income_add;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub income_add {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'p';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $pa = $self->params(
		{
			p => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pa->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_income_add $condition group by $fields";
    my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub income_add_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	# p
	my $p = $self->param('p');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'p';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $pa = $self->params(
		{
			p => $p,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pa->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_income_add $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
