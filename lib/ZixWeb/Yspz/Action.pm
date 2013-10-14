package ZixWeb::Yspz::Action;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use boolean;
use JSON::XS;

sub add {
	my $self          = shift;
	my $ys_type       = $self->param('ys_type');
	my $data->{_type} = $ys_type;

	# 原始凭证内容
	my $dict = {
		'0001' => [
			qw/bfj_acct zjbd_date_in zyzj_acct zjbd_date_out zjhb_amt zyzj_bfee memo/
		],
		'0008' => [qw/bfj_acct_bj zjbd_date_in tx_amt c memo/],
		'0009' => [qw/zjbd_date_out tx_amt bi c ssn wk_cfee cust_proto memo/],
		'0013' => [qw/bfj_acct zjbd_date_out zhgl_fee memo/],
		'0014' => [qw/bfj_acct zjbd_date_in zhlx_amt memo/],
		'0015' => [
			qw/bfj_acct_in zjbd_date_in bfj_acct_out zjbd_date_out zjhb_amt bfj_bfee memo/
		],
		'0018' => [qw/bfj_acct_bj zjbd_date_in tx_amt c memo/],
		'0054' =>
		  [qw/zyzj_acct bi zjbd_date_in c lfee tx_date_from tx_date_to meno/],

	};

	# 如果是0006号原始凭证的话，转义
	if ( $ys_type eq '0006' ) {
		my $d;
		my $da = $self->param('data');
		$da =~ s/\\\\/\\/g;
		for ( split /\\;/, $da ) {
			my $p;
			my @dat = split /\\\|/, $_;
			$p->{id}     = shift @dat;
			$p->{period} = shift @dat;
			$p->{clfs}   = shift @dat;
			if ( $p->{clfs} == 1 ) {
				$p->{yqr_c} = shift @dat;
				$p->{memo}  = shift @dat;
			}
			push @$d, $p;
		}
		$data->{data} = $d;
	}

	# 取得凭证数据
	else {
		for ( @{ $dict->{$ys_type} } ) {
			$data->{$_} = $self->param($_);
		}
	}

	#use Data::Dump;
	#Data::Dump->dump({
	#        'svc'   => "yspz_$ys_type",
	#        'data'  => $data,
	#        'sys'   => { 'oper_user' => $self->session->{uid}, },
	#    });
	#Data::Dump->dump($self->configure->{svc_url});
	# 发送凭证录入请求
	my $res = $self->ua->post(
		$self->configure->{svc_url},
		encode_json {
			'svc'  => "yspz_$ys_type",
			'data' => $data,
			'sys'  => { 'oper_user' => $self->session->{uid}, },
		}
	)->res->json->{status};
	$self->stash( 'pd' => $res );
}

sub action {
	my $self = shift;
	my $opt  = $self->param('action');
	my $id   = $self->param('id');
	my $date = $self->param('date');
	my $type = $self->param('type');
	my $res;
	my $result = { success => false };
	if ( $opt eq 'run_job' || $opt eq 'get_log' ) {
		$res = $self->ua->post(
			$self->configure->{mgr_url},
			encode_json {
				action => $opt,
				param  => {
					job_id    => $id,
					date      => $date,
					type      => $type,
					oper_user => $self->session->{uid},
				}
			}
		)->res->json;
		if ( $opt eq 'get_log' ) {
			unless ($res) {
				$self->render( json => { success => false } );
				return;
			}
			my $r = "";
			$r .= "$res->{errmsg} <br/>" if $res->{errmsg};
			$r .= join "<br/>", @{ $res->{ret} };
			$self->render( json => { text => $self->my_decode($r) } );
			return;
		}
		else {
			$res = $res->{status};
		}
	}
	else {
		$res = $self->ua->post(
			$self->configure->{mgr_url},
			encode_json {
				action => $opt,
				param  => {
					mission_id => $id,
					date       => $date,
					type       => $type,
					oper_user  => $self->session->{uid},
				}
			}
		)->res->json->{status};
	}
	if ( defined $res && $res == 0 ) {
		$result->{success} = true;
	}
	$self->render( json => $result );
}

1;
