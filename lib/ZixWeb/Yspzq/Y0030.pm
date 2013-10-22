package ZixWeb::Yspzq::Y0030;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub y0030 {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $data = {};
	for (
		qw/id bi bfj_acct_bj zjbd_date_in_from zjbd_date_in_to c ssn tx_amt_from tx_amt_to flag period_from period_to revoke_user ts_revoke/
	  )
	{
		$data->{$_} = $self->param($_);
	}
	if ( $data->{revoke_user} ) {
		$data->{revoker} = $self->uids->{ $data->{revoke_user} } || -1;
	}
	if ( $data->{ts_revoke} ) {
		$data->{ts_revoke_from} = $data->{ts_revoke} . ' 00:00:00';
		$data->{ts_revoke_to}   = $data->{ts_revoke} . ' 23:59:59';
	}
	my $p = $self->params(
		{
			period => [
				$self->quote( $data->{period_from} ),
				$self->quote( $data->{period_to} ),
			],
			status       => 1,
			id           => $data->{id},
			bi           => $data->{bi},
			bfj_acct_bj  => $data->{bfj_acct_bj},
			c            => $data->{c},
			ssn          => $data->{ssn},
			zjbd_date_in => [
				0,
				$data->{zjbd_date_in_from}
				  && $self->quote( $data->{zjbd_date_in_from} ),
				$data->{zjbd_date_in_to}
				  && $self->quote( $data->{zjbd_date_in_to} )
			],
			tx_amt => [
				2,
				$data->{tx_amt_from} && $self->quote( $data->{tx_amt_from} ),
				$data->{tx_amt_to}   && $self->quote( $data->{tx_amt_to} )
			],
			flag        => $data->{flag},
			revoke_user => $data->{revoker},
			ts_revoke   => [
				0,
				$data->{ts_revoke_from}
				  && $self->quote( $data->{ts_revoke_from} ),
				$data->{ts_revoke_to} && $self->quote( $data->{ts_revoke_to} )
			]
		}
	);
	my $sql =
"select id, bfj_acct_bj, tx_amt, flag, period, rownumber() over(order by id desc) as rowid from yspz_0030 $p->{condition}";

	my $pager = $self->page_data( $sql, $page, $limit );

	$pager->{success} = true;

	$self->render( json => $pager );
}

1;
