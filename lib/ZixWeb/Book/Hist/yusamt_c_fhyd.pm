package ZixWeb::Book::Hist::yusamt_c_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub yusamt_c_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to fhw_type fyw_type fc/
	  )
	{
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			id      => $params->{id},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			fyw_type => $params->{fyw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
			fhw_type => $params->{fhw_type},
			period   => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, fyw_type, fc, fhw_type, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_yusamt_c_fhyd $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

sub yusamt_c_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	$header = { reverse %$header };

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to fhw_type fyw_type fc/
	  )
	{
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			id      => $params->{id},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			fyw_type => $params->{fyw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
			fhw_type => $params->{fhw_type},
			period   => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $fields = join ',', keys %$header;
	my $sql    = "select $fields from book_yusamt_c_fhyd $p->{condition}";
	my $file   = $self->gen_file( $sql, $header );
	my $data   = {};
	$data->{success} = true;
	$self->render( json => $data );
}

1;
