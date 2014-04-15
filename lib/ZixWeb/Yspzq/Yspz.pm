package ZixWeb::Yspzq::Yspz;

use Mojo::Base 'Mojolicious::Controller';
use boolean;

sub list {
	my $self = shift;

	my $page   = $self->param('page');
	my $limit  = $self->param('limit');
	my $ys_id  = $self->param('ys_id');
	my $fields = $self->dict->{types}{yspz}{"yspz_$ys_id"};
	my $data   = { status => 1 };
	for my $field ( keys %$fields ) {
		next if $field eq 'period';
		if ( $fields->{$field}[1] eq 'date' ) {
			my ( $from, $to ) = (
				$self->param( $field . "_from" ),
				$self->param( $field . "_to" )
			);
			$data->{$field} =
			  [ 0, $from && $self->quote($from), $to && $self->quote($to) ];
		}
		elsif ( $fields->{$field}[1] eq 'money' ) {
			my ( $from, $to ) = (
				$self->param( $field . "_from" ),
				$self->param( $field . "_to" )
			);
			$data->{$field} = [ 0, $from && $from * 100, $to && $to * 100 ];
		}
		elsif ( $fields->{$field}[1] eq 'text' ) {
			my $text = $self->param($field);
			$data->{$field} = $text && $self->quote($text);
		}
		else {
			$data->{$field} = $self->param($field);
		}
	}
	$data->{period} = [
		$self->quote( $self->param('period_from') ),
		$self->quote( $self->param('period_to') ),
	];
	for (qw/id flag revoke_user ts_revoke crt_user/) {
		$data->{$_} = $self->param($_);
	}
	if ( $data->{revoke_user} ) {
		$data->{revoke_user} = $self->uids->{ $data->{revoke_user} }
		  || -1;
	}
	if ( $data->{crt_user} ) {
		$data->{crt_id} = $self->uids->{ delete $data->{crt_user} } || -1;
	}

	# 特种调账单的原因字段模糊查询
	if ( $data->{cause} ) {
		$data->{cause} = [ 4, '%' . $self->param('cause') . '%' ];
	}
	if ( $data->{ts_revoke} ) {
		my ( $from, $to ) = (
			$self->quote( $data->{ts_revoke} . ' 00:00:00' ),
			$self->quote( $data->{ts_revoke} . ' 00:00:00' )
		);
		$data->{ts_revoke} = [ 0, $from, $to ];
	}
	my $p = $self->params($data);
	$fields = join ', ', keys %$fields;
	my $sql =
"select id, flag, crt_id, period, $fields, rownumber() over(order by id desc) as rowid from yspz_$ys_id $p->{condition}";
	my $pager = $self->page_data( $sql, $page, $limit );

	for ( @{ $pager->{data} } ) {
		$_->{crt_user} = $self->usernames->{ delete $_->{crt_id} }
		  if $_->{crt_id};
	}
	$pager->{success} = true;

	$self->render( json => $pager );
}

1;
