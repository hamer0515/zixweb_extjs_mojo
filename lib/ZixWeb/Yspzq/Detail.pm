package ZixWeb::Yspzq::Detail;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

sub detail {

	my $self   = shift;
	my $data   = [];
	my $detail = {};
	$detail->{properties} = [];

	#ys_type
	my $ys_type = $self->param('ys_type');    #参数1

	#ys_id
	my $ys_id = $self->param('ys_id');        #参数2

	#该yspz非公共字段 {zyzj_acct=>"自有资金账户"}
	my $yspz_zd = $self->dict->{types}->{ 'yspz_' . $ys_type };

	#ys_data
	my $ys_data = $self->select("select * from yspz_$ys_type where id =$ys_id");
	$ys_data = $ys_data->[0];

	#flag 是否撤销
	$detail->{period} = $ys_data->{period};
	$detail->{title} =
	  $ys_type . $self->ys_type->{$ys_type} . "原始凭证详细信息";
	$detail->{isdetail} = true;
	$detail->{ys_id}    = $ys_id;
	$detail->{ys_type}  = $ys_type;
	$detail->{cause}    = delete $ys_data->{cause} if exists $ys_data->{cause};
	$detail->{memo}     = delete $ys_data->{memo};
	$detail->{revoke_cause} = delete $ys_data->{revoke_cause};
	$detail->{revoke_flag}  = $ys_data->{flag};

	# 数据格式化和转意
	$self->transform($ys_data);
	my $yspz_item = [ keys %{$yspz_zd} ];

	#yspz公共字段
	my $public = {
		id               => "原始凭证ID",
		status           => "原始凭证处理状态",
		flag             => "撤销状态",
		revoke_user_name => "撤销者",
		ts_revoke        => "撤销时间",
		ts_c             => "创建时间",
		crt_id_name      => "录入员",
		group            => "原始凭证组ID"
	};

	#凭证详细第一部分
	my @p1;
	for (
		qw/ssn period tx_type matcher bfee clear_date
		tx_amt tx_date ftx_date e_data fe_date bfj_acct_bj
		zjbd_date_in zjbd_date_bj bi zjbd_date_out zjbd_date_out_bj/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p1, $property;
	}
	push @{ $detail->{properties} }, \@p1 if scalar(@p1) > 0;

	#凭证详细第二部分
	my @p2;
	for (
		qw/cwwf_bfee cwwf_bfee_1 bfee bfee_1
		cwwf_bfee_2 bfee_2
		cwwf_bfee_3 bfee_3
		cwwf_bfee_4 bfee_4
		cwwf_bfee_5 bfee_5/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p2, $property;
	}
	push @{ $detail->{properties} }, \@p2 if scalar(@p2) > 0;

	#凭证详细第三部分
	my @p3;
	for (
		qw/zg_bfee zg_bfee_1 fp fp_1 zg_bfee_1_back
		zg_bfee_2 fp_2 zg_bfee_2_back
		zg_bfee_3 fp_3 zg_bfee_3_back
		zg_bfee_4 fp_4 zg_bfee_4_back
		zg_bfee_5 fp_5 zg_bfee_5_back/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p3, $property;
	}
	push @{ $detail->{properties} }, \@p3 if scalar(@p3) > 0;

	#凭证详细第四部分
	my @p4;
	for (
		qw/cwwf_bfee_1_back bfee_back bfee_1_back
		cwwf_bfee_2_back bfee_2_back
		cwwf_bfee_3_back bfee_3_back
		cwwf_bfee_4_back bfee_4_back
		cwwf_bfee_5_back bfee_5_back/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p4, $property;
	}
	push @{ $detail->{properties} }, \@p4 if scalar(@p4) > 0;

	#凭证详细第五部分
	my @p5;
	for (
		qw/bfj_acct bfj_acct_1 zjbd_date_out zjbd_date_out_1 zjbd_date_in zjbd_date_in_1
		bfj_acct_2 zjbd_date_out_2 zjbd_date_in_2
		bfj_acct_3 zjbd_date_out_3 zjbd_date_in_3
		bfj_acct_4 zjbd_date_out_4 zjbd_date_in_4
		bfj_acct_5 zjbd_date_out_5 zjbd_date_in_5/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p5, $property;
	}
	push @{ $detail->{properties} }, \@p5 if scalar(@p5) > 0;

	#凭证详细第五部分
	my @p6;
	for (
		qw/rb_cwwf_bfee rb_cwwf_bfee_back cfee cwws_cfee
		cfee_back cwws_cfee_back ls_amt in_cost
		c sp_c fc cust_proto sp_cust_proto wqr_c p p1 p2 wlzj_type/
	  )
	{
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @p6, $property;
	}
	push @{ $detail->{properties} }, \@p6 if scalar(@p6) > 0;

	#凭证详细公共字段部分
	my @public;
	for (qw/group id status crt_id_name flag revoke_user_name ts_revoke ts_c/) {
		my $property = {};
		$property->{key}   = $public->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @public, $property;
	}

	#其他字段
	my @other;
	for ( sort @$yspz_item ) {
		next unless exists $ys_data->{$_};
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = delete $ys_data->{$_};
		push @other, $property;
	}
	push @{ $detail->{properties} }, \@other;
	push @{ $detail->{properties} }, \@public;

	push @$data, $detail;

	my $jzpz_sql =
"select * from jzpz where ys_type='$ys_type' and ys_id=$ys_id order by cast(left(fid,3) as float)";

	#jzpz所有记录
	my $jzpz = $self->select($jzpz_sql);

	#组建jd_books的json
	#
	my $num = 0;
	my $jd_book;

	for my $pz (@$jzpz) {
		my $fl = {};
		$fl->{isdetail} = false;
		$fl->{j_book}   = [];
		$fl->{d_book}   = [];
		$fl->{title}    = '分录' . $pz->{fid};
		my $property = {};

		#j_book
		my $jbook_name = $self->dict->{book}->{ $pz->{jb_id} }->[0];

		# 组成借方科目的表头部分
		$property->{key}   = '借方科目';
		$property->{value} = $self->dict->{book}->{ $pz->{jb_id} }->[1];
		push @{ $fl->{j_book} }, $property;

		my $jbook_data = $self->select(
			"select * from book_$jbook_name where id=" . $pz->{j_id} );
		$jbook_data = $jbook_data->[0];

		#jbook的核算项
		my $h = $self->configure->{headers}->{ $pz->{jb_id} };
		for (@$h) {
			next unless exists $jbook_data->{$_};
			$property = {};
			$property->{key} = $self->dict->{dim}{$_};
			my $co = $jbook_data->{$_};
			if ( $_ eq "zjbd_type" ) {
				$property->{value} = $self->zjbd_type->{$co};
			}
			elsif ( $_ eq "zyzj_acct" ) {
				$property->{value} = $self->zyzj_acct->{$co};
			}
			elsif ( $_ eq "bfj_acct" ) {
				$property->{value} = $self->bfj_acct->{$co};
			}
			elsif ( $_ eq "wlzj_type" ) {
				$property->{value} = $self->dict->{types}{wlzj_type}->{$co};
			}
			elsif ( $_ eq "p" ) {
				$property->{value} = $self->p->{$co};
			}
			elsif ( $_ eq "bi" ) {
				$property->{value} = $self->bi->{$co};
			}
			elsif ( $_ eq "acct" ) {
				$property->{value} = $self->acct->{$co};
			}
			elsif ( $_ eq "fhw_type" ) {
				$property->{value} = $self->fhw_type->{$co};
			}
			elsif ( $_ eq "fyw_type" ) {
				$property->{value} = $self->dict->{types}{fyw_type}->{$co};
			}
			elsif ( $_ eq "fhyd_acct" ) {
				$property->{value} = $self->fhyd_acct->{$co};
			}
			elsif ( $_ eq "fyp_acct" ) {
				$property->{value} = $self->fyp_acct->{$co};
			}
			else {
				$property->{value} = $co || "";
			}
			push @{ $fl->{j_book} }, $property;
		}
		$fl->{j_amt} =
		  ( $jbook_data->{j} ne '0' ) ? $jbook_data->{j} : $jbook_data->{d};
		$fl->{j_amt} = $self->nf( $fl->{j_amt} / 100 );

		#d_book
		$property = {};
		my $dbook_name = $self->dict->{book}->{ $pz->{db_id} }->[0];

		# 组成贷方科目的表头部分
		$property->{key}   = '贷方科目';
		$property->{value} = $self->dict->{book}->{ $pz->{db_id} }->[1];
		push @{ $fl->{d_book} }, $property;
		my $dbook_data = $self->select(
			"select * from book_$dbook_name where id=" . $pz->{d_id} );
		$dbook_data = $dbook_data->[0];

		#dbook的核算项
		my $h1 = $self->configure->{headers}->{ $pz->{db_id} };

		for (@$h1) {
			next unless exists $dbook_data->{$_};
			$property = {};
			$property->{key} = $self->dict->{dim}{$_};
			my $co = $dbook_data->{$_};
			if ( $_ eq "zjbd_type" ) {
				$property->{value} = $self->zjbd_type->{$co};
			}
			elsif ( $_ eq "zyzj_acct" ) {
				$property->{value} = $self->zyzj_acct->{$co};
			}
			elsif ( $_ eq "bfj_acct" ) {
				$property->{value} = $self->bfj_acct->{$co};
			}
			elsif ( $_ eq "wlzj_type" ) {
				$property->{value} = $self->dict->{types}{wlzj_type}{$co};
			}
			elsif ( $_ eq "bi" ) {
				$property->{value} = $self->bi->{$co};
			}
			elsif ( $_ eq "p" ) {
				$property->{value} = $self->p->{$co};
			}
			elsif ( $_ eq "acct" ) {
				$property->{value} = $self->acct->{$co};
			}
			elsif ( $_ eq "fhw_type" ) {
				$property->{value} = $self->fhw_type->{$co};
			}
			elsif ( $_ eq "fyw_type" ) {
				$property->{value} = $self->dict->{types}{fyw_type}->{$co};
			}
			elsif ( $_ eq "fhyd_acct" ) {
				$property->{value} = $self->fhyd_acct->{$co};
			}
			elsif ( $_ eq "fyp_acct" ) {
				$property->{value} = $self->fyp_acct->{$co};
			}
			else {
				$property->{value} = $co || "";
			}
			push @{ $fl->{d_book} }, $property;
		}
		$fl->{d_amt} =
		  ( $dbook_data->{d} ne '0' ) ? $dbook_data->{d} : $dbook_data->{j};
		$fl->{d_amt} = $self->nf( $fl->{d_amt} / 100 );
		push @$data, $fl;
	}
	$self->render( json => $data );
}
1;
