package ZixWeb::Yspzq::Detail;

use Mojo::Base 'Mojolicious::Controller';
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

	#[id,status,flag]
	my $public_item = [ keys %{$public} ];

	#
	#{备付金账户=>1,资金变动类型=>1]
	#
	for (@$yspz_item) {
		my $property = {};
		$property->{key}   = $yspz_zd->{$_};
		$property->{value} = $ys_data->{$_};
		push @{ $detail->{properties} }, $property;
	}

	#
	#{撤销标志=>0,原始凭证id=>1]
	#
	for (@$public_item) {
		my $property = {};
		$property->{key}   = $public->{$_};
		$property->{value} = $ys_data->{$_};
		push @{ $detail->{properties} }, $property;
	}
	push @$data, $detail;

	my $jzpz_sql =
"select * from jzpz where ys_type=$ys_type and ys_id=$ys_id order by cast(left(fid,3) as float)";

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
