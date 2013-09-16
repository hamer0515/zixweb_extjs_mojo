#!/usr/bin/perl

{
    # db information
    dsn    => "dbi:DB2:$ENV{DB_NAME}",
    user   => $ENV{DB_USER},
    pass   => $ENV{DB_PASS},
    schema => $ENV{DB_SCHEMA},
    
    port   => $ENV{LISTEN_PORT},
    
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
    
    #Accounting entries
    headers => {'1'=>['zyzj_acct','zjbd_type','zjbd_date'],
                '2'=>['zyzj_acct','zjbd_type','zjbd_date'],
                '3'=>['bfj_acct','zjbd_type','zjbd_date'],
                '4'=>['bfj_acct','zjbd_type','zjbd_date'],
                '5'=>['c'],
                '6'=>['bfj_acct','zjbd_type','e_date'],
                '7'=>['zyzj_acct','e_date'],
                '8'=>['bi','tx_date'],
                '9'=>['bfj_acct','zjbd_type','e_date'],
                '10'=>['zyzj_acct','e_date'],
                '11'=>['c','cust_proto','tx_date'],
                '12'=>['c','bi','p'],
                '13'=>['p'],
                '14'=>['bfj_acct'],
                '15'=>['zyzj_acct'],
                '16'=>['acct'],
                '17'=>['c','p'],
                '18'=>['acct'],
                '19'=>['bi','tx_date'],
                '20'=>['bi','tx_date'],
                '21'=>['bfj_acct','zjbd_type','zjbd_date'],
                '22'=>['bfj_acct','zjbd_type','zjbd_date'], 
                '23'=>[''],
                '24'=>['wlzj_type'],
                '25'=>['wlzj_type'],
                '26'=>[''],
                '27'=>['c','cust_proto','tx_date'],
                '28'=>['bi','tx_date'],
                '29'=>[ 'bi', 'tx_date' ],
                '30'=>[ 'c', 'p', 'bi', 'fp', 'tx_date'],
                '31'=>[ 'bi', 'fp', 'tx_date'],
                '32'=>[ 'c', 'p', 'bi', 'fp', 'tx_date'],
                '33'=>['c','p'],
                '34'=>['c','p'],  
            }
};


