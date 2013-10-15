package ZixWeb::Zjdz::Zjdz;

use Mojo::Base 'Mojolicious::Controller';
use POSIX qw/mktime/;
use utf8;
use DateTime;
use boolean;
use JSON::XS;

use constant { DEBUG => $ENV{RECONCILIATION_DEBUG} || 0, };

BEGIN {
	require Data::Dump if DEBUG;
}

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

	##其它
	$all->{"其它"}->{txamt_yhys} = [ "0", "0" ];
	$all->{"其它"}->{txamt_yhyf} = [ "0", "0" ];
	$all->{"其它"}->{bfee_yhys}  = [ "0", "0" ];
	$all->{"其它"}->{bfee_yhyf}  = [ "0", "0" ];
	$all->{"其它"}->{zjbd_type_id} = 0;

	my $length = keys %{$all};
	$all->{t_ids} = [ keys %{$all} ];

	$all->{l}       = $length;
	$all->{records} = ( $length + 1 ) * 7 + 5;

	for ( @{ $all->{t_ids} } ) {
		$all->{$_}->{ch_j} = $self->uf( $self->param( $_ . "_j" ) )
		  || 0;    #参数4
		$all->{$_}->{ch_d} = $self->uf( $self->param( $_ . "_d" ) )
		  || 0;    #参数5
	}

	#sort delete "其它"
	my @zjbd = ( @{ $all->{t_ids} } );
	@zjbd = grep { $_ ne "其它" } @zjbd;

	#总计
	$self->get_sum($all);
	$all->{t_ids} = [ @zjbd, "其它", "总计" ];
	$all->{length}++;
	my $ch_j = $all->{"总计"}{ch_j};
	my $ch_d = $all->{"总计"}{ch_d};
	my $ch   = $ch_j - $ch_d;

	#金额数据格式化
	my $tag = $self->param('tag');
	for my $o ( @{ $all->{t_ids} } ) {
		for my $k (qw/txamt_yhyf txamt_yhys bfee_yhyf bfee_yhys sc lc/) {
			$all->{$o}{$k}[0] = $self->nf( $all->{$o}{$k}[0] );
			$all->{$o}{$k}[1] = $self->nf( $all->{$o}{$k}[1] );
		}
		$all->{$o}{ch_j} = $self->nf( $all->{$o}{ch_j} );
		$all->{$o}{ch_d} = $self->nf( $all->{$o}{ch_d} );
		if ($tag) {
			$all->{$o}->{ch_j} = $all->{$o}{lc}[1];
			$all->{$o}{lc}[1]  = '0.00';
			$all->{$o}->{ch_d} = $all->{$o}{sc}[0];
			$all->{$o}{sc}[0]  = '0.00';
		}
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

####################################################
#
# 模块名称:需对账银行账户-对账完成
#
# param: acct_type 账户分类
#       acct_id   账户id
#       zjbd_date 资金对账日期
#       XXXX_j    某资金变动类型银行存款借方变动金额
#       XXXX_d    某资金变动类型银行存款贷方变动金额
#
# return:  hash类型的数据集合
#例:
#{
#  b_acct    => "\x{519C}\x{4E1A}\x{94F6}\x{884C}\x{6DF1}\x{5733}\x{4E0A}\x{6B65}\x{652F}\x{884C}-41-004300040017055",
#  status    => 0,
#  zjbd_date => "'2013-03-25'",
#}
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
	####other
	$all->{0}->{txamt_yhyf} = [ "0", "0" ];
	$all->{0}->{txamt_yhys} = [ "0", "0" ];
	$all->{0}->{bfee_yhys}  = [ "0", "0" ];
	$all->{0}->{bfee_yhyf}  = [ "0", "0" ];

	$all->{t_ids} = [ keys %{$all} ];

	for ( @{ $all->{t_ids} } ) {
		my $c_j;
		my $c_d;
		if ( $_ == 0 ) {
			$c_j = $self->uf( $self->param("其它_j") ) || 0;
			$c_d = $self->uf( $self->param("其它_d") ) || 0;
		}
		else {
			$c_j = $self->uf( $self->param( $self->zjbd_type->{$_} . "_j" ) )
			  || 0;    #参数4
			$c_d = $self->uf( $self->param( $self->zjbd_type->{$_} . "_d" ) )
			  || 0;    #参数5
		}
		$data->{zjbd_type}->{$_}->{ch_j} = int( $c_j * 100 );
		$data->{zjbd_type}->{$_}->{ch_d} = int( $c_d * 100 );
	}
	my $user = $self->session->{uid};
	my $res  = $self->ua->post(
		$self->configure->{svc_url},
		encode_json {
			"svc"  => 'zjdz',
			"data" => $data,
			'sys'  => { 'oper_user' => $user, },
		}
	)->res->json->{status};
	if ( $res == 0 ) {
		$r->{success} = true;
	}
	else {
		$r->{success} = false;
	}
	$self->render( json => $r );
}

