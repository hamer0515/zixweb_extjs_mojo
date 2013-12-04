package ZixWeb::SourceDocMgr::Y0025;

use Mojo::Base 'Mojolicious::Controller';

sub y0025 {
	my $self = shift;
	my $tag  = $self->param('tag');
	my $data = {};
	my $code = '0025';
	$data->{ys_type} = $code;
	$data->{book}    = $code . $self->ys_type->{$code};
	my $fields = [
		'bfj_acct_bj', 'bi',  'period', 'zjbd_date_in_bj',
		'tx_date',     'ssn', 'tx_amt'
	];
	$self->init( $data, $fields );
	my $p->{condition} = 'where status = 1';
	unless ($tag) {
		if ( $data->{id} ) {
			$p = $self->params( { id => $data->{id}, status => 1 } );
		}
		else {
			$p = $self->params(
				{
					ssn => $data->{ssn} && $self->quote( $data->{ssn} ),
					bfj_acct_bj     => $data->{bfj_acct_bj},
					bi              => $data->{bi},
					zjbd_date_in_bj => [
						0,
						$data->{zjbd_date_in_bj_from}
						  && $self->quote( $data->{zjbd_date_in_bj_from} ),
						'zjbd_date_in_bj_from',
						$data->{zjbd_date_in_bj_to}
						  && $self->quote( $data->{zjbd_date_in_bj_to} ),
						'zjbd_date_in_bj_to'
					],
					tx_date => [
						0,
						$data->{tx_date_from}
						  && $self->quote( $data->{tx_date_from} ),
						'tx_date_from',
						$data->{tx_date_to}
						  && $self->quote( $data->{tx_date_to} ),
						'tx_date_to'
					],
					tx_amt => [
						0,             $data->{tx_amt_from},
						'tx_amt_from', $data->{tx_amt_to},
						'tx_amt_to'
					],
					status      => 1,
					flag        => $data->{flag},
					revoke_user => [
						1,                'revoke_user',
						$data->{revoker}, $data->{revoke_user}
					],
					ts_revoke => [
						2,
						$data->{ts_revoke_from}
						  && $self->quote( $data->{ts_revoke_from} ),
						$data->{ts_revoke_to}
						  && $self->quote( $data->{ts_revoke_to} ),
						'ts_revoke',
						$data->{ts_revoke}
					],
					period => [
						0,             $self->quote( $data->{period_from} ),
						'period_from', $self->quote( $data->{period_to} ),
						'period_to'
					]
				}
			);
		}
		my $sql =
		    "select id, "
		  . join( ', ', @$fields )
		  . ", flag, revoke_user, ts_revoke, period, rownumber() over(order by id desc) as rowid from yspz_$code $p->{condition}";
		my $pager = $self->page_data( $sql, $data->{index} );
		%$data = ( %$data, %$pager );
		$data->{params} = $p->{params};
		$data->{data}   = $pager->{data};
	}
	$data->{params} .= '&tag=1' if $tag;
	$data->{bfj_acct_dict} = $self->bfj_acct;
	$data->{bi_dict}       = $self->bi;
	$data->{items}         = $self->dict->{types}->{ 'yspz_' . $code };
	$self->stash( 'pd' => $data );
}

sub init {
	my $self = shift;
	my $data = shift;
	my $dim  = shift;
	my $dict = $self->dict;

	for (@$dim) {
		if ( exists $dict->{types}{range_fields}{$_} ) {
			$data->{ $_ . '_from' } = $self->param( $_ . '_from' );
			$data->{ $_ . '_to' }   = $self->param( $_ . '_to' );
		}
		else {
			$data->{$_} = $self->param($_);
			$data->{ $_ . '_dict' } = $dict->{types}{$_}
			  if $dict->{types}{$_};
			$data->{items}{$_} = $dict->{dim}{$_};
		}
	}
	for (qw/id flag period_from period_to revoke_user ts_revoke/) {
		$data->{$_} = $self->param($_);
	}
	if ( $data->{revoke_user} ) {

	 #my $u =
	 #         $self->select( "select user_id from tbl_user_inf where username="
	 #              . $self->quote( $data->{revoke_user} ) );
	 #        $data->{revoker} = $u->[0]{user_id};
		$data->{revoker} = $self->uids->{ $data->{revoke_user} } || -1;
	}
	if ( $data->{ts_revoke} ) {
		$data->{ts_revoke_from} = $data->{ts_revoke} . ' 00:00:00';
		$data->{ts_revoke_to}   = $data->{ts_revoke} . ' 23:59:59';
	}
	$data->{'index'} = $self->param('index') || 1;
	$data->{ys_type_dict} = $dict->{types}{ys_type};
	$data->{flag_dict}    = $dict->{types}{flag};
}

1;
