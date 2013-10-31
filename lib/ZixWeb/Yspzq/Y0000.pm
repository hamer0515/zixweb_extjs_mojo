package ZixWeb::Yspzq::Y0000;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub y0000 {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $data = {};
	for (qw/id flag period_from period_to revoke_user ts_revoke crt_user/) {
		$data->{$_} = $self->param($_);
	}
	if ( $data->{revoke_user} ) {
		$data->{revoker} = $self->uids->{ $data->{revoke_user} } || -1;
	}
	if ( $data->{crt_user} ) {
		$data->{crt_id} = $self->uids->{ $data->{crt_user} } || -1;
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
			revoke_user => $data->{revoker},
			ts_revoke   => [
				0,
				$data->{ts_revoke_from}
				  && $self->quote( $data->{ts_revoke_from} ),
				$data->{ts_revoke_to} && $self->quote( $data->{ts_revoke_to} )
			],
			crt_id => $data->{crt_id}
		}
	);
	my $sql =
"select id, flag, crt_id, period, cause, rownumber() over(order by id desc) as rowid from yspz_0000 $p->{condition}";
	my $pager = $self->page_data( $sql, $page, $limit );

	# 录入员登录名转化为id
	for ( @{ $pager->{data} } ) {
		$_->{crt_user} = $self->usernames->{ delete $_->{crt_id} }
		  if $_->{crt_id};
	}
	$pager->{success} = true;

	$self->render( json => $pager );
}

1;
