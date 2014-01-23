DROP VIEW VIW_ZJDZ_BFJ_RESULT;
CREATE VIEW
    VIW_ZJDZ_BFJ_RESULT
    (
        bfj_acct,
        dz_date,
        GROUP,
        id,
        ys_type,
        zjbd_type,
        flag
    ) AS
SELECT
    bfj_acct,
    period AS dz_date,
    GROUP,
    id,
    value('0010', '0010') AS ys_type,
    bfj_zjbd_type         AS zjbd_type,
    flag
FROM
    yspz_0010
UNION ALL
SELECT
    bfj_acct,
    period AS dz_date,
    GROUP,
    id,
    value('0011', '0011') AS ys_type,
    bfj_zjbd_type         AS zjbd_type,
    flag
FROM
    yspz_0011
UNION ALL
SELECT
    bfj_acct,
    period AS dz_date,
    GROUP,
    id,
    value('0012', '0012') AS ys_type,
    bfj_zjbd_type         AS zjbd_type,
    flag
FROM
    yspz_0012;