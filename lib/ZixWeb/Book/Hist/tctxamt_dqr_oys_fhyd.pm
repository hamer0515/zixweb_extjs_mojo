package ZixWeb::Book::Hist::tctxamt_dqr_oys_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub tctxamt_dqr_oys_fhyd{
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $id     = $self->param('id');
	my $params = {};
	for (qw/ys_type ys_id j_from j_to d_from d_to period_from period_to fhw_type fc ftx_date_from ftx_date_to fch_ssn f_rate/)
	{
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			id       => $id,
			ys_type  => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			fch_ssn  => $params->{fch_ssn} && $self->quote( $params->{fch_ssn} ),
			f_rate  => $params->{f_rate} && $self->quote( $params->{f_rate} ),
			ys_id    => $params->{ys_id},
			j        => [ 0, $params->{j_from}, $params->{j_to} ],
			d        => [ 0, $params->{d_from}, $params->{d_to} ],
			fhw_type => $params->{fhw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
            ftx_date => [
                0,
                $params->{ftx_date_from}
                  && $self->quote( $params->{ftx_date_from} ),
                $params->{ftx_date_to}
                  && $self->quote( $params->{ftx_date_to} )
            ],
			period   => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, fhw_type, fc, ftx_date, fch_ssn, f_rate, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_tctxamt_dqr_oys_fhyd $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;
