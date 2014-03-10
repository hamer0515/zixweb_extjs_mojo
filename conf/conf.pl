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

	hsx => [ 'fir', 'sec', 'thi', 'fou', 'fiv', 'six', 'sev', 'eig' ],

	#Accounting entries
	headers => {
		'1' => [ 'zjbd_date', 'zjbd_type', 'zyzj_acct' ],
		'2' => [ 'zjbd_date', 'zjbd_type', 'zyzj_acct' ],
		'3' => [ 'bfj_acct',  'zjbd_date', 'zjbd_type' ],
		'4' => [ 'bfj_acct',  'zjbd_date', 'zjbd_type' ],
		'5' => ['c'],
		'6' => [ 'bfj_acct',  'e_date',    'zjbd_type' ],
		'7'  => [ 'e_date',   'zyzj_acct' ],
		'8'  => [ 'bi',       'tx_date' ],
		'9'  => [ 'bfj_acct', 'e_date', 'zjbd_type' ],
		'10' => [ 'e_date',   'zyzj_acct' ],
		'11' => [ 'c',        'cust_proto', 'tx_date' ],
		'12' => [ 'bi',       'c', 'p' ],
		'13' => ['p'],
		'14' => ['bfj_acct'],
		'15' => ['zyzj_acct'],
		'16' => ['acct'],
		'17' => [ 'c', 'p' ],
		'18' => ['acct'],
		'19' => [ 'bi', 'tx_date' ],
		'20' => [ 'bi', 'tx_date' ],
		'21' => [ 'bfj_acct', 'zjbd_date', 'zjbd_type' ],
		'22' => [ 'bfj_acct', 'zjbd_date', 'zjbd_type' ],
		'23' => [],
		'24' => ['wlzj_type'],
		'25' => ['wlzj_type'],
		'26' => [],
		'27' => [ 'c', 'cust_proto', 'tx_date' ],
		'28' => [ 'bi', 'tx_date' ],
		'29' => [ 'bi', 'tx_date' ],
		'30' => [ 'bi', 'c', 'fp', 'p', 'tx_date' ],
		'31' => [ 'bi', 'fp',, 'tx_date' ],
		'32' => [ 'bi',  'c', 'fp', 'p', 'tx_date' ],
		'33' => [ 'c',   'p' ],
		'34' => [ 'c',   'p' ],
		'35' => [ 'bi',, 'tx_date' ],
		'36' => [],
		'37' => ['p'],
		'38'  => [ 'bfj_acct', 'e_date', 'zjbd_type' ],
		'39'  => [],
		'40'  => ['yw_type'],
		'38'  => [ 'bfj_acct', 'e_date', 'zjbd_type' ],
		'201' => ['fhyd_acct'],
		'202' => [ 'fc',      'fyw_type' ],
		'203' => [ 'fc',      'fhw_type' ],
		'204' => [ 'fe_date', 'fyp_acct', 'fyw_type' ],
		'205' => [ 'fch',     'fe_date' ],
		'206' => [ 'fch',     'fe_date' ],
		'207' => ['fyp_acct'],
		'208' => ['fch'],
		'209' => [ 'fc', 'fhw_type' ],
		'210' => [ 'fch', 'fhw_type' ],
		'211' => [ 'fe_date', 'fyp_acct', 'fyw_type' ],
		'212' => ['fhw_type'],
		'213' => ['fm'],
		'214' => [ 'fch',   'fhw_type' ],
		'215' => ['fch'],
		'216' => ['f_dcn'],
		'217' => [ 'fch',   'fe_date' ],
		'218' => ['fc'],
		'219' => [ 'fc',    'fhw_type' ],
		'220' => [ 'fch',   'fhw_type' ],
		'221' => [],
		'222' => [ 'f_agm', 'fhw_type' ],
		'223' => [ 'f_agm', 'f_ssn',    'fhw_type' ],
		'224' => ['fhw_type'],
		'225' => [ 'fc',    'fhw_type', 'fyw_type' ],
		'226' => [ 'fhw_type', 'fyw_type' ],
		'227' => [ 'fhw_type', 'fyw_type' ],
		'228' => [ 'fc',       'fhw_type' ],
		'229' => [ 'f_dcn',    'fm' ],
		'230' => [ 'fhw_type', 'fyw_type' ],
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

