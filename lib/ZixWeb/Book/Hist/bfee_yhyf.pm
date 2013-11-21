package ZixWeb::Book::Hist::bfee_yhyf;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub bfee_yhyf {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to bfj_acct zjbd_type zjbd_date_from zjbd_date_to/
	  )
	{
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			id        => $params->{id},
			zjbd_type => $params->{zjbd_type},
			zjbd_date => [
				0,
				$params->{zjbd_date_from}
				  && $self->quote( $params->{zjbd_date_from} ),
				$params->{zjbd_date_to}
				  && $self->quote( $params->{zjbd_date_to} )
			],
			bfj_acct => $params->{bfj_acct},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j      => [ 0, $params->{j_from}, $params->{j_to} ],
			d      => [ 0, $params->{d_from}, $params->{d_to} ],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, bfj_acct, zjbd_type, zjbd_date, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_bfee_yhyf $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub bfee_yhyf_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to bfj_acct zjbd_type zjbd_date_from zjbd_date_to/
	  )
	{
		my $p = $self->param($_);
		undef $p if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			id        => $params->{id},
			zjbd_type => $params->{zjbd_type},
			zjbd_date => [
				0,
				$params->{zjbd_date_from}
				  && $self->quote( $params->{zjbd_date_from} ),
				$params->{zjbd_date_to}
				  && $self->quote( $params->{zjbd_date_to} )
			],
			bfj_acct => $params->{bfj_acct},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j      => [ 0, $params->{j_from}, $params->{j_to} ],
			d      => [ 0, $params->{d_from}, $params->{d_to} ],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, bfj_acct, zjbd_type, zjbd_date, ys_id, ys_type, j, d, period from book_bfee_yhyf $p->{condition} order by id desc";
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
