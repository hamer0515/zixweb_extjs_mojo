package ZixWeb::Task::Taskpzcx;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use boolean;

#
#模块名称:凭证撤销审核任务列表
#
sub list {
	my $self = shift;

	my $page  = $self->param('page');
	my $limit = $self->param('limit');

	my $id = $self->param('id');

	my $params = {};
	for (qw/c_user from to status/) {
		my $p = $self->param($_);
		$p = undef if $p eq '';
		$params->{$_} = $p;
	}

	my $p->{condition} = '';
	if ($id) {
		$p = $self->params(
			{
				id      => $id,
				type    => 2,
				ys_type => [ 4, '0%' ]
			}
		);
	}
	else {
		$p = $self->params(
			{
				ys_type => [ 4, '0%' ],
				ts_c    => [
					0,
					$params->{from} && $self->quote( $params->{from} ),
					$params->{to}   && $self->quote( $params->{to} )
				],
				status => $params->{status},
				c_user => $params->{c_user}
				  && $self->uids->{ $params->{c_user} },
				type => 2
			}
		);
	}

	my $sql =
"select id, content,ys_type, ys_id, c_user, ts_c, status as shstatus, rownumber() over(order by id desc) as rowid from verify $p->{condition}";
	my $data = $self->page_data( $sql, $page, $limit );

	for my $d ( @{ $data->{data} } ) {
		my $content = decode_json delete $d->{content};
		$d->{cause} = $content->{cause}        if $content->{cause};
		$d->{cause} = $content->{revoke_cause} if $content->{revoke_cause};
	}
	$data->{success} = true;

	$self->render( json => $data );
}

#
#模块名称:凭证撤销审核任务详细
#
sub detail {
	my $self   = shift;
	my $data   = [];
	my $detail = {};
	my $verify = {};
	$detail->{properties} = [];

	#id
	my $id = $self->param('id');    #参数1

	#ys_type
	my $ys_type = $self->param('ys_type');    #参数2

	#ys_id
	my $ys_id = $self->param('ys_id');        #参数3

	#审核详细信息
	my $ex_sql =
"select id as shid, content, status as shstatus, v_user, v_ts,type as shtype, c_user, v_ts, ts_c from verify where id=$id";

	my $ex = $self->select($ex_sql)->[0];
	$ex->{content}      = decode_json $self->my_decode( $ex->{content} );
	$verify->{isverify} = true;
	$verify->{title} =
	  $ys_type . $self->ys_type->{$ys_type} . "凭证撤销审核详细信息";
	$verify->{revoke_cause} = $ex->{content}{revoke_cause};
	$verify->{period}       = $ex->{content}{period};
	$verify->{shid}         = $ex->{shid};
	$verify->{shstatus}     = $ex->{shstatus};
	$verify->{shtype}       = $ex->{shtype};
	$verify->{c_user}       = $ex->{c_user_name};
	$verify->{ts_c}         = $ex->{ts_c};
	$verify->{v_user}       = $ex->{v_user_name};
	$verify->{v_ts}         = $ex->{v_ts};

	# 从我的任务菜单进入传入readonly参数
	$verify->{rdonly} = $self->param('rdonly');

	push @$data, $verify;

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
				$property->{value} = $self->dict->{types}{acct}->{$co};
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
				$property->{value} = $self->dict->{types}{acct}{$co};
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

#
#模块名称: 凭证撤销审核任务审核通过
#
sub pass {
	my $self = shift;
	my $id   = $self->param('id');

	#	my $result = false;
	#	my $res    = 1;
	#	$res = $self->ua->post(
	#		$self->configure->{svc_url},
	#		encode_json {
	#			data => { id        => $id, },
	#			svc  => "verify",
	#			sys  => { oper_user => $self->session->{uid} },
	#		}
	#	)->res->json->{status};
	#	if ( $res == 0 ) {
	#		$result = true;
	#	}
	#	$self->render( json => { success => $result } );

	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json(
				{
					data => { id        => $id, },
					svc  => "verify",
					sys  => { oper_user => $self->session->{uid} },
				}
			)
		)
	);
}

#
#模块名称: 凭证撤销审核任务审核不通过
#
sub deny {
	my $self = shift;
	my $id   = $self->param('id');

	#	my $result = false;
	#	my $res    = 1;
	#	$res = $self->ua->post(
	#		$self->configure->{svc_url},
	#		encode_json {
	#			data => { id        => $id, },
	#			svc  => "refuse_verify",
	#			sys  => { oper_user => $self->session->{uid} },
	#		}
	#	)->res->json->{status};
	#	if ( $res == 0 ) {
	#		$result = true;
	#	}
	#	$self->render( json => { success => $result } );

	$self->render(
		json => $self->post_url(
			$self->configure->{svc_url},
			encode_json(
				{
					data => { id        => $id, },
					svc  => "refuse_verify",
					sys  => { oper_user => $self->session->{uid} },
				}
			)
		)
	);
}

1;
