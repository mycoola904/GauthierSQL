-- report: CustomerCountSummary
SELECT
    'Source customers (ConversionData.dbo.CUST)' AS Metric,
    COUNT_BIG(1) AS [RowCount]
FROM ConversionData.dbo.CUST
UNION ALL
SELECT
    'Target customers (ModMigration.dbo.CustomerLocations where c_id = UniqRef)' AS Metric,
    COUNT_BIG(DISTINCT cl.c_id) AS [RowCount]
FROM ModMigration.dbo.CustomerLocations AS cl
WHERE CONVERT(varchar(50), cl.c_id) = cl.UniqRef
UNION ALL
SELECT
    'Difference (target - source)' AS Metric,
    (
        SELECT COUNT_BIG(DISTINCT cl.c_id)
        FROM ModMigration.dbo.CustomerLocations AS cl
        WHERE CONVERT(varchar(50), cl.c_id) = cl.UniqRef
    ) - (
        SELECT COUNT_BIG(1)
        FROM ConversionData.dbo.CUST
    ) AS [RowCount];
GO

-- report: MissingAccounts
SELECT
    cu.c_id_alpha AS Account,
    cu.c_id AS SourceCustomerId,
    st.Status AS SourceStatus
FROM ConversionData.dbo.CUST AS cu
inner join Status st on st.StatusID = cu.C_CSTAT
LEFT JOIN (
    SELECT DISTINCT c_id
    FROM ModMigration.dbo.CustomerLocations
    WHERE CONVERT(varchar(50), c_id) = UniqRef
) AS cl
    ON cl.c_id = cu.c_id
WHERE cl.c_id IS NULL
ORDER BY cu.c_id_alpha;
GO

-- report: DuplicateTargetCustomerLocations
SELECT
    cl.c_id AS TargetCustomerId,
    COUNT_BIG(1) AS DuplicateCount
FROM ModMigration.dbo.CustomerLocations AS cl
WHERE CONVERT(varchar(50), cl.c_id) = cl.UniqRef
GROUP BY cl.c_id
HAVING COUNT_BIG(1) > 1
ORDER BY DuplicateCount DESC, TargetCustomerId;
GO

-- report: ARTotalSummary
SELECT
    'Source AR total (ConversionData.dbo.CUST.C_CUR_BAL)' AS Metric,
    SUM(ROUND(cu.C_CUR_BAL, 2)) AS [TotalAR]
FROM ConversionData.dbo.CUST AS cu
UNION ALL
SELECT
    'Target AR total (ModMigration.dbo.AgedDebtorsData net value)' AS Metric,
    SUM(
        CASE
            WHEN ad.DocumentType = 'C' THEN -ad.NetDocumentValue
            ELSE ad.NetDocumentValue
        END
    ) AS [TotalAR]
FROM ModMigration.dbo.AgedDebtorsData AS ad
UNION ALL
SELECT
    'Difference (target - source)' AS Metric,
    (
        SELECT SUM(
            CASE
                WHEN ad.DocumentType = 'C' THEN -ad.NetDocumentValue
                ELSE ad.NetDocumentValue
            END
        )
        FROM ModMigration.dbo.AgedDebtorsData AS ad
    ) - (
        SELECT SUM(ROUND(cu.C_CUR_BAL, 2))
        FROM ConversionData.dbo.CUST AS cu
    ) AS [TotalAR];
GO

-- report: ARMismatchedAccounts
SELECT
    cu.c_id_alpha AS Account,
    targetAR.[TotalAR] AS TargetAR,
    ROUND(cu.C_CUR_BAL, 2) AS SourceAR,
    targetAR.[TotalAR] - ROUND(cu.C_CUR_BAL, 2) AS Delta
FROM (
    SELECT
        ad.DMAccount,
        SUM(
            CASE
                WHEN ad.DocumentType = 'C' THEN -ad.NetDocumentValue
                ELSE ad.NetDocumentValue
            END
        ) AS [TotalAR]
    FROM ModMigration.dbo.AgedDebtorsData AS ad
    GROUP BY ad.DMAccount
) AS targetAR
INNER JOIN ConversionData.dbo.CUST AS cu
    ON cu.C_ID_ALPHA = targetAR.DMAccount
WHERE targetAR.[TotalAR] <> ROUND(cu.C_CUR_BAL, 2)
ORDER BY ABS(targetAR.[TotalAR] - ROUND(cu.C_CUR_BAL, 2)) DESC, cu.c_id_alpha;
GO

-- report: MissingServiceCodesInCode
SELECT
    cu.c_id AS C_ID,
    cu.C_ID_ALPHA AS Account,
    a.SVC_CODE,
    st.Status
FROM ConversionData.dbo.AUTO AS a
LEFT JOIN ConversionData.dbo.CODE AS co
    ON co.SVC_CODE = a.SVC_CODE
INNER JOIN ConversionData.dbo.CUST AS cu
    ON cu.c_id = a.C_ID
INNER JOIN ModMigration.dbo.Status AS st
    ON st.StatusID = cu.C_CSTAT
WHERE co.SVC_CODE IS NULL
ORDER BY cu.C_ID_ALPHA, a.SVC_CODE;
GO

-- report: ActiveAutoNotMappedToServiceCodeDetail
SELECT
    aa.ServiceCode,
    aa.ServiceDescription
FROM ActiveAuto AS aa
INNER JOIN ConversionData.dbo.CODE AS cm
    ON cm.SVC_CODE = aa.SVC_CODE
INNER JOIN ConversionData.dbo.UDEF AS bc
    ON bc.UNIQUE_ID = aa.BILLCYCLE
INNER JOIN ConversionData.dbo.CUST AS cl
    ON cl.c_id = aa.C_ID
LEFT JOIN ConversionData.dbo.UDEF AS cta
    ON cta.UNIQUE_ID = cl.B_TAXAREA
LEFT JOIN ModMigration.dbo.ServiceCodeDetail AS sd
    ON sd.[ServiceCode] = cm.SVC_CODE_ALPHA
WHERE sd.id IS NULL
ORDER BY aa.ServiceCode, aa.ServiceDescription;
GO

-- report: CSAPActionCounts
SELECT
    [Action],
    COUNT_BIG(1) AS [RowCount]
FROM ModMigration.dbo.CustomerServiceAgreementPrices
GROUP BY [Action]
ORDER BY [Action];
GO

-- report: UnassignedServices
SELECT
    DMAccount,
    ServiceCode,
    ServiceDescription
FROM v_UnassignedServices
ORDER BY DMAccount, ServiceCode, ServiceDescription;
GO
