package ZixWeb::Book::Detail::yusamt_c_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub yusamt_c_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

    #fc
    my $fc = $self->param('fc');
    
	# fhw_type 
	my $fhw_type = $self->param('fhw_type');

	# fyw_type
	my $fyw_type = $self->param('fyw_type');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');
    
	my ( $fir, $sec, $thi, $fou, );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'fc';
		$sec = 'fhw_type';
		$thi = 'fyw_type';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
			fhw_type   => $fhw_type,
			fyw_type      => $fyw_type, 
			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_yusamt_c_fhyd $condition group by $fields";
	warn $sql;
    my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;