use ModMigration

drop table if exists TempContainers

select row_number() over(order by cd.cand_id) ContRefId
,cd.CONNUMBER ContainerSerialNo
,cv.ContainerType
, '' TagReference
, cd.COMMENT Notes
,cv.company CompanyOutlet
,  cast(cd.PLACED as date) DateOfDelivery
, soh.id SiteOrderUniqueRef
, '' Commercial
, '1' BinOnSiteNumber
, sap.AgreeNbr
, soh.DMAccount
Into TempContainers
-- select count(1)
from ConversionData.dbo.CANG cg
inner join ConversionData.dbo.cand cd on cd.CONGRPUID = cg.CONGRPUID
inner join ConversionData.dbo.CCAN cc on cc.CONGRPUID = cg.CONGRPUID
--inner join ConversionData.dbo.XAUS x on x.STOPID = cc.STOPID
inner join RouteAssignments x on x.STOPID = cc.STOPID
inner join CustomerServiceAgreementPrices sap on sap.AutoID = x.AUTOID
inner join Container_View cv on cv.CONTID = cg.CONTID
--inner join AutoDetails ad on ad.SIZE = cv.Size and ad.c_id = cg.C_ID
--inner join Pricing p on p.autoid = ad.AUTOID
--inner join AgreeNumber an on an.GroupKey = p.GroupKey
inner join SiteOrderHeader soh on soh.autoid = sap.AutoID
group by 
cd.CAND_ID
,cd.CONNUMBER 
,cv.ContainerType
, cd.COMMENT 
,cv.company 
,  cast(cd.PLACED as date) 
, soh.id 
, sap.AgreeNbr
, soh.DMAccount

-- select tc.*
-- from TempContainers tc
-- inner join
-- (
-- select AgreeNbr
-- from TempContainers
-- group by AgreeNbr
-- having count(1)>1
-- ) ct on ct.AgreeNbr = tc.AgreeNbr
-- where DMAccount = '4208-001'
-- and tc.AgreeNbr = 11079
-- order by tc.AgreeNbr

