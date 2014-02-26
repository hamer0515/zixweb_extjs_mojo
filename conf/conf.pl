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
		'33' => [ 'c',  'p' ],
		'34' => [ 'c',  'p' ],
		'35' => [ 'bi', 'tx_date' ],
		'36' => [],
		'37' => ['p'],
		'38'  => [ 'bfj_acct', 'zjbd_type', 'e_date' ],
		'201' => ['fhyd_acct'],
		'202' => [ 'fc',       'ftx_date',  'fyw_type' ],
		'203' => [ 'fc',       'fhw_type',  'ftx_date' ],
		'204' => [ 'fe_date',  'fyp_acct',  'fyw_type' ],
		'205' => [ 'fch', 'fe_date' ],
		'206' => ['fyp_acct'],
		'207' => ['fch'],
		'208' => [ 'fc',       'fhw_type', 'ftx_date' ],
		'209' => [ 'fch',      'fhw_type', 'ftx_date' ],
		'210' => [ 'fe_date',  'fyp_acct', 'fyw_type' ],
		'211' => [ 'fhw_type', 'ftx_date' ],
		'212' => [ 'fcg_date', 'fm' ],
		'213' => [ 'fch',      'fhw_type', 'ftx_date' ],
		'214' => [ 'fch',      'ftx_date' ],
		'215' => [ 'f_dcn',    'ftx_date' ],
		'216' => [ 'fch',      'fe_date' ],
		'217' => [ 'fc',       'fhw_type' ],
		'218' => [ 'fc',       'fhw_type', 'ftx_date' ],
		'219' => [ 'fch',      'fhw_type', 'ftx_date' ],
		'220' => [],
		'221' => [ 'f_agm',    'f_ssn',    'fhw_type' ],
		'222' => [ 'fc',       'fhw_type' ],
		'223' => [ 'fc',       'fhw_type', 'fyw_type' ],
		'224' => [ 'fhw_type', 'fyw_type' ],
		'225' => [ 'fhw_type', 'fyw_type' ],
		'226' => [ 'fc',       'fhw_type' ],
		'227' => [ 'f_dcn',    'fm' ],
		'228' => [ 'fhw_type', 'fyw_type' ],
	},
	extra_headers => {
		book => {
			period  => '会计期间',
			j       => '借方金额',
			d       => '贷方金额',
			ys_type => '原始凭证类型',
			ys_id   => '原始凭证ID',
			jzpz_id => '记账凭证ID',
			ts_c    => '创建时间'
		}
	} };

