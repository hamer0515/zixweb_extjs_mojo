package ZixWeb::Zjdz::Zjdz_qd;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

#
#模块名称:需对账银行账户查询
#
sub qd {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/from to fch/) {
		my $p = $self->param($_) || '';
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			fch => $params->{fch} && $self->quote( $params->{fch} ),
			zjdz_date => [
				0,
				$params->{from} && $self->quote( $params->{from} ),
				$params->{to}   && $self->quote( $params->{to} ),
			],
			status => 1
		}
	);

	my $sql =
"select fch, zjdz_date,rownumber() over(order by zjdz_date asc) as rowid from job_dz_qd_fhyd $p->{condition} ";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

#
#模块名称:需对账银行账户-对账 / 计算长短款
#
sub qdcheck {
	my $self = shift;
	my $data;

	# f_ch 渠道方编号
	my $f_ch = $self->param('f_ch');    #参数2
	$data->{f_ch} = $f_ch;

	#b_acct
	$data->{fch_name} = $self->f_ch->{$f_ch};

	# date
	my $zjbd_date = $self->param('zjbd_date');    #参数3
	$data->{zjbd_date} = $zjbd_date;

	#tag
	my $tag = $self->param('tag') || 0;

	my $p = $self->params(
		{
			period => "'" . $zjbd_date . "'",
			fch    => "'" . $f_ch . "'"
		}
	);
	my $condition = $p->{condition} || "";

	#此处查出的是zjdz_type的id
	my $yufamt_ch_fhyd_sql =
	    "select fch as f_ch,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_yufamt_ch_fhyd $condition "
	  . "group by fch";

	my $yufamt = $self->select($yufamt_ch_fhyd_sql)
	  || [ { f_ch => $f_ch, j_amt => 0, d_amt => 0 } ];

	#借贷金额累加
	$yufamt = $self->zjdz($yufamt);

	my $all;
	for my $f_ch ( keys %$yufamt ) {
		my $fch_name = $self->f_ch->{$f_ch};
		$all->{$fch_name} = [
			$self->nf( $yufamt->{$f_ch}->{j_amt} / 100 ),
			$self->nf( $yufamt->{$f_ch}->{d_amt} / 100 )
		];
	}

	my $length = keys %{$all};
	$all->{t_ids} = [ keys %{$all} ];
	$all->{l}     = $length;

	my ( $before, $current, $predict, $lc, $sc ) = (
		$zjbd_date . "日前渠道余额",
		$zjbd_date . "日渠道预期余额",
		$zjbd_date . "日渠道实际余额",
		$zjbd_date . "日渠道长款",
		$zjbd_date . "日渠道短款",
	);
	$all->{ch_qd} =
	  [ '渠道方资金变化', $before, $current, $predict, $lc, $sc ];

	my $quote_fch = $self->quote($f_ch);

	my $before_sql =
"select sum(j)-sum(d) as b from sum_yufamt_ch_fhyd where period<\'$zjbd_date\' and fch = $quote_fch ";
	my $before_amt = ( $self->select($before_sql) )->[0]->{b} || 0;

	my $current_sql =
"select sum(j)-sum(d) as b from sum_yufamt_ch_fhyd where period<=\'$zjbd_date\' and fch = $quote_fch ";
	my $current_amt = ( $self->select($current_sql) )->[0]->{b} || 0;

	#print "$before_sql\n $current_sql\n";
	#print "before: $before_amt ; current: $current_amt \n";

	$data->{real_ch_amt} = $self->param('real_ch_amt') || '0.00';
	my $ch;
	my $lc_amt;
	my $sc_amt;
	if ( defined $self->param('real_ch_amt') ) {
		$ch = $self->uf( $self->param('real_ch_amt') ) * 100;
		if ( $current_amt > $ch ) {
			$lc_amt = 0;
			$sc_amt = $current_amt - $ch;
		}
		elsif ( $current_amt < $ch ) {
			$lc_amt = $ch - $current_amt;
			$sc_amt = 0;
		}
		else {
			$lc_amt = 0;
			$sc_amt = 0;
		}
	}
	else {
		$ch     = 0;
		$lc_amt = 0;
		$sc_amt = 0;
	}
	$before_amt /= 100;
	$all->{$before} = $self->nf($before_amt);
	$current_amt /= 100;
	$all->{$current} = $self->nf($current_amt);
	$ch /= 100;
	$all->{$predict} = $self->nf($ch);
	$lc_amt /= 100;
	$all->{$lc} = $self->nf($lc_amt);
	$sc_amt /= 100;
	$all->{$sc} = $self->nf($sc_amt);

	for (qw/l t_ids ch_qd/) {
		$data->{$_} = delete $all->{$_};
	}
	$data->{data} = $all;

	#use Data::Dump;
	#Data::Dump->dump($data);
	$self->render( json => $data );
}

# 模块名称:需对账-对账完成
sub qdcheckdone {
	my $self = shift;
	my $data;

	# f_ch 渠道方编号
	my $f_ch = $self->param('f_ch');    #参数2
	$data->{fch} = $f_ch;

	#b_acct
	$data->{fch_name} = $self->f_ch->{$f_ch};

	# date
	my $zjbd_date = $self->param('zjbd_date');    #参数3
	$data->{zjbd_date} = $zjbd_date;

	my $quote_fch = $self->quote($f_ch);

	my $current_sql =
"select sum(j)-sum(d) as b from sum_yufamt_ch_fhyd where period<=\'$zjbd_date\' and fch = $quote_fch ";
	my $current_amt = ( $self->select($current_sql) )->[0]->{b} || 0;

	my $ch;
	my $lc_amt;
	my $sc_amt;
	if ( defined $self->param('real_ch_amt') ) {
		$ch = $self->uf( $self->param('real_ch_amt') ) * 100;
		if ( $current_amt > $ch ) {
			$lc_amt = 0;
			$sc_amt = $current_amt - $ch;
		}
		elsif ( $current_amt < $ch ) {
			$lc_amt = $ch - $current_amt;
			$sc_amt = 0;
		}
		else {
			$lc_amt = 0;
			$sc_amt = 0;
		}
	}
	else {
		$ch     = 0;
		$lc_amt = 0;
		$sc_amt = 0;
	}

	$data->{zjbd_type}{lc_amt} = $lc_amt;
	$data->{zjbd_type}{sc_amt} = $sc_amt;
	$data->{zjbd_type}{memo}   = $self->param('memo');

	#use Data::Dump;
	#Data::Dump->dump($data);

	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json {
				"svc"  => 'zjdz_qd_fhyd',
				"data" => $data,
				'sys'  => { 'oper_user' => $self->session->{uid}, },
			}
		)
	);
}

#方法名称:资金对账
sub zjdz {
	my $self   = shift;
	my $origin = shift;    #参数1
	my $data;
	for my $row ( @{$origin} ) {
		my $f_ch = $row->{f_ch};
		$data->{$f_ch}->{j_amt} += $row->{j_amt} || 0;
		$data->{$f_ch}->{d_amt} += $row->{d_amt} || 0;
	}
	return $data;
}

sub bfjgzcx {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/from to bfj_acct/) {
		my $p = $self->param($_);
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			bfj_acct => $params->{bfj_acct},
			e_date   => [
				0,
				$params->{from} && $self->quote( $params->{from} ),
				$params->{to}   && $self->quote( $params->{to} ),
			  ]

		}
	);

	my $sql = qq/
		select bfj_acct, e_date, blc, bsc, rownumber() over(order by e_date desc) as rowid
		from viw_blc_bsc
		$p->{condition} /;
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

1;
