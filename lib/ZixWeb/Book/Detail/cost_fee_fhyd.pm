package ZixWeb::Book::Detail::cost_fee_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_fee_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fyw_type 
	my $fyw_type = $self->param('fyw_type');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

    # fhw_type
	my $fhw_type = $self->param('fhw_type');
 


	my ( $fir, $sec, $thi);
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	unless ( $fir || $sec || $thi ) {
		$fir = 'fyw_type'; 
		$sec = 'period';
        $thi = 'fhw_type';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi );
	my $p = $self->params(
		{
            fhw_type => $fhw_type,
			fyw_type => $fyw_type, 
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $p->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_fee_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
