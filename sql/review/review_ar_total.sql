
-- This SQL script calculates the total accounts receivable (AR) from two different sources: the current balance in the cust table and the net document value from the AgedDebtorsData. It then compares these two values to identify any discrepancies.
select SUM(round(C_CUR_BAL,2)) [Total AR]
from ConversionData.dbo.CUST 

select sum(case
when DocumentType = 'C' then  -NetDocumentValue
else NetDocumentValue end) AR
from AgedDebtorsData

-- This query compares the total AR calculated from the AgedDebtorsData with the current balance in the cust table, and returns any discrepancies.
select cu.c_id_alpha, targetAR.[Total AR], cu.C_CUR_BAL from (
select DMAccount, sum(case
when DocumentType = 'C' then  -NetDocumentValue
else NetDocumentValue end) [Total AR]
from AgedDebtorsData
group by DMAccount
) targetAR
inner join ConversionData.dbo.cust cu on cu.C_ID_ALPHA = targetAR.DMAccount
where targetAR.[Total AR] <> round(cu.C_CUR_BAL, 2)