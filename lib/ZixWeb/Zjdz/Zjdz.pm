package ZixWeb::Zjdz::Zjdz;

use Mojo::Base 'Mojolicious::Controller';
use boolean;
use JSON::XS;

#
#模块名称:需对账银行账户查询
#
sub bfj {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $params = {};
	for (qw/from to b_acct/) {
		my $p = $self->param($_);
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}
	my $p->{condition} = '';
	$p = $self->params(
		{
			b_acct    => $params->{b_acct},
			zjdz_date => [
				0,
				$params->{from} && $self->quote( $params->{from} ),
				$params->{to}   && $self->quote( $params->{to} ),
			],
			type   => 1,
			status => 1
		}
	);

	my $sql =
"select b_acct, type, zjdz_date,rownumber() over(order by zjdz_date asc) as rowid from job_dz $p->{condition} ";
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

#
#模块名称:需对账银行账户-对账 / 计算长短款
#
sub bfjcheck {
	my $self = shift;
	my $data;

	# acct_id
	my $acct_id = $self->param('acct_id');    #参数2
	$data->{acct_id} = $acct_id;

	#b_acct
	$data->{b_acct} = $self->bfj_acct->{$acct_id};

	# date
	my $zjbd_date = $self->param('zjbd_date');    #参数3

	#tag
	my $tag = $self->param('tag') || 0;

	$data->{zjbd_date} = $zjbd_date;

	my $p = $self->params(
		{
			zjbd_date => "'" . $zjbd_date . "'",
			bfj_acct  => $acct_id
		}
	);
	my $condition = $p->{condition} || "";

	#此处查出的是zjdz_type的id
	my $yf_amt_sql =
	    "select zjbd_type as zjbd_id,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_txamt_yhyf $condition "
	  . "group by zjbd_type";

	my $yf_amt = $self->select($yf_amt_sql) || [];

	my $ys_amt_sql =
	    "select zjbd_type as zjbd_id,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_txamt_yhys $condition "
	  . "group by zjbd_type";

	my $ys_amt = $self->select($ys_amt_sql) || [];

	my $ys_fee_sql =
	    "select zjbd_type as zjbd_id,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_bfee_yhys $condition "
	  . "group by zjbd_type";

	my $ys_fee = $self->select($ys_fee_sql) || [];

	my $yf_fee_sql =
	    "select zjbd_type as zjbd_id,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_bfee_yhyf $condition "
	  . "group by zjbd_type";

	my $yf_fee = $self->select($yf_fee_sql) || [];

	$ys_amt = $self->zjdz($ys_amt);
	$ys_fee = $self->zjdz($ys_fee);
	$yf_fee = $self->zjdz($yf_fee);
	$yf_amt = $self->zjdz($yf_amt);

	my $all;
	for my $tid ( keys %$yf_amt ) {
		my $zjbd_type;
		$zjbd_type = $self->zjbd_type->{$tid};
		$all->{$zjbd_type}->{txamt_yhyf} =
		  [ $yf_amt->{$tid}->{j_amt} / 100, $yf_amt->{$tid}->{d_amt} / 100 ];
		$all->{$zjbd_type}->{zjbd_type_id} = $tid;
	}
	for my $tid ( keys %$yf_fee ) {
		my $zjbd_type;
		$zjbd_type = $self->zjbd_type->{$tid};
		$all->{$zjbd_type}->{bfee_yhyf} =
		  [ $yf_fee->{$tid}->{j_amt} / 100, $yf_fee->{$tid}->{d_amt} / 100 ];
		$all->{$zjbd_type}->{zjbd_type_id} = $tid;
	}
	for my $tid ( keys %$ys_amt ) {
		my $zjbd_type;
		$zjbd_type = $self->zjbd_type->{$tid};
		$all->{$zjbd_type}->{txamt_yhys} =
		  [ $ys_amt->{$tid}->{j_amt} / 100, $ys_amt->{$tid}->{d_amt} / 100 ];
		$all->{$zjbd_type}->{zjbd_type_id} = $tid;
	}
	for my $tid ( keys %$ys_fee ) {
		my $zjbd_type;
		$zjbd_type = $self->zjbd_type->{$tid};
		$all->{$zjbd_type}->{bfee_yhys} =
		  [ $ys_fee->{$tid}->{j_amt} / 100, $ys_fee->{$tid}->{d_amt} / 100 ];
		$all->{$zjbd_type}->{zjbd_type_id} = $tid;
	}

	#########处理未知长短款###############
	$all->{"未知入款"}->{ch_j} = $self->uf( $self->param("未知入款_j") )
	  || 0;    #参数4
	$all->{"未知入款"}->{ch_d} = $self->uf( $self->param("未知入款_d") )
	  || 0;    #参数5
	$all->{"未知入款"}->{txamt_yhys} = [ "0", "0" ];
	$all->{"未知入款"}->{txamt_yhyf} = [ "0", "0" ];
	$all->{"未知入款"}->{bfee_yhys}  = [ "0", "0" ];
	$all->{"未知入款"}->{bfee_yhyf}  = [ "0", "0" ];
	$all->{"未知入款"}->{zjbd_type_id} = '-6';

	$all->{"未知出款"}->{ch_j} = $self->uf( $self->param("未知出款_j") )
	  || 0;    #参数5
	$all->{"未知出款"}->{ch_d} = $self->uf( $self->param("未知出款_d") )
	  || 0;    #参数5
	$all->{"未知出款"}->{txamt_yhys} = [ "0", "0" ];
	$all->{"未知出款"}->{txamt_yhyf} = [ "0", "0" ];
	$all->{"未知出款"}->{bfee_yhys}  = [ "0", "0" ];
	$all->{"未知出款"}->{bfee_yhyf}  = [ "0", "0" ];
	$all->{"未知出款"}->{zjbd_type_id} = '-7';
	my $length = keys %{$all};
	$all->{t_ids} = [ keys %{$all} ];

	$all->{l}       = $length;
	$all->{records} = ( $length + 1 ) * 7 + 5;

	for ( @{ $all->{t_ids} } ) {
		$all->{$_}->{ch_j} = $self->uf( $self->param( $_ . "_j" ) )
		  || 0;    #参数4
		$all->{$_}->{ch_d} = $self->uf( $self->param( $_ . "_d" ) )
		  || 0;    #参数5
		$all->{$_}->{memo} = $self->param( $_ . "_memo" )
		  || "";
	}
	my @zjbd = ( @{ $all->{t_ids} } );
	@zjbd = grep { $_ ne "未知出款" && $_ ne "未知入款" } @zjbd;

	#总计
	$self->get_sum( $all, $tag );
	$all->{t_ids} = [ @zjbd, "未知入款", "未知出款", "总计" ];
	$all->{length}++;
	my $ch_j = $all->{"总计"}{ch_j};
	my $ch_d = $all->{"总计"}{ch_d};
	my $ch   = $ch_j - $ch_d;

	#金额数据格式化
	for my $o ( @{ $all->{t_ids} } ) {
		for my $k (qw/txamt_yhyf txamt_yhys bfee_yhyf bfee_yhys sc lc/) {
			$all->{$o}{$k}[0] = $self->nf( $all->{$o}{$k}[0] );
			$all->{$o}{$k}[1] = $self->nf( $all->{$o}{$k}[1] );
		}
		$all->{$o}{ch_j} = $self->nf( $all->{$o}{ch_j} );
		$all->{$o}{ch_d} = $self->nf( $all->{$o}{ch_d} );
	}

	my ( $before, $current, $predict ) = (
		$zjbd_date . "前银行存款余额",
		$zjbd_date . "日银行存款变化",
		$zjbd_date . "预期银行存款余额"
	);
	$all->{ch_bank} = [ '银行存款变化', $before, $current, $predict ];
	my $before_sql =
"select sum(j)-sum(d) as b from sum_deposit_bfj where period<\'$zjbd_date\' and bfj_acct = $acct_id";
	my $before_amt = ( $self->select($before_sql) )->[0]->{b} || 0;
	$before_amt /= 100;
	$all->{$before}  = $self->nf($before_amt);
	$all->{$current} = $self->nf($ch);
	$all->{$predict} = $self->nf( $before_amt + $ch );

	for (qw/l records t_ids ch_bank/) {
		$data->{$_} = delete $all->{$_};
	}
	$data->{data} = $all;
	$data->{real_bank_ch} = $self->param('real_bank_ch') || '';
	$self->render( json => $data );
}

# 模块名称:需对账银行账户-对账完成
sub bfjcheckdone {
	my $self = shift;
	my $data;
	my $r = {};    #响应对账结果

	# type
	my $type = $self->param('type');    #参数1
	$data->{acct_type} = 1;

	# acct_id
	my $acct_id = $self->param('acct_id') || "";    #参数2
	$data->{acct_id} = $acct_id;

	#b_acct
	$r->{b_acct} = $self->bfj_acct->{$acct_id};

	#date
	my $zjbd_date = $self->param('zjbd_date') || "";    #参数3
	$data->{zjbd_date} = $zjbd_date;
	$zjbd_date = $self->quote($zjbd_date) if $zjbd_date;

	$r->{zjbd_date} = $zjbd_date;

	my $p = $self->params(
		{
			zjbd_date => $zjbd_date,
			bfj_acct  => $acct_id
		}
	);
	my $condition = $p->{condition} || "";

	my $ys_amt_sql =
	    "select zjbd_type as zjbd_id,zjbd_date,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_txamt_yhys $condition"
	  . "group by zjbd_date,zjbd_type ";
	my $ys_amt = $self->select($ys_amt_sql) || [];

	my $yf_amt_sql =
	    "select zjbd_type zjbd_id,zjbd_date,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_txamt_yhyf $condition"
	  . "group by zjbd_date,zjbd_type ";
	my $yf_amt = $self->select($yf_amt_sql) || [];

	my $yf_fee_sql =
	    "select zjbd_type zjbd_id,zjbd_date,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_bfee_yhyf $condition"
	  . "group by zjbd_date,zjbd_type ";
	my $yf_fee = $self->select($yf_fee_sql) || [];

	my $ys_fee_sql =
	    "select zjbd_type zjbd_id,zjbd_date,sum(j) as j_amt,sum(d) as d_amt "
	  . "from sum_bfee_yhys $condition"
	  . "group by zjbd_date,zjbd_type ";
	my $ys_fee = $self->select($ys_fee_sql) || [];

	$ys_amt = $self->zjdz($ys_amt);
	$ys_fee = $self->zjdz($ys_fee);
	$yf_fee = $self->zjdz($yf_fee);
	$yf_amt = $self->zjdz($yf_amt);

	my $all;
	for my $zjbd_type ( keys %{$yf_amt} ) {
		$all->{$zjbd_type}->{txamt_yhyf} =
		  [ $yf_amt->{$zjbd_type}->{j_amt}, $yf_amt->{$zjbd_type}->{d_amt} ];
	}
	for my $zjbd_type ( keys %{$yf_fee} ) {
		$all->{$zjbd_type}->{bfee_yhyf} =
		  [ $yf_fee->{$zjbd_type}->{j_amt}, $yf_fee->{$zjbd_type}->{d_amt} ];
	}
	for my $zjbd_type ( keys %{$ys_amt} ) {
		$all->{$zjbd_type}->{txamt_yhys} =
		  [ $ys_amt->{$zjbd_type}->{j_amt}, $ys_amt->{$zjbd_type}->{d_amt} ];
	}
	for my $zjbd_type ( keys %{$ys_fee} ) {
		$all->{$zjbd_type}->{bfee_yhys} =
		  [ $ys_fee->{$zjbd_type}->{j_amt}, $ys_fee->{$zjbd_type}->{d_amt} ];
	}

	####其他长款
	$all->{'-6'}->{txamt_yhyf} = [ "0", "0" ];
	$all->{'-6'}->{txamt_yhys} = [ "0", "0" ];
	$all->{'-6'}->{bfee_yhys}  = [ "0", "0" ];
	$all->{'-6'}->{bfee_yhyf}  = [ "0", "0" ];

	####其他短款
	$all->{'-7'}->{txamt_yhyf} = [ "0", "0" ];
	$all->{'-7'}->{txamt_yhys} = [ "0", "0" ];
	$all->{'-7'}->{bfee_yhys}  = [ "0", "0" ];
	$all->{'-7'}->{bfee_yhyf}  = [ "0", "0" ];

	$all->{t_ids} = [ keys %{$all} ];

	for ( @{ $all->{t_ids} } ) {
		my $c_j;
		my $c_d;
		if ( $_ == '-6' ) {    ##未知入款
			$c_j = $self->uf( $self->param("未知入款_j") ) || 0;
			$c_d = $self->uf( $self->param("未知入款_d") ) || 0;
			$data->{zjbd_type}->{$_}->{memo} = $self->param('未知入款_memo')
			  || '';
		}
		elsif ( $_ == '-7' ) {    ##未知出款
			$c_j = $self->uf( $self->param("未知出款_j") ) || 0;
			$c_d = $self->uf( $self->param("未知出款_d") ) || 0;
			$data->{zjbd_type}->{$_}->{memo} = $self->param('未知出款_memo')
			  || '';
		}
		else {
			$c_j = $self->uf( $self->param( $self->zjbd_type->{$_} . "_j" ) )
			  || 0;               #参数4
			$c_d = $self->uf( $self->param( $self->zjbd_type->{$_} . "_d" ) )
			  || 0;               #参数5
			$data->{zjbd_type}->{$_}->{memo} =
			  $self->param( $self->zjbd_type->{$_} . '_memo' ) || '';
		}
		$data->{zjbd_type}->{$_}->{ch_j} = ( sprintf "%.2f", $c_j ) * 100;
		$data->{zjbd_type}->{$_}->{ch_d} = ( sprintf "%.2f", $c_d ) * 100;
	}
	$data->{real_bank_ch} = $self->uf( $self->param('real_bank_ch') ) * 100;
	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json {
				"svc"  => 'zjdz',
				"data" => $data,
				'sys'  => { 'oper_user' => $self->session->{uid}, },
			}
		)
	);
}

