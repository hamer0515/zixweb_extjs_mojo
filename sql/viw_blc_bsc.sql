drop view VIW_BLC_BSC;
CREATE VIEW
    VIW_BLC_BSC
    (
        bfj_acct,
        e_date,
        blc,
        bsc
    ) AS  
select 
	blc.bfj_acct as bfj_acct, 
	blc.e_date as e_date, 
	blc.amt as blc,
	bsc.amt as bsc
from 
(
	select bfj_acct, e_date, sum(j) - sum(d) as amt
		from sum_blc
		group by
			e_date,
			bfj_acct
) blc
full join 
(
	select bfj_acct, e_date, sum(d) - sum(j) as amt
	from sum_bsc
	group by
	e_date,bfj_acct
) bsc
on blc.e_date = bsc.e_date and blc.bfj_acct = blc.bfj_acct;
