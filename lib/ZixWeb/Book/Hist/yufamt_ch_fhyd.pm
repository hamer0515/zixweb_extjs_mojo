package ZixWeb::Book::Hist::yufamt_ch_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub yufamt_ch_fhyd{
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $id     = $self->param('id');
	my $params = {};
	for (qw/ys_type ys_id j_from j_to d_from d_to period_from period_to fyw_type fc fio_date_from fio_date_to/)
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
			fyw_type => $params->{fyw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
            fio_date => [
                0,
                $params->{fio_date_from}
                  && $self->quote( $params->{fio_date_from} ),
                $params->{fio_date_to}
                  && $self->quote( $params->{fio_date_to} )
            ],
			period   => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, fyw_type, fc, fio_date,  ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_yufamt_ch_fhyd $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;
