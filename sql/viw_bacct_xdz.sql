drop view VIW_BACCT_XDZ;
CREATE VIEW
    VIW_BACCT_XDZ
    (
        b_acct,
        zjbd_date,
        acct_type,
        j,
        d
    ) AS
    
select b_acct,zjbd_date,acct_type,sum(j) as j,sum(d) as d 
from (
select bfj_acct as b_acct,zjbd_date,'1' as acct_type,sum(j) as j,sum(d) as d 
                    from sum_bfee_yhyf 
                    where j<>d
                    group by zjbd_date,bfj_acct
  
union(
          select bfj_acct as b_acct,zjbd_date,'1' as acct_type,sum(j) as j,sum(d) as d 
                    from sum_bfee_yhys 
                    where j<>d
                    group by zjbd_date,bfj_acct        

)union(
          select bfj_acct as b_acct,zjbd_date,'1' as acct_type,sum(j) as j,sum(d) as d 
                    from sum_txamt_yhys 
                    where j<>d
                    group by zjbd_date,bfj_acct        

)union(
          select bfj_acct as b_acct,zjbd_date,'1' as acct_type,sum(j) as j,sum(d) as d 
                    from sum_txamt_yhyf 
                    where j<>d
                    group by zjbd_date,bfj_acct        

)
)where j<>d
group by  b_acct,zjbd_date,acct_type;
