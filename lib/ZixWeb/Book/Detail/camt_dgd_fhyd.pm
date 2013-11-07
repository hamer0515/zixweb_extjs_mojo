package ZixWeb::Book::Detail::camt_dgd_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub camt_dgd_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# fyw_type 
	my $fyw_type = $self->param('fyw_type');

	# fc
	my $fc = $self->param('fc');

	# ftx_date
	my $ftx_date_from = $self->param('ftx_date_from');
	my $ftx_date_to   = $self->param('ftx_date_to');

	#period
	my $period_from = $self->param('period_from');
	my $period_to   = $self->param('period_to');

    # fhw_type
	my $fhw_type = $self->param('fhw_type');
 
    # f_ssn
    my $f_ssn = $self->param('f_ssn');

    # fs_rate
    my $fs_rate = $self->param('fs_rate');

	my ( $fir, $sec, $thi, $fou, $fiv, $six, $sev );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	$fiv = $self->param('fiv');
	$six = $self->param('six');
	$sev = $self->param('sev');
	unless ( $fir || $sec || $thi || $fou || $fiv || $six || $sev) {
		$fir = 'fyw_type'; 
        $sec = 'fc';
		$thi = 'period';
		$fou = 'ftx_date';
        $fiv = 'fhw_type';
        $six = 'f_ssn';
        $sev = 'fs_rate';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou , $fiv, $six, $sev);
	my $pp = $self->params(
		{
			fc => $fc && $self->quote($fc),
            f_ssn   => $f_ssn && $self->quote($f_ssn),
            fs_rate => $fs_rate && $self->quote($fs_rate),
            fhw_type => $fhw_type,
			fyw_type => $fyw_type,
            ftx_date =>[
                0,
                $ftx_date_from && $self->quote($ftx_date_from),
                $ftx_date_to   && $self->quote($ftx_date_to)
            ],

			period => [ $self->quote($period_from), $self->quote($period_to) ],
		}
	);
	my $condition = $pp->{condition};

	my $sql =
"select $fields, sum(j) as j, sum(d) as d, rownumber() over(order by $fields) as rowid from sum_camt_dgd_fhyd $condition group by $fields";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

1;