package ZixWeb::Book::Detail::wlzj_yfbf;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub wlzj_yfbf {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my ( $fir, $sec );
	$fir = $self->param('fir');
	unless ($fir) {
		$fir = 'period';
	}
	my $fields = join ',', grep { $_ } ($fir);
	my $p = $self->params(
		{ period => [ $self->quote($period_from), $self->quote($period_to) ], }
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_wlzj_yfbf $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub wlzj_yfbf_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to') || '';

	my $fir;
	$fir = $self->param('fir');
	unless ($fir) {
		$fir = 'period';
	}
	my $fields = join ',', grep { $_ } ($fir);
	my $p = $self->params(
		{ period => [ $self->quote($period_from), $self->quote($period_to) ], }
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_wlzj_yfbf $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;
	$self->render( json => $data );
}
1;