#
#方法名称:总计
#       $self->get_sum( $all, $tag );
#
#param: $all 某账户各资金变动类型下各科目对应的金额
#       $tag
#return:hash
#{
#  bfee_yhyf => [0, 0],
#  bfee_yhys => [0, 0],
#  ch_d => 0,
#  ch_j => 43197281,
#  lc => [0, 0],
#  sc => [0, 0],
#  txamt_yhyf => [0, 0],
#  txamt_yhys => [43197281, 0],
#}
sub get_sum {

	my $self = shift;
	my $all  = shift;              #参数1
	my $sum  = $all->{"总计"};

	#Caculate short and long
	for my $key ( @{ $all->{t_ids} } ) {
		my $total_j = 0;
		my $total_d = 0;
		for my $k0 (qw/txamt_yhyf bfee_yhyf txamt_yhys bfee_yhys/) {
			$total_j += $all->{$key}->{$k0}->[0] || 0;
			$total_d += $all->{$key}->{$k0}->[1] || 0;
		}
		my $change = $total_j - $total_d;
		$change = $all->{$key}->{ch_j} - $all->{$key}->{ch_d} - $change;
		my @sc = ( "0", "0" );
		my @lc = ( "0", "0" );
		if ( $change > 0 ) {
			$lc[1] = $change;
		}
		elsif ( $change < 0 ) {
			$sc[0] = -$change;
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

#
#方法名称:资金对账
#
#param :$origin
#      格式format { d_amt => 2700, j_amt => 0, zjbd_id => 7 }]
#
#return:{ 7 => { d_amt => 2700, j_amt => 0 } }
#
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
	my $data;
	my $dt       = DateTime->now( time_zone => 'local' );
	my $beg_date = $dt->ymd('-');
	my $end_date = $self->next_n_date( -6, $beg_date );
	my @dates;
	for ( my $i = 6 ; $i >= 0 ; $i-- ) {
		my $cur_date = $self->next_n_date( $i, $end_date );
		push @dates, $cur_date;
	}

	# 查询有挂帐的帐号和资金变动类型
	my $records = $self->select(
		" select bfj_acct, zjbd_type, (sum(d) - sum(j)) total
                            from book_blc
                            group by bfj_acct, zjbd_type
                            union
                            (select bfj_acct, zjbd_type, (sum(j) - sum(d)) total
                            from book_bsc
                            group by bfj_acct, zjbd_type)"
	);
	my @accts;
	my $acct_zjbd_types;
	for my $row (@$records) {
		push @accts, $row->{bfj_acct}
		  unless ( grep( /$row->{bfj_acct}/, @accts ) );
		push @{ $acct_zjbd_types->{ $row->{bfj_acct} } }, $row->{zjbd_type}
		  unless (
			grep( /$row->{zjbd_type}/,
				@{ $acct_zjbd_types->{ $row->{bfj_acct} } } )
		  );
	}
	$data->{accts} = [@accts];

	# 计算七天前每天的挂帐
	$data->{data} =
	  $self->data_between( $end_date, $beg_date, \@dates, $acct_zjbd_types );

	$data->{dates} = [@dates];

	# 计算按资金变动类型和帐号汇总的挂帐
	$data->{sum_total} = $self->sum_by_zjbd_type;

	my $heji;

	my $acct_rowspan;
	for (@accts) {
		$heji->{$_} = delete $data->{data}->{$_}->{heji};
		my @zjbd_types = keys %{ $data->{sum_total}->{$_} };
		$acct_rowspan->{$_} = ( @{ $acct_zjbd_types->{$_} } + 1 ) * 2;
	}

	# 计算七天前的挂帐情况
	$data->{sum_week} =
	  $self->cal_week( $data->{data}, [@dates], $data->{sum_total} );

	# 总累计
	$data->{total_sum} =
	  $self->cal_total( $data->{data}, [@dates], $data->{sum_week},
		$data->{sum_total}, $acct_zjbd_types );
	$data->{total_sum}->{week}->{lc} =
	  $data->{total_sum}->{total}->{lc} - $data->{total_sum}->{week}->{lc};
	$data->{total_sum}->{week}->{sc} =
	  $data->{total_sum}->{total}->{sc} - $data->{total_sum}->{week}->{sc};
	$data->{heji}            = $heji;
	$data->{acct_zjbd_types} = $acct_zjbd_types;
	$data->{acct_rowspan}    = $acct_rowspan;
	$self->render( json => $data );
}

#
# $self->data_between($beg_date, $end_date);
#
#
sub data_between {
	my $self            = shift;
	my $date_beg        = shift;
	my $date_end        = shift;
	my $dates           = shift;
	my $acct_zjbd_types = shift;
	my $data;

	# short currency
	my $sc = $self->select(
		"select sum(j) as j_amt, sum(d) as d_amt, bfj_acct, e_date, zjbd_type 
                                from book_bsc 
                                where e_date >= "
		  . $self->quote($date_beg)
		  . " and e_date <= "
		  . $self->quote($date_end)
		  . "group by bfj_acct, zjbd_type, e_date"
	);
	if ( $sc && @$sc ) {
		for my $row (@$sc) {
			my $j_amt = $row->{j_amt} || 0;
			my $d_amt = $row->{d_amt} || 0;
			my $acct  = $row->{bfj_acct};
			my $zjbd_type = $row->{zjbd_type};
			my $e_date    = $row->{e_date};
			my $amt       = $j_amt - $d_amt;

			$data->{$acct}->{$zjbd_type}->{$e_date}->{sc} = $amt;
			$data->{$acct}->{heji}->{$e_date}->{sc} += $amt;
		}
	}

	# long currency
	my $lc = $self->select(
		"select sum(j) as j_amt, sum(d) as d_amt, bfj_acct, e_date, zjbd_type
                                from book_blc
                                where e_date >= "
		  . $self->quote($date_beg)
		  . " and e_date <= "
		  . $self->quote($date_end)
		  . "group by bfj_acct, zjbd_type, e_date"
	);
	if ( $lc && @$lc ) {
		for my $row (@$lc) {
			my $j_amt = $row->{j_amt} || 0;
			my $d_amt = $row->{d_amt} || 0;
			my $acct  = $row->{bfj_acct};
			my $zjbd_type = $row->{zjbd_type};
			my $e_date    = $row->{e_date};
			my $amt       = $d_amt - $j_amt;
			$data->{$acct}->{$zjbd_type}->{$e_date}->{lc} = $amt;
			$data->{$acct}->{heji}->{$e_date}->{lc} += $amt;
		}
	}

	for my $acct ( keys %$acct_zjbd_types ) {
		for my $zjbd_type ( @{ $acct_zjbd_types->{$acct} } ) {
			for (@$dates) {
				$data->{$acct}{$zjbd_type}{$_}{sc} ||= 0;
				$data->{$acct}{$zjbd_type}{$_}{lc} ||= 0;
			}
		}
		for (@$dates) {
			$data->{$acct}{heji}{$_}{sc} ||= 0;
			$data->{$acct}{heji}{$_}{lc} ||= 0;
		}
	}
	return $data;
}

#
# $self->sum_by_zjbd_type;
#
#
sub sum_by_zjbd_type {
	my $self = shift;
	my $data;

	# short currency
	my $sc = $self->select(
'select sum(j) as j_amt, sum(d) as d_amt, bfj_acct, zjbd_type from book_bsc group by bfj_acct, zjbd_type'
	);
	if ( $sc && @$sc ) {
		for my $row (@$sc) {
			my $j_amt = $row->{j_amt} || 0;
			my $d_amt = $row->{d_amt} || 0;
			my $zjbd_type = $row->{zjbd_type};
			my $acct      = $row->{bfj_acct};
			my $amt       = $j_amt - $d_amt;

			$data->{$acct}->{$zjbd_type}->{sc} = $amt;
			$data->{$acct}->{heji}->{sc} += $amt;
		}
	}

	# long currency
	my $lc = $self->select(
'select sum(j) as j_amt, sum(d) as d_amt, bfj_acct, zjbd_type from book_blc group by bfj_acct, zjbd_type'
	);
	if ( $lc && @$lc ) {
		for my $row (@$lc) {
			my $j_amt = $row->{j_amt} || 0;
			my $d_amt = $row->{d_amt} || 0;
			my $zjbd_type = $row->{zjbd_type};
			my $acct      = $row->{bfj_acct};
			my $amt       = $d_amt - $j_amt;
			$data->{$acct}->{$zjbd_type}->{lc} = $amt;
			$data->{$acct}->{heji}->{lc} += $amt;
		}
	}

	# 补齐没有数据的项
	for my $acct ( keys %$data ) {
		for my $type ( keys %{ $data->{$acct} } ) {
			$data->{$acct}{$type}{sc} ||= 0;
			$data->{$acct}{$type}{lc} ||= 0;
		}
	}
	return $data;
}

#
# $self->cal_week($data, @dates);
#
#
sub cal_week {
	my $self      = shift;
	my $data      = shift;
	my $dates     = shift;
	my $sum_total = shift;
	my $week_sum;
	for my $acct ( keys %{$sum_total} ) {
		my $total_sc = 0;
		my $total_lc = 0;
		for my $zjbd_type ( keys %{ $sum_total->{$acct} } ) {
			next if $zjbd_type eq 'heji';
			my $lc = 0;
			my $sc = 0;
			for ( @{$dates} ) {
				if ( $data->{$acct}->{$zjbd_type}->{$_}->{lc} ) {
					$lc       += $data->{$acct}->{$zjbd_type}->{$_}->{lc};
					$total_lc += $data->{$acct}->{$zjbd_type}->{$_}->{lc};
				}
				if ( $data->{$acct}->{$zjbd_type}->{$_}->{sc} ) {
					$sc       += $data->{$acct}->{$zjbd_type}->{$_}->{sc};
					$total_sc += $data->{$acct}->{$zjbd_type}->{$_}->{sc};
				}
			}
			$week_sum->{$acct}->{$zjbd_type}->{sc} =
			  $sum_total->{$acct}->{$zjbd_type}->{sc} - $sc;
			$week_sum->{$acct}->{$zjbd_type}->{lc} =
			  $sum_total->{$acct}->{$zjbd_type}->{lc} - $lc;
		}
		$week_sum->{$acct}->{heji}->{sc} =
		  $sum_total->{$acct}->{heji}->{sc} - $total_sc;
		$week_sum->{$acct}->{heji}->{lc} =
		  $sum_total->{$acct}->{heji}->{lc} - $total_lc;
	}

	return $week_sum;
}

#
# $self->cal_total($data, \@dates, $sum_week, $sum_total);
#
#
sub cal_total {
	my $self = shift;

	my $data           = shift;
	my $dates          = shift;
	my $sum_week       = shift;
	my $sum_total      = shift;
	my $acct_zjbd_type = shift;
	my $total_sum;
	$total_sum->{total}->{sc} = 0;
	$total_sum->{total}->{lc} = 0;
	for my $acct ( keys %$acct_zjbd_type ) {

		for my $zjbd_type ( @{ $acct_zjbd_type->{$acct} } ) {
			if ( $sum_total->{$acct}->{$zjbd_type}->{sc} ) {
				$total_sum->{total}->{sc} +=
				  $sum_total->{$acct}->{$zjbd_type}->{sc};
			}
			if ( $sum_total->{$acct}->{$zjbd_type}->{lc} ) {
				$total_sum->{total}->{lc} +=
				  $sum_total->{$acct}->{$zjbd_type}->{lc};
			}
		}
	}

	#total_by_week
	$total_sum->{week}->{sc} = 0;
	$total_sum->{week}->{lc} = 0;
	for my $date ( @{$dates} ) {

		#total_by_day
		$total_sum->{$date}->{sc} = 0;
		$total_sum->{$date}->{lc} = 0;
		for my $acct ( keys %$acct_zjbd_type ) {
			for my $zjbd_type ( @{ $acct_zjbd_type->{$acct} } ) {
				if ( $data->{$acct}->{$zjbd_type}->{$date}->{sc} ) {
					$total_sum->{$date}->{sc} +=
					  $self->uf( $data->{$acct}->{$zjbd_type}->{$date}->{sc} );
					$total_sum->{week}->{sc} +=
					  $self->uf( $data->{$acct}->{$zjbd_type}->{$date}->{sc} );
				}
				if ( $data->{$acct}->{$zjbd_type}->{$date}->{lc} ) {
					$total_sum->{$date}->{lc} +=
					  $self->uf( $data->{$acct}->{$zjbd_type}->{$date}->{lc} );
					$total_sum->{week}->{lc} +=
					  $self->uf( $data->{$acct}->{$zjbd_type}->{$date}->{lc} );
				}
			}
		}
	}
	return $total_sum;
}

sub next_n_date {
	my $self = shift;
	my $n    = shift;
	my $date = shift;
	$date =~ s/\-//g;
	my $epoch = get_epoch_time($date);
	$epoch += $n * 24 * 60 * 60;
	my ( $y, $m, $d ) = ( localtime($epoch) )[ 5, 4, 3 ];
	$y += 1900;
	$m += 1;
	return sprintf( "%04d-%02d-%02d", $y, $m, $d );
}

sub get_epoch_time {
	my $date = shift;
	unless ( $date =~ /(\d{4})(\d{2})(\d{2})/ ) {
		return undef;
	}
	else {
		return mktime( 0, 0, 0, $3, $2 - 1, $1 - 1900 );
	}
}

1;
