package ZixWeb::Book::Hist::bfee_cwwf;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub bfee_cwwf {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to tx_date_from tx_date_to bi/
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
			bi      => $params->{bi},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			period  => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			],
			tx_date => [
				0,
				$params->{tx_date_from}
				  && $self->quote( $params->{tx_date_from} ),
				$params->{tx_date_to} && $self->quote( $params->{tx_date_to} )
			],
		}
	);
	my $sql =
"select id, bi, ys_id, ys_type, j, d, period, tx_date, rownumber() over(order by id desc) as rowid from book_bfee_cwwf $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub bfee_cwwf_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	$header = { reverse %$header };

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to tx_date_from tx_date_to bi/
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
			bi      => $params->{bi},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			period  => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			],
			tx_date => [
				0,
				$params->{tx_date_from}
				  && $self->quote( $params->{tx_date_from} ),
				$params->{tx_date_to} && $self->quote( $params->{tx_date_to} )
			],
		}
	);
	my $fields = join ',', keys %$header;
	my $sql =
	  "select $fields from book_bfee_cwwf $p->{condition}";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
