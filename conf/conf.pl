#!/usr/bin/perl

use utf8;

{

	# db information
	dsn    => "dbi:DB2:$ENV{DB_NAME}",
	user   => $ENV{DB_USER},
	pass   => $ENV{DB_PASS},
	schema => $ENV{DB_SCHEMA},

	port => $ENV{LISTEN_PORT},

	# page information
	page_size => $ENV{PAGE_SIZE},

	#server
	svc_url => $ENV{SVC_URL},

	#mgr
	mgr_url => $ENV{MGR_URL},

	#memcached server
	mem_server => [ $ENV{MEM_SERVER} ],

	#expire
	expire => 14400,

	di => [ a .. z, A .. Z, 0 .. 9 ],

	#Accounting entries
	headers => {
		'1' => [ 'zyzj_acct', 'zjbd_type', 'zjbd_date' ],
		'2' => [ 'zyzj_acct', 'zjbd_type', 'zjbd_date' ],
		'3' => [ 'bfj_acct',  'zjbd_type', 'zjbd_date' ],
		'4' => [ 'bfj_acct',  'zjbd_type', 'zjbd_date' ],
		'5' => ['c'],
		'6' => [ 'bfj_acct',  'zjbd_type', 'e_date' ],
		'7'  => [ 'zyzj_acct', 'e_date' ],
		'8'  => [ 'bi',        'tx_date' ],
		'9'  => [ 'bfj_acct',  'zjbd_type', 'e_date' ],
		'10' => [ 'zyzj_acct', 'e_date' ],
		'11' => [ 'c',         'cust_proto', 'tx_date' ],
		'12' => [ 'c',         'bi', 'p' ],
		'13' => ['p'],
		'14' => ['bfj_acct'],
		'15' => ['zyzj_acct'],
		'16' => ['acct'],
		'17' => [ 'c', 'p' ],
		'18' => ['acct'],
		'19' => [ 'bi', 'tx_date' ],
		'20' => [ 'bi', 'tx_date' ],
		'21' => [ 'bfj_acct', 'zjbd_type', 'zjbd_date' ],
		'22' => [ 'bfj_acct', 'zjbd_type', 'zjbd_date' ],
		'23' => [],
		'24' => ['wlzj_type'],
		'25' => ['wlzj_type'],
		'26' => [],
		'27' => [ 'c', 'cust_proto', 'tx_date' ],
		'28' => [ 'bi', 'tx_date' ],
		'29' => [ 'bi', 'tx_date' ],
		'30' => [ 'c',  'p', 'bi', 'fp', 'tx_date' ],
		'31' => [ 'bi', 'fp', 'tx_date' ],
		'32' => [ 'c',  'p',  'bi', 'fp', 'tx_date' ],
		'33'  => [ 'c',  'p' ],
		'34'  => [ 'c',  'p' ],
		'35'  => [ 'bi', 'tx_date' ],
		'36'  => [],
		'201' => ['fhyd_acct'],
		'202' => [ 'fc',       'fyw_type', 'ftx_date' ],
		'203' => [ 'fyp_acct', 'fyw_type', 'fe_date' ],
		'204' =>
		  [ 'fc', 'fhw_type', 'f_ssn', 'fs_rate', 'fyw_type', 'ftx_date' ],
		'205' => [ 'fyp_acct', 'fio_date' ],
		'206' => [ 'fc',       'fyw_type' ],
		'207' => [ 'fc',       'fhw_type', 'f_ssn', 'fs_rate', 'ftx_date' ],
		'208' => [ 'fc',       'fhw_type', 'fch_ssn', 'f_rate', 'ftx_date' ],
		'209' => [ 'fyp_acct', 'fyw_type', 'fe_date' ],
		'210' => [ 'f_ssn',    'fs_rate',  'fhw_type', 'fyw_type', 'ftx_date' ],
		'211' => [ 'fm', 'fcg_date' ],
		'212' =>
		  [ 'fc', 'fhw_type', 'f_ssn', 'fch_rate', 'fyw_type', 'ftx_date' ],
		'213' => [ 'fc',       'fyw_type', 'ftx_date' ],
		'214' => [ 'f_dcn',    'fm',       'fyw_type', 'ftx_date' ],
		'215' => [ 'fc',       'fhw_type', 'fyw_type' ],
		'216' => [ 'fc',       'fhw_type', 'fch_ssn', 'fs_rate', 'ftx_date' ],
		'217' => [ 'fc',       'fhw_type', 'f_ssn', 'f_rate', 'ftx_date' ],
		'218' => [ 'fyw_type', 'fm',       'fhw_type' ],
		'219' => [ 'fyw_type', 'fhw_type' ],
		'220' => [ 'fyw_type', 'fhw_type' ],
		'221' => [ 'fhw_type', 'fc', 'f_ssn' ],
		'222' => [ 'fhw_type', 'fc', 'fch_ssn' ],
		'223' => [ 'f_dcn',    'fm', 'fyw_type' ]
	},
	extra_headers => {
		book => {
			j       => '借方金额',
			d       => '贷方金额',
			ys_type => '原始凭证类型',
			ys_id   => '原始凭证ID',
			jzpz_id => '记账凭证ID',
			ts_c    => '创建时间'
		}
	} };

