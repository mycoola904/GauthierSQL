use ModMigration
-- Populate ContactType table

INSERT [dbo].[ContactType] ([Type]) VALUES (N'Operations/Service')

INSERT [dbo].[ContactType] ([Type]) VALUES (N'A/P Contact')

INSERT [dbo].[ContactType] ([Type]) VALUES (N'Other Contact')

drop table if exists xBillCycles

CREATE TABLE [dbo].[xBillCycles](
	[System_Val] [varchar](4) NULL,
	[Cycle] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'300', N'Monthly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'301', N'Quarterly 1 (Jan, Apr, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'302', N'Quarterly 2 (Feb, May, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'303', N'Quarterly 3 (Mar, Jun, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'304', N'Bi-Monthly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'305', N'Semi-Annually')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'306', N'Annually ')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'307', N'Weekly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'308', N'Bi-Weekly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'309', N'4-Month Cycle')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'310', N'4 Weeks')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'311', N'Per work order')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'312', N'Per Job')

--  Billing groups

insert into BillingGroup (BillingGroup, Description, BillingGroupID)
select  u.DATA Description,u.DATA Description, u.UNIQUE_ID
from ConversionData.dbo.udef u
where name like '%BILLTYPE%'


--  status

insert into Status (Status, Description, StatusID, SysValue)
SELECT  data
		, SystemValDefined
      ,UNIQUE_ID
      ,SYSTEM_VAL
     
  FROM [dbo].[CustomerStatusMapping]




-- Service Category
insert into ServiceCategory(ServiceCategory, Description, ServiceCategoryID)
select u.data ServiceCategory, u.DATA Description, UNIQUE_ID ServiceCategoryID
--select *
from ConversionData.dbo.UDEF u
where name like 'SERVICECAT'

-- Unit of Measure
insert into UnitOfMeasure(UnitOfMeasure, Description, UnitOfMeasureID)
select DATA UnitOfMeasure, DATA Description, UNIQUE_ID UnitOfMeasureID
--select *
from ConversionData.dbo.udef 
where name like '%UNITMEASR%'


-- Container Unit of Measure
insert into ContainerUOM( ContainerUOM, Description, ContainerUOMID)
select u.data Description, u.DATA Description, u.UNIQUE_ID ContainerUOMID
from conversiondata.dbo.cans c
inner join ConversionData.dbo.UDEF u on u.UNIQUE_ID = c.MEASUREUID
group by u.DATA, u.UNIQUE_ID

-- Companies
--select *
--from Company

insert into Company(Company, Description, CompanyID)
select COMPANY, COMPANY, CMPY_ID
from ConversionData.dbo.CMPY


-- Finance Charge
--select C_ID_ALPHA, B_STMT_TYP
--from ConversionData.dbo.cust c

insert into FinanceCharge(Description, FinanceChargeID)
select --name,
DATA as Description, UNIQUE_ID as FinanceChargeID
from ConversionData.dbo.udef ba
where ba.NAME like '%FINCHARGE%'

-- B_DELINQ
insert into DelinquencyLevel(Description, DelinquencyLevelID)
select --name, 
DATA as Description, UNIQUE_ID as DelinquencyLevelID
from ConversionData.dbo.udef u
where u.NAME like '%DELINQNOTE%'

-- B_B_CYCLE
insert into BillingCycle(Description, BillingCycleID, Cycle)
select --name, 
DATA as Description, UNIQUE_ID as BillingCycleID
, x.Cycle
from ConversionData.dbo.udef u
inner join xBillCycles x on x.System_Val = u.SYSTEM_VAL
where u.NAME like '%BILLCYCLE%'

-- bill area
insert into BillArea(Description, BillAreaID)
select ba.data as Description,ba.UNIQUE_ID BillAreaID
--select *
from ConversionData.dbo.udef ba
where ba.name like '%BILLAREA%'


-- B_STMT_TYP
insert into StatementType(Description, StatementTypeID)
select --name, 
DATA as Description, UNIQUE_ID as StatementTypeID
from ConversionData.dbo.udef u
where u.NAME like '%STMNTTYPE%'

-- B_TAXAREA
--select c_id_alpha, b_taxarea, dbo.Uname(b_taxarea)
--from ConversionData.dbo.cust  

insert into TaxArea(Description, TaxAreaID)
select --name, 
DATA as Description, UNIQUE_ID as TaxAreaID
from ConversionData.dbo.udef u
where u.NAME like '%TAXAREA%'

-- B_TERMS
--select c_id_alpha, B_TERMS, dbo.Uname(B_TERMS)
--from ConversionData.dbo.cust  

insert into Terms(Description, TermsID)
select --name, 
DATA as Description, UNIQUE_ID as TermsID
from ConversionData.dbo.udef u
where u.NAME like '%TERMS%'

-- Customer Reps
insert into CustomerRep(Name, Phone, Email, CommisionPlan, CustomerRepID)
select r.NAME, isnull(r.PHONE,''), isnull(r.EMAIL,''), isnull(r.COMMPLAN,'') as CommisionPlan, r.REP_ID as CustomerRepID
--select *
from ConversionData.dbo.REPS r

--B_BILL_INFO1
--select c_id_alpha, B_BILL_INFO1, dbo.Uname(B_BILL_INFO1)
--from ConversionData.dbo.cust  

insert into BillScreenInfo(UdefName, Description, BillScreenInfoID)
select name as UdefName, DATA as Description, UNIQUE_ID as BillScreenInfoID
from ConversionData.dbo.udef u
where u.NAME like '%BILLINFO%'

--B_SURCHARGE
--select c_id_alpha, B_SURCHARGE, dbo.Uname(B_SURCHARGE)
--from ConversionData.dbo.cust  

insert into SurchargeArea(Description, SurchargeAreaID)
select --name, 
DATA as Description, UNIQUE_ID as SurchargeAreaID
from ConversionData.dbo.udef u
where u.NAME like '%SURCHARGE%'


insert into RouteType(Description, RouteTypeID)
SELECT RT.DATA RouteType, rt.UNIQUE_ID RouteTypeID
FROM  ConversionData.DBO.UDEF RT 
where name like '%CONTROUTE%'


drop table if exists RouteDays

CREATE TABLE [dbo].[RouteDays](
	[mon] [int] NULL,
	[tue] [int] NULL,
	[wed] [int] NULL,
	[thu] [int] NULL,
	[fri] [int] NULL,
	[sat] [int] NULL,
	[sun] [int] NULL,
	[DayValue] [int] NULL,
	[WhichDay] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (1, 0, 0, 0, 0, 0, 0, 2, N'Monday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 1, 0, 0, 0, 0, 0, 3, N'Tuesday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 1, 0, 0, 0, 0, 4, N'Wednesday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 1, 0, 0, 0, 5, N'Thursday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 1, 0, 0, 6, N'Friday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 0, 1, 0, 7, N'Saturday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 0, 0, 1, 1, N'Sunday')


/* Route Frequency */

drop table if exists RouteFrequency

CREATE TABLE [dbo].[RouteFrequency](
	[Key] [varchar](10) NULL,
	[Value] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'E', N'1 x week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'A', N'EOW')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'B', N'EOW')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'1W', N'1 x week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2W', N'Every Other Week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3W', N'Every 3 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4W', N'Every 4 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'5W', N'Every 5 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'6W', N'Every 6 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'7W', N'Every 7 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'8W', N'Every 8 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'9W', N'Every 9 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'10W', N'Every 10 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'11W', N'Every 11 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'12W', N'Every 12 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'13W', N'Every 13 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'14W', N'Every 14 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'15W', N'Every 15 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'16W', N'Every 16 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'17W', N'Every 17 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'18W', N'Every 18 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'19W', N'Every 19 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'20W', N'Every 20 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'21W', N'Every 21 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'22W', N'Every 22 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'23W', N'Every 23 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'24W', N'Every 24 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'25W', N'Every 25 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'26W', N'Every 26 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'27W', N'Every 27 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'28W', N'Every 28 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'29W', N'Every 29 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'30W', N'Every 30 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'31W', N'Every 31 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'32W', N'Every 32 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'33W', N'Every 33 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'34W', N'Every 34 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'35W', N'Every 35 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'36W', N'Every 36 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'37W', N'Every 37 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'38W', N'Every 38 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'39W', N'Every 39 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'40W', N'Every 40 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'41W', N'Every 41 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'42W', N'Every 42 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'43W', N'Every 43 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'44W', N'Every 44 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'45W', N'Every 45 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'46W', N'Every 46 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'47W', N'Every 47 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'48W', N'Every 48 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'49W', N'Every 49 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'50W', N'Every 50 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'51W', N'Every 51 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'52W', N'Every 52 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2D', N'Every 2 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3D', N'Every 3 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4D', N'Every 4 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'5D', N'Every 5 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'6D', N'Every 6 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'7D', N'Every 7 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'8D', N'Every 8 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'9D', N'Every 9 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'10D', N'Every 10 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'11D', N'Every 11 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'12D', N'Every 12 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'13D', N'Every 13 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'14D', N'Every 14 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'1st', N'First Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2nd', N'Second Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3rd', N'Third Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4th', N'Forth Week Montly')
INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'ODD', N'Every Other Week')
INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'EVEN', N'Every Other Week')


drop table if exists ServiceCodeDetail

CREATE TABLE [dbo].[ServiceCodeDetail](
	[id] [bigint] NULL,
	[DMAccount] [nvarchar](19) NULL,
	[# Used] [int] NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](250) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[linkstat] [varchar](255) NULL,
	[size] [nvarchar](255) NULL,
	[unit] [nvarchar](255) NULL,
	[action] [nvarchar](255) NULL,
	[frequency] [nvarchar](255) NULL,
	[ServiceMap] [nvarchar](511) NULL,
	[container] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL
) ON [PRIMARY]

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (1, N'31946', 1, N'', N'FUEL SURCHARGE', N'ACCOUNTING', N'', N'', N'', N'Surcharge', N'', N'|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (2, N'9896-001', 235, N'1.5', N'1.5YD CONTAINER', N'COMMERCIAL', N'', N'1.5', N'Yard', N'Service', N'', N'1.5|1.5', N'1.5 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (3, N'7688-001', 12, N'1.5YD CAR', N'1.5YD CARDBOARD', N'ACCOUNTING', N'', N'1.5', N'Yard', N'Service', N'', N'1.5YD CAR|1.5', N'1.5 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (4, N'9786-001', 46, N'1.5YD REC', N'RECYCLE', N'ACCOUNTING', N'', N'1.5', N'Yard', N'Service', N'', N'1.5YD REC|1.5', N'1.5 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (5, N'8355-008', 11, N'10YD', N'10 YARD SERVICE', N'COMMERCIAL', N'', N'10', N'Yard', N'Service', N'', N'10YD|10', N'10 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (6, N'19994-003', 1, N'10YD CAR', N'10YD CARDBOARD', N'COMMERCIAL', N'', N'10', N'Yard', N'Service', N'', N'10YD CAR|10', N'10 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (7, N'32106', 2, N'10YD CARD', N'10YD CARDBOARD', N'ACCOUNTING', N'', N'10', N'Yard', N'Service', N'', N'10YD CARD|10', N'10 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (8, N'6242-001', 8, N'10YD REC', N'10YD RECYCLE', N'ACCOUNTING', N'', N'10', N'Yard', N'Service', N'', N'10YD REC|10', N'10 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (9, N'28219-003', 1, N'12', N'12 YD CONTAINER', N'COMMERCIAL', N'', N'12', N'Yard', N'Service', N'', N'12|12', N'12 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (10, N'20644-001', 1, N'12YD CARD', N'12YD CARDBOARD', N'ACCOUNTING', N'', N'12', N'Yard', N'Service', N'', N'12YD CARD|12', N'12 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (11, N'8355-034', 3, N'12YD REC', N'12YD RECYCLE', N'ACCOUNTING', N'', N'12', N'Yard', N'Service', N'', N'12YD REC|12', N'12 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (12, N'22857-008', 1, N'15YDRE', N'15YD RENTAL', N'ROLL OFF', N'', N'15', N'Yard', N'Rent', N'', N'15YDRE|15', N'15 Yard', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (13, N'8707-005', 6, N'45690', N'2-2YD CONTAINERS', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'2-2|2', N'2 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (14, N'28219-004', 3, N'45696', N'2-8YD CONTAINERS', N'COMMERCIAL', N'', N'8', N'Yard', N'Service', N'', N'2-8|8', N'8 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (15, N'6064-002', 1, N'20YDR', N'20YD RENTAL', N'COMMERCIAL', N'', N'20', N'Yard', N'Rent', N'', N'20YDR|20', N'20 Yard', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (16, N'9859-001', 242, N'2YD', N'2YD CONTAINER', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'2YD|2', N'2 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (17, N'9859-001', 6, N'2YD CAR', N'2YD CARDBOARD', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'2YD CAR|2', N'2 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (18, N'9629-004', 19, N'2YD CARD', N'2YD CARDBOARD', N'ACCOUNTING', N'', N'2', N'Yard', N'Service', N'', N'2YD CARD|2', N'2 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (19, N'30809', 8, N'2YD CO-MINGLE', N'RECYCLE', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'2YD CO-MINGLE|2', N'2 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (20, N'9838-001', 71, N'2YD REC', N'2YD RECYCLE', N'ACCOUNTING', N'', N'2', N'Yard', N'Service', N'', N'2YD REC|2', N'2 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (21, N'8912-003', 11, N'30YDR', N'30YD MONTHLY RENTAL FEES', N'COMMERCIAL', N'', N'30', N'Yard', N'Rent', N'', N'30YDR|30', N'30 Yard', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (22, N'2930-001', 3, N'30YDRE', N'MONTHLY RENTAL 30YD COMP', N'ROLL OFF', N'', N'30', N'Yard', N'Rent', N'', N'30YDRE|30', N'30 Yard', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (23, N'30495', 1, N'3YDCOMINGLE', N'3YD CO-MINGLE', N'ACCOUNTING', N'', N'3', N'Yard', N'Service', N'', N'3YDCOMINGLE|3', N'3 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (24, N'9838-001', 118, N'3YD', N'3YD CONTAINER', N'COMMERCIAL', N'', N'3', N'Yard', N'Service', N'', N'3YD|3', N'3 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (25, N'9409-003', 1, N'3YD CAR', N'3YD CARDBOARD', N'COMMERCIAL', N'', N'3', N'Yard', N'Service', N'', N'3YD CAR|3', N'3 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (26, N'5709-001', 6, N'3YD CARD', N'3YD CARDBOARD', N'ACCOUNTING', N'', N'3', N'Yard', N'Service', N'', N'3YD CARD|3', N'3 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (27, N'26748-001', 1, N'3YD COM', N'3YD COMPACTOR', N'COMPACTOR', N'', N'3', N'Yard', N'Service', N'', N'3YD COM|3', N'3 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (28, N'8192-001', 48, N'3YD REC', N'3YD RECYCLE', N'ACCOUNTING', N'', N'3', N'Yard', N'Service', N'', N'3YD REC|3', N'3 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (29, N'16338-005', 1, N'4 & 3', N'4YD & 3YD CONTAINER', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'4 & 3|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (30, N'25257-002', 2, N'40YD RENTAL-CARD', N'CARD COMPACTOR RENTAL', N'COMMERCIAL', N'', N'40', N'Yard', N'Rent', N'', N'40YD RENTAL-CARD|40', N'40 Yard', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (31, N'8861-002', 83, N'4YD', N'4 YARD SERVICE', N'COMMERCIAL', N'', N'4', N'Yard', N'Service', N'', N'4YD|4', N'4 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (32, N'8912-001', 5, N'4YD CAR', N'4YD CARDBOARD', N'COMMERCIAL', N'', N'4', N'Yard', N'Service', N'', N'4YD CAR|4', N'4 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (33, N'8355-023', 8, N'4YD CARD', N'4YD CARDBOARD', N'ACCOUNTING', N'', N'4', N'Yard', N'Service', N'', N'4YD CARD|4', N'4 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (34, N'8830-001', 45, N'4YD REC', N'4YD RECYCLE', N'ACCOUNTING', N'', N'4', N'Yard', N'Service', N'', N'4YD REC|4', N'4 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (35, N'28219-002', 1, N'6&4', N'6YD & 4YD CONTAINERS', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'6&4|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (36, N'8912-001', 53, N'6YD', N'6 YARD SERVICE', N'COMMERCIAL', N'', N'6', N'Yard', N'Service', N'', N'6YD|6', N'6 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (37, N'30761', 1, N'6YDCOMINGLE', N'6YD CO-MINGLE', N'ACCOUNTING', N'', N'6', N'Yard', N'Service', N'', N'6YDCOMINGLE|6', N'6 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (38, N'5607-001', 4, N'6YD CAR', N'6YD CARDBOARD', N'COMMERCIAL', N'', N'6', N'Yard', N'Service', N'', N'6YD CAR|6', N'6 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (39, N'8355-005', 6, N'6YD CARD', N'6YD CARDBOARD', N'ACCOUNTING', N'', N'6', N'Yard', N'Service', N'', N'6YD CARD|6', N'6 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (40, N'8120-001', 25, N'6YD REC', N'6YD RECYCLE', N'ACCOUNTING', N'', N'6', N'Yard', N'Service', N'', N'6YD REC|6', N'6 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (41, N'8434-001', 23, N'8YD', N'8 YARD SERVICE', N'COMMERCIAL', N'', N'8', N'Yard', N'Service', N'', N'8YD|8', N'8 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (42, N'5610-001', 8, N'8YD CARD', N'8YD CARDBOARD', N'ACCOUNTING', N'', N'8', N'Yard', N'Service', N'', N'8YD CARD|8', N'8 Yard', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (43, N'6064-002', 12, N'8YD REC', N'8YD RECYCLE', N'ACCOUNTING', N'', N'8', N'Yard', N'Service', N'', N'8YD REC|8', N'8 Yard', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (44, N'31068', 13, N'A1.5YD', N'1.5YD CONTAINER', N'COMMERCIAL', N'', N'1.5', N'Yard', N'Service', N'', N'A1.5YD|1.5', N'1.5 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (45, N'25967', 1, N'A10YD', N'10YD CONTAINER', N'COMMERCIAL', N'', N'10', N'Yard', N'Service', N'', N'A10YD|10', N'10 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (46, N'28872-001', 2, N'A12YD', N'12YD CONTAINER', N'COMMERCIAL', N'', N'12', N'Yard', N'Service', N'', N'A12YD|12', N'12 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (47, N'29502', 13, N'A2YD', N'2YD CONTAINER', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'A2YD|2', N'2 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (48, N'29297', 6, N'A3YD', N'3YD CONTAINER', N'COMMERCIAL', N'', N'3', N'Yard', N'Service', N'', N'A3YD|3', N'3 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (49, N'31946', 5, N'A4YD', N'4YD CONTAINER', N'COMMERCIAL', N'', N'4', N'Yard', N'Service', N'', N'A4YD|4', N'4 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (50, N'25700-001', 2, N'A6YD', N'6YD CONTAINER', N'COMMERCIAL', N'', N'6', N'Yard', N'Service', N'', N'A6YD|6', N'6 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (51, N'28872-002', 2, N'A8YD', N'8YD CONTAINER', N'COMMERCIAL', N'', N'8', N'Yard', N'Service', N'', N'A8YD|8', N'8 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (52, N'31959', 37, N'ACFSC', N'FUEL SURCHARGE', N'ACCOUNTING', N'', N'', N'', N'Surcharge', N'', N'ACFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (53, N'6978-028', 3, N'ADM', N'ADMINISTRATIVE FEES', N'RESIDENTIAL', N'', N'', N'', N'Fees', N'', N'ADM|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (54, N'5350-002', 34, N'AMONBI', N'BI-WEEKLY', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'AMONBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (55, N'32234', 37, N'AMONW', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'AMONW|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (56, N'32234', 50, N'ARFSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'ARFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (57, N'9920-001', 251, N'BACK DOOR', N'BACK DOOR SERVICE', N'ACCOUNTING', N'', N'', N'', N'Fee', N'', N'BACK DOOR|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (58, N'9540-001', 22, N'BACKBI', N'BACK DOOR SERVICE', N'ACCOUNTING', N'', N'', N'', N'Service', N'', N'BACKBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (59, N'9280-002', 12, N'BACKQTR', N'BACK DOOR SERVICE', N'ACCOUNTING', N'', N'', N'', N'Service', N'', N'BACKQTR|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (60, N'12070-003', 2, N'BAR', N'BARREL SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'', N'BAR|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (61, N'4208-001', 1, N'BAR2', N'BARREL SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'', N'BAR2|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (62, N'9617-001', 63, N'BIBBI', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'BIBBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (63, N'9868-001', 85, N'BIBIWKL', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'BIBIWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (64, N'9542-001', 61, N'BIBWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'BIBWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (65, N'9879-001', 58, N'BIWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'BIWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (66, N'31490', 13, N'BMONBI', N'BI WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'BMONBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (67, N'32242', 22, N'BMONW', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'BMONW|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (68, N'32242', 35, N'BRFSC', N'FUEL SURCHARGE', N'RESIDENTIAL', N'', N'', N'', N'Surcharge', N'', N'BRFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (69, N'17030-002', 1, N'C-TOT', N'COMPOST TOTER', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'C-TOT|', N' ', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (70, N'9576-001', 85, N'C32B', N'32 GAL BI-WKLY COMPOST', N'COMMERCIAL', N'', N'32', N'Gallon', N'Service', N'EOW', N'C32B|32', N'32 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (71, N'9649-001', 112, N'C32W', N'32 GAL WKLY COMPOST', N'COMMERCIAL', N'', N'32', N'Gallon', N'Service', N'1 per week', N'C32W|32', N'32 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (72, N'5652-001', 2, N'C32WQ', N'32 GAL WKLY COMPOST', N'COMMERCIAL', N'', N'32', N'Gallon', N'Service', N'1 per week', N'C32WQ|32', N'32 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (73, N'3939-001', 5, N'C68B', N'68 GAL BI-WKLY COMPOST', N'COMMERCIAL', N'', N'68', N'Gallon', N'Service', N'EOW', N'C68B|68', N'68 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (74, N'9577-003', 78, N'C68W', N'68 GAL WKLY COMPOST', N'COMMERCIAL', N'', N'68', N'Gallon', N'Service', N'1 per week', N'C68W|68', N'68 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (75, N'9663-001', 2, N'C6GBI', N'6 GALLON BI-WKLY COMP', N'RESIDENTIAL', N'', N'6', N'Gallon', N'Service', N'EOW', N'C6GBI|6', N'6 Gallon', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (76, N'9351-001', 3, N'CAR', N'CARDBOARD PICKUP', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'CAR|', N' ', N'Cardboard')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (77, N'9896-001', 622, N'CFSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'CFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (78, N'6223-001', 10, N'CFSC-B', N'COM FUEL SC', N'ACCOUNTING', N'', N'', N'', N'Surcharge', N'', N'CFSC-B|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (79, N'7567-001', 8, N'CFSC-Q', N'COM FUEL SC', N'ACCOUNTING', N'', N'', N'', N'Surcharge', N'', N'CFSC-Q|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (80, N'9577-001', 1, N'CL FEE', N'CLEANING FEE', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'CL FEE|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (81, N'9577-001', 19, N'COM', N'COMPOST', N'ACCOUNTING', N'', N'', N'', N'Service', N'', N'COM|', N' ', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (82, N'24145-001', 2, N'COM BAGS', N'COMPOST BAGS', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'COM BAGS|', N' ', N'Compost')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (83, N'3100-001', 3, N'CURB', N'CURBSIDE PICKUP', N'RESIDENTIAL', N'', N'', N'', N'Service', N'', N'CURB|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (84, N'5504-001', 53, N'F1.5', N'1.5YD CONTAINER', N'COMMERCIAL', N'', N'1.5', N'Yard', N'Service', N'', N'F1.5|1.5', N'1.5 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (85, N'5680-001', 4, N'F10YD', N'10YD CONTAINER', N'COMMERCIAL', N'', N'10', N'Yard', N'Service', N'', N'F10YD|10', N'10 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (86, N'31684', 1, N'F12YD', N'12YD CONTAINER', N'COMMERCIAL', N'', N'12', N'Yard', N'Service', N'', N'F12YD|12', N'12 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (87, N'9429-001', 38, N'F2YD', N'2YD CONTAINER', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'F2YD|2', N'2 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (88, N'30999', 13, N'F3YD', N'3YD CONTAINER', N'COMMERCIAL', N'', N'3', N'Yard', N'Service', N'', N'F3YD|3', N'3 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (89, N'31674', 10, N'F4YD', N'4YD CONTAINER', N'COMMERCIAL', N'', N'4', N'Yard', N'Service', N'', N'F4YD|4', N'4 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (90, N'30364-002', 8, N'F6YD', N'6YD CONTAINER', N'COMMERCIAL', N'', N'6', N'Yard', N'Service', N'', N'F6YD|6', N'6 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (91, N'31564', 7, N'F8YD', N'8YD CONTAINER', N'COMMERCIAL', N'', N'8', N'Yard', N'Service', N'', N'F8YD|8', N'8 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (92, N'1926-001', 1, N'FBIBIWKL', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'FBIBIWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (93, N'9429-001', 89, N'FCFSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'FCFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (94, N'8924-005', 92, N'FMONBI', N'BI WEEKLY', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'FMONBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (95, N'8300-005', 91, N'FMONWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'FMONWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (96, N'8924-005', 206, N'FRFSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'FRFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (97, N'1926-001', 1, N'FRFSC-B', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'FRFSC-B|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (98, N'5350-002', 54, N'FSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'FSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (99, N'6242-001', 1, N'FTS', N'FRIDAY TRASH SERVICE', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'FTS|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (100, N'26765', 2, N'HPU', N'HAND PICKUP', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'HPU|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (101, N'28901-001', 1, N'MAINT', N'MAINTENANCE FEE', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'MAINT|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (102, N'9991-001', 452, N'MONBBI', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'MONBBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (103, N'9976-006', 853, N'MONBI', N'BI WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'MONBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (104, N'9478-001', 637, N'MONBWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'MONBWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (105, N'9998-004', 1075, N'MONWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'MONWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (106, N'6242-001', 1, N'MTS', N'MONDAY TRASH SERVICE', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'MTS|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (107, N'9770-002', 80, N'QTRBBI', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'QTRBBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (108, N'9544-002', 51, N'QTRBI', N'BI-WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'QTRBI|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (109, N'9374-001', 77, N'QTRBW', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'QTRBW|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (110, N'9974-003', 57, N'QTRWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'QTRWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (111, N'7895-001', 8, N'R-TOT', N'RECYCLE TOTERS', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'R-TOT|', N' ', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (112, N'9669-001', 356, N'REC', N'RECYCLE PICKUP', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'REC|', N' ', N'Recycle')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (113, N'9613-002', 32, N'REN', N'RENTAL FEES', N'ROLL OFF', N'', N'', N'', N'Rent', N'', N'REN|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (114, N'9998-004', 2928, N'RFSC', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'RFSC|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (115, N'9879-001', 257, N'RFSC-B', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'RFSC-B|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (116, N'9974-003', 257, N'RFSC-Q', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'RFSC-Q|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (117, N'5436-001', 23, N'T-TOT', N'TRASH TOTER', N'RESIDENTIAL', N'', N'', N'', N'Service', N'', N'T-TOT|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (118, N'9649-001', 37, N'TFSC-M', N'ENVIRONMENTAL FEES', N'ACCOUNTING', N'', N'', N'', N'Fees', N'', N'TFSC-M|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (119, N'6978-049', 10, N'TOT', N'TOTERS', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'TOT|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (120, N'15495', 2, N'TOT RENTAL', N'RENTAL', N'ACCOUNTING', N'', N'', N'', N'Rent', N'', N'TOT RENTAL|', N' ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (121, N'31477', 1, N'TRA', N'TRASH SERVICE', N'COMMERCIAL', N'', N'', N'', N'Service', N'', N'TRA|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (122, N'32219', 16, N'UMONBIWKL', N'BI WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'EOW', N'UMONBIWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (123, N'32173', 9, N'UMONWKL', N'WEEKLY SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'1 per week', N'UMONWKL|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (124, N'9991-001', 932, N'WMT', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (125, N'9576-001', 5, N'WMT-10', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-10|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (126, N'25507-003', 3, N'WMT-11', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-11|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (127, N'26232', 1, N'WMT-12', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-12|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (128, N'8355-002', 2, N'WMT-13', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-13|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (129, N'10283-001', 1, N'WMT-15', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-15|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (130, N'8861-003', 133, N'WMT-2', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-2|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (131, N'19702', 1, N'WMT-23', N'WMT TAX AND ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-23|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (132, N'25140', 1, N'WMT-25', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-25|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (133, N'2662-001', 1, N'WMT-28', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-28|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (134, N'8678-001', 12, N'WMT-2B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-2B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (135, N'9182-001', 19, N'WMT-2Q', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-2Q|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (136, N'5984-011', 3, N'WMT-2T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-2T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (137, N'9281-001', 61, N'WMT-3', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-3|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (138, N'21047-001', 1, N'WMT-34', N'34 UNITS', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-34|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (139, N'8802-002', 2, N'WMT-3B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-3B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (140, N'7594-001', 7, N'WMT-3Q', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-3Q|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (141, N'6978-052', 5, N'WMT-3T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-3T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (142, N'8949-001', 44, N'WMT-4', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-4|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (143, N'4594-001', 1, N'WMT-49', N'WMT MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-49|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (144, N'28231', 3, N'WMT-4B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-4B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (145, N'3237-006', 1, N'WMT-4Q', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-4Q|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (146, N'6978-026', 3, N'WMT-4T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-4T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (147, N'8706-001', 19, N'WMT-5', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-5|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (148, N'8502-002', 22, N'WMT-6', N'WASTE MGT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-6|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (149, N'4072-001', 1, N'WMT-60', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-60|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (150, N'6035-001', 1, N'WMT-6B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-6B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (151, N'6978-015', 3, N'WMT-6T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-6T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (152, N'6587-001', 10, N'WMT-7', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-7|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (153, N'2930-001', 1, N'WMT-78', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-78|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (154, N'3983-006', 1, N'WMT-7B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-7B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (155, N'3586-013', 1, N'WMT-7T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-7T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (156, N'8502-003', 13, N'WMT-8', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-8|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (157, N'8861-002', 5, N'WMT-9', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-9|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (158, N'3586-014', 2, N'WMT-9T', N'WASTE MGMT TAX', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-9T|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (159, N'9811-001', 143, N'WMT-B', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-B|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (160, N'9770-002', 161, N'WMT-Q', N'WASTE MGMT TAX & ADM FEES', N'RESIDENTIAL', N'', N'na', N'', N'Fees', N'', N'WMT-Q|na', N'na ', N'')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (161, N'9577-001', 20, N'WS', N'WASTE SERVICE', N'RESIDENTIAL', N'', N'', N'', N'Service', N'', N'WS|', N' ', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (162, N'26766-001', 6, N'2-2', N'2-2YD CONTAINERS', N'COMMERCIAL', N'', N'2', N'Yard', N'Service', N'', N'2-2|2', N'2 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (163, N'28219-004', 3, N'2-8', N'2-8YD CONTAINERS', N'COMMERCIAL', N'', N'8', N'Yard', N'Service', N'', N'2-8|8', N'8 Yard', N'Other')

INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (164, N'21762-002', 3, N'32 GAL RECYCLE', N'32 GAL RECYCLE', N'RESIDENTIAL', N'', N'32', N'Gallon', N'Service', N'', N'32 GAL RECYCLE|32', N'32 Gallon', N'Recycle')




DROP TABLE IF EXISTS ServiceCodeUnitOfMeasure

select scd.ServiceCode, scd.ServiceDescription, scd.ServiceCategory, 
case when co.LINKSTAT = '' then  uom.DATA
else co.LINKSTAT end UnitOfMeasure
into ServiceCodeUnitOfMeasure
from ServiceCodeDetail scd
inner join ConversionData.dbo.CODE co on co.SVC_CODE_ALPHA = scd.ServiceCode
left join ConversionData.dbo.UDEF uom on uom.UNIQUE_ID = co.UNITMEASUR