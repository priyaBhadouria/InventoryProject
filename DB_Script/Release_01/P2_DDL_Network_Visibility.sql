--Network visibility
--Get Plant
DROP MATERIALIZED VIEW IF EXISTS validstage.plant_names_view;
CREATE materialized VIEW validstage.plant_names_view AS
SELECT DISTINCT rec_plant AS plant_name FROM validstage.plant_sap_valid_stage;

--Second level From Plant to Destination (FSG/Customer)

DROP MATERIALIZED VIEW IF EXISTS analytics.plant_to_fsg_names_view;
CREATE MATERIALIZED VIEW analytics.plant_to_fsg_names_view AS
SELECT DISTINCT location, location_type, source, source_type FROM analytics.div_transaction WHERE source_type='GE';


--Third  level From FSG to Destination (FSG/Customer)
DROP MATERIALIZED VIEW IF EXISTS analytics.fsg_to_fsg_names_view;
CREATE MATERIALIZED VIEW analytics.fsg_to_fsg_names_view AS
SELECT DISTINCT location, location_type, source, source_type FROM analytics.div_transaction WHERE source_type ='FSG' AND location_type='FSG';

DROP MATERIALIZED VIEW IF EXISTS analytics.fsg_to_customer_names_view;
CREATE MATERIALIZED VIEW analytics.fsg_to_customer_names_view AS
SELECT DISTINCT location, location_type, source, source_type FROM analytics.div_transaction WHERE source_type ='FSG' AND location_type='CUSTOMER';


--getTotalInventorySummary Reused from Total inventory page

--Plant Data table drill down

create sequence analytics.tree_data_table_plant_level_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE;

 create materialized view analytics.tree_data_table_plant_level_view as
  SELECT nextval('analytics.tree_data_table_plant_level_seq '::regclass) AS vid, material, material_description, 
SUM(COALESCE(quantity,0)) AS quantity,  uom AS unit_of_measure,storage_location AS location,rec_plant AS plant 
FROM validstage.plant_sap_valid_stage sap,master.material mm WHERE sap.material=mm.material_name GROUP BY 
material,material_description,storage_location,uom,rec_plant ;  


--2nd level Overview
CREATE materialized VIEW analytics.intransit_to_customer_view AS  
SELECT SUM(div_transaction.in_bound_transit_qty) as intransit_to_customer,div_transaction.source as location FROM analytics.div_transaction WHERE div_transaction.location_type='CUSTOMER' group by div_transaction.source;

CREATE materialized VIEW analytics.intransit_to_fsg_and_stock_at_fsg_view AS  
SELECT SUM(in_bound_transit_qty) as intransit_to_fsg,location, SUM(current_qty) as stock_service_provider FROM analytics.div_transaction
WHERE location_type='FSG'  group by location;


--2nd level data table drill down 
create materialized view analytics.inventory_drilldown_view as
SELECT material, material_description, sum(COALESCE(current_qty,0)) AS quantity, uom AS unit_of_measure,
location,source as plant FROM analytics.div_transaction div,master.material mm WHERE div.material=mm.material_name AND 
 current_qty !=0 AND location_type='FSG' and source is not null GROUP BY material,material_description,location,uom,source;

 
 --3nd level Overview
--CREATE materialized VIEW analytics.intransit_to_customer_view AS  
--SELECT SUM(div_transaction.in_bound_transit_qty) as intransit_to_customer,div_transaction.source as location FROM analytics.div_transaction WHERE div_transaction.location_type='CUSTOMER' group by div_transaction.source;

create materialized view analytics.tree_data_aggrigate_for_customer_level_view as
select sum(in_bound_transit_qty) as intransit_to_customer,location as customer,current_qty as quantity from 
analytics.div_transaction,master.material mm where location_type='CUSTOMER' group by location,current_qty;


CREATE SEQUENCE analytics.tree_data_table_for_customer_level_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

create materialized view analytics.tree_data_table_for_customer_level_view as
 select nextval('analytics.tree_data_table_for_customer_level_view_seq'::regclass) AS id,div.location as plant,mm.uom as unit_of_measure,div.location,COALESCE(sum(div.in_bound_transit_qty),0::numeric) as intransit_qty,div.location as customer,COALESCE(sum(div.current_qty),0::numeric) as current_qty,div.material,mm.material_description from analytics.div_transaction div,
master.material mm where div.material = mm.material_name and div.location_type='CUSTOMER' group by div.location,div.material,mm.material_description,mm.uom;




