package ZixWeb::Book::Hist::cost_tcss_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub cost_tcss_fhyd{
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $id     = $self->param('id');
	my $params = {};
	for (qw/ys_type ys_id j_from j_to d_from d_to period_from period_to fhw_type fch_ssn fc/)
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
			ys_id    => $params->{ys_id},
			j        => [ 0, $params->{j_from}, $params->{j_to} ],
			d        => [ 0, $params->{d_from}, $params->{d_to} ],
			fch_ssn  => $params->{fch_ssn} && $self->quote( &params->{fch_ssn}),
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
			fhw_type => $params->{fhw_type}, 
			period   => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, fch_ssn, fc, fhw_type, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_cost_tcss_fhyd $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;