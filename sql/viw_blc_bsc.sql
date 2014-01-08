DROP VIEW VIW_BLC_BSC;
CREATE VIEW
    VIW_BLC_BSC
    (
    	blc,
        bsc,
        bfj_acct,
        e_date,
        zjbd_type,
        period
    ) AS
SELECT
	VALUE(blc.amt, 0) as blc,
	VALUE(bsc.amt, 0) as bsc,
    CASE
        WHEN blc.bfj_acct IS NOT NULL
        THEN blc.bfj_acct
        ELSE bsc.bfj_acct
    END AS bfj_acct,
    CASE
        WHEN blc.e_date IS NOT NULL
        THEN blc.e_date
        ELSE bsc.e_date
    END AS e_date,
    CASE
        WHEN blc.zjbd_type IS NOT NULL
        THEN blc.zjbd_type
        ELSE bsc.zjbd_type
    END AS zjbd_type,
    CASE
        WHEN blc.period IS NOT NULL
        THEN blc.period
        ELSE bsc.period
    END AS period
FROM
    (
        SELECT
            bfj_acct,
            e_date,
            zjbd_type,
            period,
            SUM(d) - SUM(j) AS amt
        FROM
            sum_blc
        GROUP BY
            e_date,
            bfj_acct,
            zjbd_type,
            period) blc
FULL JOIN
    (
        SELECT
            bfj_acct,
            e_date,
            zjbd_type,
            period,
            SUM(j) - SUM(d) AS amt
        FROM
            sum_bsc
        GROUP BY
            e_date,
            bfj_acct,
            zjbd_type,
            period) bsc
ON
    blc.e_date = bsc.e_date
AND blc.bfj_acct = bsc.bfj_acct
AND blc.zjbd_type = bsc.zjbd_type
AND blc.period = bsc.period;