package ZixWeb::Zjdz::Zjdz_fyp;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

#
#模块名称:需对账银行账户查询
#
sub fyp {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/from to fyp_acct/) {
		my $p = $self->param($_) || '';
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			fyp_acct => $params->{fyp_acct}
			  && $self->quote( $params->{fyp_acct} ),
			zjdz_date => [
				0,
				$params->{from} && $self->quote( $params->{from} ),
				$params->{to}   && $self->quote( $params->{to} ),
			],
			status => 1
		}
	);

	my $sql =
"select fyp_acct, zjdz_date,rownumber() over(order by zjdz_date asc) as rowid from job_dz_fyp_fhyd $p->{condition} ";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

#
#模块名称:需对账银行账户-对账 / 计算长短款
#
sub fypcheck {
	my $self = shift;
	my $data;

	# fyp_acct 电话卡充值易宝中间账户方编号
	my $fyp_acct = $self->param('fyp_acct');    #参数2
	$data->{fyp_acct} = $fyp_acct;

	#b_acct
	$data->{acct_name} = $self->fyp_acct->{$fyp_acct};

	# date
	my $zjbd_date = $self->param('zjbd_date');    #参数3
	$data->{zjbd_date} = $zjbd_date;

	#tag
	my $tag = $self->param('tag') || 0;

	my $p = $self->params(
		{
			period   => "'" . $zjbd_date . "'",
			fyp_acct => "'" . $fyp_acct . "'"
		}
	);
	my $condition = $p->{condition} || "";

	#此处查出的是zjdz_type的id
	my $yp_acct_fhyd_sql =
	    "select fyp_acct as fyp_acct,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_yp_acct_fhyd $condition "
	  . "group by fyp_acct";

	my $yufamt = $self->select($yp_acct_fhyd_sql)
	  || [ { fyp_acct => $fyp_acct, j_amt => 0, d_amt => 0 } ];

	#借贷金额累加
	$yufamt = $self->zjdz($yufamt);

	my $all;
	for my $fyp_acct ( keys %$yufamt ) {
		my $fyp_acct_name = $self->fyp_acct->{$fyp_acct};
		$all->{$fyp_acct_name} = [
			$self->nf( $yufamt->{$fyp_acct}->{j_amt} / 100 ),
			$self->nf( $yufamt->{$fyp_acct}->{d_amt} / 100 )
		];
	}

	my $length = keys %{$all};
	$all->{t_ids} = [ keys %{$all} ];
	$all->{l}     = $length;

	my ( $before, $chenge, $current, $predict, $lc, $sc ) = (
		$zjbd_date . "日前电话卡充值易宝中间账户余额",
		$zjbd_date . "日电话卡充值易宝中间账户预期变化",
		$zjbd_date . "日电话卡充值易宝中间账户预期余额",
		$zjbd_date . "日电话卡充值易宝中间账户实际余额",
		$zjbd_date . "日电话卡充值易宝中间账户长款",
		$zjbd_date . "日电话卡充值易宝中间账户短款",
	);
	$all->{ch_fyp} = [
		'易宝中间账户方资金变化',
		$before, $chenge, $current, $predict, $lc, $sc
	];

	my $quote_fyp_acct = $self->quote($fyp_acct);

	my $before_sql =
"select sum(j)-sum(d) as b from sum_yp_acct_fhyd where period<\'$zjbd_date\' and fyp_acct = $quote_fyp_acct ";
	my $before_amt = ( $self->select($before_sql) )->[0]->{b} || 0;

	my $chenge_sql =
"select sum(j)-sum(d) as b from sum_yp_acct_fhyd where period=\'$zjbd_date\' and fyp_acct = $quote_fyp_acct ";
	my $chenge_amt = ( $self->select($chenge_sql) )->[0]->{b} || 0;

	my $current_sql =
"select sum(j)-sum(d) as b from sum_yp_acct_fhyd where period<=\'$zjbd_date\' and fyp_acct = $quote_fyp_acct ";
	my $current_amt = ( $self->select($current_sql) )->[0]->{b} || 0;

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
	$chenge_amt /= 100;
	$all->{$chenge} = $self->nf($chenge_amt);
	$current_amt /= 100;
	$all->{$current} = $self->nf($current_amt);
	$ch /= 100;
	$all->{$predict} = $self->nf($ch);
	$lc_amt /= 100;
	$all->{$lc} = $self->nf($lc_amt);
	$sc_amt /= 100;
	$all->{$sc} = $self->nf($sc_amt);

	for (qw/l t_ids ch_fyp/) {
		$data->{$_} = delete $all->{$_};
	}
	$data->{data} = $all;
	$self->render( json => $data );
}

# 模块名称:需对账-对账完成
sub fypcheckdone {
	my $self = shift;
	my $data;

	# fyp_acct 电话卡充值易宝中间账户方编号
	my $fyp_acct = $self->param('fyp_acct');    #参数2
	$data->{fyp_acct} = $fyp_acct;

	#b_acct
	$data->{acct_name} = $self->fyp_acct->{$fyp_acct};

	# date
	my $zjbd_date = $self->param('zjbd_date');    #参数3
	$data->{zjbd_date} = $zjbd_date;

	my $quote_fyp_acct = $self->quote($fyp_acct);

	my $current_sql =
"select sum(j)-sum(d) as b from sum_yp_acct_fhyd where period<=\'$zjbd_date\' and fyp_acct = $quote_fyp_acct ";
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
				"svc"  => 'zjdz_fyp_fhyd',
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
		my $fyp_acct = $row->{fyp_acct};
		$data->{$fyp_acct}->{j_amt} += $row->{j_amt} || 0;
		$data->{$fyp_acct}->{d_amt} += $row->{d_amt} || 0;
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