#方法名称:总计
sub get_sum {

	my $self = shift;
	my $all  = shift;
	my $tag  = shift;              #参数1
	my $sum  = $all->{"总计"};

	# 计算长短款
	for my $key ( @{ $all->{t_ids} } ) {
		my $total_j = 0;
		my $total_d = 0;
		for my $k0 (qw/txamt_yhyf bfee_yhyf txamt_yhys bfee_yhys/) {
			$total_j += $all->{$key}->{$k0}->[0] || 0;
			$total_d += $all->{$key}->{$k0}->[1] || 0;
		}
		my $change = $total_j - $total_d;
		$change = $all->{$key}->{ch_j} - $all->{$key}->{ch_d} - $change;
		my @sc = ( 0, 0 );
		my @lc = ( 0, 0 );
		if ( $change > 0 ) {
			if ($tag) {
				$all->{$key}->{ch_d} = $change;
			}
			else {
				$lc[1] = $change;
			}
		}
		elsif ( $change < 0 ) {
			if ($tag) {
				$all->{$key}->{ch_j} = -$change;
			}
			else {
				$sc[0] = -$change;
			}
		}
		$all->{$key}->{sc} = [@sc];
		$all->{$key}->{lc} = [@lc];
	}

	my ( $sum_ch_d, $sum_ch_j, $sc0, $sc1, $lc0, $lc1 ) = ( 0, 0, 0, 0, 0, 0 );

	for my $key ( @{ $all->{t_ids} } ) {
		for my $k0 (qw/txamt_yhyf bfee_yhyf txamt_yhys bfee_yhys/) {
			$sum->{$k0}->[0] += $all->{$key}->{$k0}->[0] || 0;
			$sum->{$k0}->[1] += $all->{$key}->{$k0}->[1] || 0;
		}
		$sc0      += $all->{$key}->{sc}->[0];
		$sc1      += $all->{$key}->{sc}->[1];
		$lc0      += $all->{$key}->{lc}->[0];
		$lc1      += $all->{$key}->{lc}->[1];
		$sum_ch_d += $all->{$key}->{ch_d};
		$sum_ch_j += $all->{$key}->{ch_j};
	}
	for my $key ( @{ $all->{t_ids} } ) {
		$sum->{ch_d}         = $sum_ch_d;
		$sum->{ch_j}         = $sum_ch_j;
		$sum->{sc}           = [ $sc0, $sc1 ];
		$sum->{lc}           = [ $lc0, $lc1 ];
		$all->{$key}->{ch_j} = $all->{$key}->{ch_j};
		$all->{$key}->{ch_d} = $all->{$key}->{ch_d};
	}
	$all->{"总计"} = $sum;

}

