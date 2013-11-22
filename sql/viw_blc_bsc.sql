DROP VIEW VIW_BLC_BSC;
CREATE VIEW
    VIW_BLC_BSC
    (
    	blc,
        bsc,
        bfj_acct,
        e_date       
    ) AS
SELECT
    blc.amt AS blc,
    bsc.amt AS bsc,
    CASE
        WHEN blc.bfj_acct IS NULL
        THEN bsc.bfj_acct
    END AS bfj_acct,
    CASE
        WHEN blc.e_date IS NULL
        THEN bsc.e_date
    END AS e_date
FROM
    (
        SELECT
            bfj_acct,
            e_date,
            SUM(j) - SUM(d) AS amt
        FROM
            sum_blc
        GROUP BY
            e_date,
            bfj_acct ) blc
FULL JOIN
    (
        SELECT
            bfj_acct,
            e_date,
            SUM(d) - SUM(j) AS amt
        FROM
            sum_bsc
        GROUP BY
            e_date,
            bfj_acct ) bsc
ON
    blc.e_date = bsc.e_date
AND blc.bfj_acct = blc.bfj_acct;