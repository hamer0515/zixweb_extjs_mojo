package ZixWeb::Yspzq::Y0104;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub y0104 {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $data = {};
	for (
		qw/id flag bfj_acct_bj  bi period_from period_to revoke_user ts_revoke/)
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
			status      => 1,
			id          => $data->{id},
			flag        => $data->{flag},
			bfj_acct_bj => $data->{bfj_acct_bj},
			bi          => $data->{bi},
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
"select id, flag, period, bfj_acct_bj, bi ,tx_amt, rownumber() over(order by id desc) as rowid from yspz_0104 $p->{condition}";

	my $pager = $self->page_data( $sql, $page, $limit );

	$pager->{success} = true;

	$self->render( json => $pager );
}

1;