#方法名称:资金对账
sub zjdz {
	my $self   = shift;
	my $origin = shift;    #参数1
	my $data;
	for my $row ( @{$origin} ) {
		my $j_amt = $row->{j_amt} || 0;
		my $d_amt = $row->{d_amt} || 0;
		my $zjbd_type = $row->{zjbd_id};
		if ( $j_amt > $d_amt ) {
			$j_amt -= $d_amt;
			$d_amt = 0;
		}
		elsif ( $j_amt == $d_amt ) {
			$j_amt = 0;
			$d_amt = 0;
		}
		else {
			$d_amt -= $j_amt;
			$j_amt = 0;
		}
		$data->{$zjbd_type} = {
			j_amt => $j_amt,
			d_amt => $d_amt,
		};
	}
	return $data;
}

sub bfjgzcx {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	# bfj_acct
	my $bfj_acct = $self->param('bfj_acct');

	# zjbd_type
	my $zjbd_type = $self->param('zjbd_type');

	#period
	my $period_from = $self->param('period_from') || '';
	my $period_to   = $self->param('period_to')   || '';

	#e_date
	my $e_date_from = $self->param('e_date_from') || '';
	my $e_date_to   = $self->param('e_date_to')   || '';

	my ( $fir, $sec, $thi, $fou );
	$fir = $self->param('fir');
	$sec = $self->param('sec');
	$thi = $self->param('thi');
	$fou = $self->param('fou');
	unless ( $fir || $sec || $thi || $fou ) {
		$fir = 'bfj_acct';
		$sec = 'zjbd_type';
		$thi = 'e_date';
		$fou = 'period';
	}
	my $fields = join ',', grep { $_ } ( $fir, $sec, $thi, $fou );

	my $p = $self->params(
		{
			bfj_acct  => $bfj_acct,
			zjbd_type => $zjbd_type,
			period => [ $self->quote($period_from), $self->quote($period_to) ],
			e_date => [
				0,
				$e_date_from && $self->quote($e_date_from),
				$e_date_to   && $self->quote($e_date_to)
			],

		}
	);
	my $condition = $p->{condition};
	my $sql       = qq/
		select $fields,sum(blc) as blc,sum(bsc) as bsc,rownumber() over() as rowid
		from viw_blc_bsc
		$p->{condition} group by $fields/;
	my $data = $self->page_data( $sql, $page, $limit );
	$data->{success} = true;
	$self->render( json => $data );
}

sub bfjrefresh_mqt {
	my $self = shift;
	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json( { svc => "refresh_mqt" } )
		)
	);
}
1;
