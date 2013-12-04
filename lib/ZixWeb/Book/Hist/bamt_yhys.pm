package ZixWeb::Book::Hist::bamt_yhys;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub bamt_yhys {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to zjbd_date_from zjbd_date_to zjbd_type zyzj_acct/
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
			zyzj_acct => $params->{zyzj_acct},
			zjbd_type => $params->{zjbd_type},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j      => [ 0, $params->{j_from}, $params->{j_to} ],
			d      => [ 0, $params->{d_from}, $params->{d_to} ],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			],
			zjbd_date => [
				0,
				$params->{zjbd_date_from}
				  && $self->quote( $params->{zjbd_date_from} ),
				$params->{zjbd_date_to}
				  && $self->quote( $params->{zjbd_date_to} )
			],
		}
	);
	my $sql =
"select id, zyzj_acct, ys_id, ys_type, j, d, period, zjbd_type, zjbd_date, rownumber() over(order by id desc) as rowid from book_bamt_yhys $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;

	$self->render( json => $data );
}

sub bamt_yhys_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	$header = { reverse %$header };

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to zjbd_date_from zjbd_date_to zjbd_type zyzj_acct/
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
			zyzj_acct => $params->{zyzj_acct},
			zjbd_type => $params->{zjbd_type},
			ys_type => $params->{ys_type} && $self->quote( $params->{ys_type} ),
			ys_id   => $params->{ys_id},
			j      => [ 0, $params->{j_from}, $params->{j_to} ],
			d      => [ 0, $params->{d_from}, $params->{d_to} ],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} )
			],
			zjbd_date => [
				0,
				$params->{zjbd_date_from}
				  && $self->quote( $params->{zjbd_date_from} ),
				$params->{zjbd_date_to}
				  && $self->quote( $params->{zjbd_date_to} )
			],
		}
	);
	my $fields = join ',', keys %$header;
	my $sql =
	  "select $fields from book_bamt_yhys $p->{condition}"
	  ;
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;

	$self->render( json => $data );
}

1;
