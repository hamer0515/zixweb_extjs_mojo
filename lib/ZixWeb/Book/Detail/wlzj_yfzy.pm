package ZixWeb::Book::Detail::wlzj_yfzy;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub wlzj_yfzy {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#wlzj_type
	my $wlzj_type = $self->param('wlzj_type');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'wlzj_type';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $p = $self->params(
		{
			wlzj_type => $wlzj_type,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_wlzj_yfzy $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub wlzj_yfzy_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	#wlzj_type
	my $wlzj_type = $self->param('wlzj_type');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'wlzj_type';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $p = $self->params(
		{
			wlzj_type => $wlzj_type,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_wlzj_yfzy $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
