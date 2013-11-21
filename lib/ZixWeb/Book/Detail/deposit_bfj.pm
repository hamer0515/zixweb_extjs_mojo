package ZixWeb::Book::Detail::deposit_bfj;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub deposit_bfj {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	#bfj_acct
	my $bfj_acct = $self->param('bfj_acct');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'bfj_acct';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $p = $self->params(
		{
			bfj_acct => $bfj_acct,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_deposit_bfj $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub deposit_bfj_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	#bfj_acct
	my $bfj_acct = $self->param('bfj_acct');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

	my ( $fir, $sec );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	unless ( $fir || $sec ) {
		$fir = 'bfj_acct';
		$sec = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec );
	my $p = $self->params(
		{
			bfj_acct => $bfj_acct,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d from sum_deposit_bfj $condition group by $fields order by $fields";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
