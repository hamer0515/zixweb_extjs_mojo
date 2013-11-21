package ZixWeb::Book::Hist::cost_bfee_zg;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub cost_bfee_zg {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to tx_date_from tx_date_to bi c p fp/
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
			c       => $params->{c} && $self->quote( $params->{c} ),
			fp      => $params->{fp} && $self->quote( $params->{fp} ),
			p       => $params->{p},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			tx_date => [
				0,
				$params->{tx_date_from}
				  && $self->quote( $params->{tx_date_from} ),
				$params->{tx_date_to} && $self->quote( $params->{tx_date_to} )
			],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			]
		}
	);
	my $sql =
"select id, bi, c, p, fp,tx_date, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_cost_bfee_zg $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub cost_bfee_zg_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to tx_date_from tx_date_to bi c p fp/
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
			c       => $params->{c} && $self->quote( $params->{c} ),
			fp      => $params->{fp} && $self->quote( $params->{fp} ),
			p       => $params->{p},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j       => [ 0, $params->{j_from}, $params->{j_to} ],
			d       => [ 0, $params->{d_from}, $params->{d_to} ],
			tx_date => [
				0,
				$params->{tx_date_from}
				  && $self->quote( $params->{tx_date_from} ),
				$params->{tx_date_to} && $self->quote( $params->{tx_date_to} )
			],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			]
		}
	);
	my $sql =
"select id, bi, c, p, fp,tx_date, ys_id, ys_type, j, d, period from book_cost_bfee_zg $p->{condition} order by id desc";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
