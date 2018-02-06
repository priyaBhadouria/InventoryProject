
update staging.plant_sap_stage set material=LTRIM(material,'0');
 
-- Drill Down Calculation 

CREATE SEQUENCE analytics."customer_consumed_view_seq"  
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 25871
   CACHE 1
   NO CYCLE;
   
   
create materialized view analytics.customer_consumed_view as
  select nextval('analytics.customer_consumed_view_seq'::regclass) AS id, ai.customer as customer_site,mc.customer_desc,
  ai.material,mm.material_description,ai.assetinstalled as installed_qty,ai.installation_date as last_date ,
  ma.state,COALESCE(sum(received.actual_quantity),0) as returned_qty,ai.storage_location as fsg_served_location 
from analytics.Analytics_Installation ai LEFT JOIN validstage.fsg_receipt_valid_stage received on ai.customer = received.issued_from and received.receive_from_type='CUSTOMER',master.material mm,master.customer mc,master.address ma
where ai.material=mm.material_name and ai.customer=mc.customer_name and mc.address_id =ma.address_id group by ai.customer,mc.customer_desc,ai.material,mm.material_description,ai.assetinstalled,ai.installation_date,
  ma.state,ai.storage_location; 


-- Drill Down Table
CREATE SEQUENCE analytics."customer_consumption_drilldown_variance_view_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
   
CREATE MATERIALIZED VIEW analytics.customer_consumption_drilldown_variance_view AS
  Select nextval('analytics.customer_consumption_drilldown_variance_view_seq '::regclass) AS id,
   cust_consumption.customer_site,cust_consumption.customer_desc,cust_consumption.material,
   cust_consumption.material_description,cust_consumption.installed_qty,cust_consumption.last_date,
   cust_consumption.state,cust_consumption.returned_qty,cust_consumption.fsg_served_location,
   Variance_Calulcation.variance  from
   (Select * from analytics.customer_consumed_view) cust_consumption
  INNER JOIN
  (Select Instllation.material,Instllation.customer,Instllation.storage_location,(CUST_TRANSIT.transit_customer+CUST_TOTAL.current_qty_customer-Instllation.install)variance from
(Select material,customer,storage_location,coalesce(sum(assetinstalled),0)install from analytics.analytics_installation group by material,storage_location,customer)Instllation
LEFT JOIN
(Select material,location customer,source storage_location, coalesce(SUM(in_bound_transit_qty),0) transit_customer   
FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'AND SOURCE_TYPE='FSG'
group by location ,material,source)CUST_TRANSIT
On Instllation.material=CUST_TRANSIT.material and Instllation.customer=CUST_TRANSIT.customer and Instllation.storage_location=CUST_TRANSIT.storage_location
LEFT JOIN  
(Select material,location customer,source storage_location, coalesce(SUM(current_qty),0) current_qty_customer   
FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'AND SOURCE_TYPE='FSG'
group by location ,material,source)CUST_TOTAL
on CUST_TRANSIT.material=CUST_TOTAL.material and CUST_TRANSIT.customer =CUST_TOTAL.customer and CUST_TRANSIT.storage_location=CUST_TOTAL.storage_location)Variance_Calulcation
On  cust_consumption.material=Variance_Calulcation.material
and cust_consumption.customer_site=Variance_Calulcation.customer
and cust_consumption.fsg_served_location= Variance_Calulcation.storage_location;

--Header
CREATE OR REPLACE FUNCTION analytics.customer_consumption_aggregate(
OUT total_sites_installed numeric, 
 OUT assets_installed numeric, 
 OUT assets_returned numeric,
OUT totalvariance numeric
  ) AS $$
BEGIN
   total_sites_installed := COALESCE((select count(distinct(customer)) from analytics.Analytics_Installation),0);
   assets_installed := COALESCE((select sum(assetinstalled) from analytics.Analytics_Installation),0);
   assets_returned := COALESCE((select sum(in_bound_transit_qty) from analytics.div_transaction where location_type='FSG' AND source_type='CUSTOMER'),0.0);
   totalvariance := (select sum(greatest(0,variance)) from analytics.customer_consumption_drilldown_variance_view);  
   
   END;
$$ LANGUAGE plpgsql;


DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumption_overview_view;
create materialized view analytics.customer_consumption_overview_view as 
select * from analytics.customer_consumption_aggregate(); 


-- Chart
 create materialized view analytics.customer_summary_view as
select coalesce(sum(assetinstalled),0) as current_qty,ma.state, coalesce(sum(received.actual_quantity),0) as return_qty from analytics.Analytics_Installation install LEFT JOIN validstage.fsg_receipt_valid_stage received on install.customer = received.issued_from and received.receive_from_type='CUSTOMER',master.customer mc,master.address ma where install.customer=mc.customer_name and mc.address_id=ma.address_id group by ma.state;


 
  

