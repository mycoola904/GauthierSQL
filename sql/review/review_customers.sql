use ModMigration

-- Return the count of unique Customers in CustomerLocations
select count(1) 
from CustomerLocations cl 
where cast(c_id as varchar) = UniqRef

-- Return the count of the Customers in the source data
select count(1) from ConversionData.dbo.CUST 

--  Find any missing Customer Locations
select cu.c_id_alpha Account
from ConversionData.dbo.CUST cu
left join (
	select c_id from CustomerLocations where cast(c_id as varchar) = UniqRef
	) cl on cl.c_id = cu.c_id 
where cl.C_ID is null