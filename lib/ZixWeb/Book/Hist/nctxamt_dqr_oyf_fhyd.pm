package ZixWeb::Book::Hist::nctxamt_dqr_oyf_fhyd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

sub nctxamt_dqr_oyf_fhyd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to fc ftx_date_from ftx_date_to fhw_type fch_ssn fs_rate/
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
			fhw_type => $params->{fhw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
			fch_ssn => $params->{fch_ssn} && $self->quote( $params->{fch_ssn} ),
			fs_rate => $params->{fs_rate} && $self->quote( $params->{fs_rate} ),
			ftx_date => [
				0,
				$params->{ftx_date_from}
				  && $self->quote( $params->{ftx_date_from} ),
				$params->{ftx_date_to} && $self->quote( $params->{ftx_date_to} )
			],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $sql =
"select id, fc, ftx_date, fhw_type,fch_ssn, fs_rate, ys_id, ys_type, j, d, period, rownumber() over(order by id desc) as rowid from book_nctxamt_dqr_oyf_fhyd $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

sub nctxamt_dqr_oyf_fhyd_excel {
	my $self = shift;

	# Excel Header
	my $header = decode_json $self->param('header');
	$header = { reverse %$header };

	my $params = {};
	for (
		qw/id ys_type ys_id j_from j_to d_from d_to period_from period_to fc ftx_date_from ftx_date_to fhw_type fch_ssn fs_rate/
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
			fhw_type => $params->{fhw_type},
			fc       => $params->{fc} && $self->quote( $params->{fc} ),
			fch_ssn => $params->{fch_ssn} && $self->quote( $params->{fch_ssn} ),
			fs_rate => $params->{fs_rate} && $self->quote( $params->{fs_rate} ),
			ftx_date => [
				0,
				$params->{ftx_date_from}
				  && $self->quote( $params->{ftx_date_from} ),
				$params->{ftx_date_to} && $self->quote( $params->{ftx_date_to} )
			],
			period => [
				$self->quote( $params->{period_from} ),
				$self->quote( $params->{period_to} ),
			]
		}
	);
	my $fields = join ',', keys %$header;
	my $sql =
"select $fields from book_nctxamt_dqr_oyf_fhyd $p->{condition}"
	  ;
	my $file = $self->gen_file( $sql, $header );
	my $data = {};
	$data->{file}    = "/var/$file";
	$data->{success} = true;
	$self->render( json => $data );
}

1;
