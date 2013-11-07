package ZixWeb::Book::Detail::cost_dcch_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_dcch_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

    #fm
    my $fm = $self->param('fm');
    
	# fyw_type 
	my $fyw_type = $self->param('fyw_type');

	# f_dcn
	my $f_dcn = $self->param('f_dcn');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');
    
	my ( $fir, $sec, $thi, $fou, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fm';
		$sec = 'fyw_type';
		$thi = 'f_dcn';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fm => $fm && $self->quote($fm),
			fyw_type   => $fyw_type,
			f_dcn      => $f_dcn && $self->quote($f_dcn), 
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_cost_dcch_fhyd $condition group by $fields";
	warn $sql;
    my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;
