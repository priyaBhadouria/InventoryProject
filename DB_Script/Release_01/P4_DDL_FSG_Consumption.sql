 DROP SEQUENCE IF EXISTS analytics.fsg_inventory_summary_view_seq;
 CREATE SEQUENCE analytics.fsg_inventory_summary_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
 

 DROP MATERIALIZED VIEW IF EXISTS analytics.fsg_inventory_summary_view;
CREATE MATERIALIZED VIEW analytics.fsg_inventory_summary_view AS
Select nextval('analytics.fsg_inventory_summary_view_seq'::regclass) AS id, * FROM (
 SELECT 
fsg_current.material material,fsg_current.location fsg_loc,coalesce(SUM(fsg_current.in_bound_transit_qty),0) transit, coalesce(fsgNet.net,0) AS inventory  
FROM analytics.div_transaction fsg_current,analytics.FSG_DAILY_STOCK_NET_INVENTORY fsgNet WHERE fsg_current.LOCATION_type='FSG' and fsg_current.material=fsgNet.material and fsg_current.location=fsgNet.Storage_Location
GROUP BY fsg_loc,fsg_current.material,fsgNet.net
UNION
 SELECT plant_sap_valid_stage.material,
    plant_sap_valid_stage.storage_location AS fsg_loc,
    COALESCE(sum(plant_sap_valid_stage.quantity), 0::numeric) AS transit,
    COALESCE(0) AS inventory
   FROM validstage.plant_sap_valid_stage
  WHERE plant_sap_valid_stage.status = 'T'::bpchar 
  GROUP BY plant_sap_valid_stage.storage_location, plant_sap_valid_stage.material) as fsg_intransit;



CREATE SEQUENCE analytics.fsg_material_demand_inv_veiw_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.fsg_material_demand_inv_veiw;
CREATE MATERIALIZED VIEW analytics.fsg_material_demand_inv_veiw AS
Select coalesce(NULLIF(Fsg_Material_Demand_master.fsg_location,''),Fsg_Inv_Master.fsg_loc) as location,
coalesce(NULLIF(Fsg_Material_Demand_master.materialid,''),Fsg_Inv_Master.material) as materialid,
Fsg_Material_Demand_master.demand,Fsg_Material_Demand_master.fiscal_week,Fsg_Material_Demand_master.year,
Fsg_Inv_Master.inventory,Fsg_Inv_Master.transit from
(Select coalesce(sum(demand_overview.demand),0) demand,demand_overview.Storage_Location fsg_location,
demand_overview.materialid materialid,demand_overview.fiscal_week fiscal_week,demand_overview.year
from analytics.customer_fsg_material_demand_overview demand_overview 
Group by demand_overview.materialid ,demand_overview.Storage_Location,demand_overview.fiscal_week,demand_overview.year)Fsg_Material_Demand_master
FULL Join
(Select material,fsg_loc,greatest(0,transit) transit,greatest(0,inventory)inventory from analytics.fsg_inventory_summary_view )Fsg_Inv_Master
On Fsg_Material_Demand_master.fsg_location=Fsg_Inv_Master.fsg_loc
and Fsg_Material_Demand_master.materialid=Fsg_Inv_Master.material;





CREATE SEQUENCE analytics.fsg_material_consumption_rate_veiw_detail_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.fsg_material_consumption_rate_veiw_detail;
CREATE MATERIALIZED VIEW analytics.fsg_material_consumption_rate_veiw_detail AS
 Select distinct nextval('analytics.fsg_material_consumption_rate_veiw_detail_seq'::regclass) AS id,
demand_view.fsg_location,demand_view.materialid,matmaster.material_description  as materialdesc,
  demand_view.demand,demand_view.fiscal_week,demand_view.year,demand_view.inventory,
  demand_view.transit,demand_view.shortage FROM
(Select storage_location as fsg_location,material as materialid,sum(demand) as demand,
fiscal_week,year,stock as inventory,transit,sum(shortage) as shortage
from analytics.FSG_ACTUAL_DEMAND_STOCK 
group by fiscal_week,year,material,storage_location,stock,transit)demand_view 
LEFT JOIN
 master.material matmaster on  demand_view.materialid=matmaster.material_name
order by demand_view.fiscal_week,demand_view.year;



CREATE SEQUENCE analytics.fsg_consumption_rate_all_veiw_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.fsg_consumption_rate_all_veiw AS
Select nextval('analytics.fsg_consumption_rate_all_veiw_seq'::regclass) AS id,
transitview.fsg_loc as fsg_location,transitview.tans as fsg_transit,
inventoryview.inv as fsg_inventory, demandview.demand as fsg_demand,
shortageview.shortage as fsg_shortage from  
(Select fsg_loc,coalesce(sum(transit),0) as tans from analytics.fsg_inventory_summary_view group by fsg_loc)transitview,
(Select fsg_loc, coalesce(sum(inventory),0) as inv from analytics.fsg_inventory_summary_view group by fsg_loc)inventoryview,
(Select fsg_location,coalesce(sum(demand),0) as demand from analytics.fsg_material_consumption_rate_veiw_detail group by fsg_location)demandview, 
(Select fsg_location,coalesce(sum(shortage),0) as shortage from analytics.fsg_material_consumption_rate_veiw_detail group by fsg_location)shortageview
 where inventoryview.fsg_loc=transitview.fsg_loc
  and inventoryview.fsg_loc=demandview.fsg_location
  and inventoryview.fsg_loc=shortageview.fsg_location;

  
  

 CREATE SEQUENCE analytics.All_Location_consumption_rate_veiw_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.All_Location_consumption_rate_veiw AS
Select distinct nextval('analytics.All_Location_consumption_rate_veiw_seq'::regclass) AS id,
transitview.tans as all_transit,inventoryview.inv as all_inventory,
demandview.demand as all_demand,shortageview.shortage as all_shortage from  
(Select coalesce(sum(transit),0) as tans from analytics.fsg_inventory_summary_view)transitview,
(Select coalesce(sum(inventory),0) as inv from analytics.fsg_inventory_summary_view)inventoryview, 
(Select coalesce(sum(demand),0) as demand from analytics.fsg_material_consumption_rate_veiw_detail)demandview, 
(Select coalesce(sum(shortage),0) as shortage from analytics.fsg_material_consumption_rate_veiw_detail)shortageview;


---- ********************* FSG Overview db script start  ***************************---------------

DROP FUNCTION IF EXISTS validstage.fsg_overview_dollar_value_summary();
CREATE OR REPLACE FUNCTION validstage.fsg_overview_dollar_value_summary( 
 OUT transit_to_FSG DECIMAL, 
 OUT at_FSG DECIMAL,   
 OUT fsg_demand DECIMAL,
 OUT fsg_shortage DECIMAL
) AS $$
BEGIN
  
   transit_to_FSG := COALESCE((SELECT SUM(material_cost) FROM (SELECT COALESCE(SUM(in_bound_transit_qty * cost),0) AS material_cost FROM analytics.div_transaction, master.material WHERE LOCATION_type='FSG' AND material=material_name GROUP BY material) AS intransit_cost),0) ;
   at_FSG := COALESCE((SELECT SUM(material_cost) FROM (SELECT COALESCE(SUM(current_qty * cost),0) AS material_cost FROM analytics.div_transaction, master.material WHERE LOCATION_type='FSG' AND material=material_name GROUP BY material) AS inventory_at_fsg_cost),0);   
   fsg_demand := COALESCE((SELECT SUM(demand_cost) FROM (SELECT COALESCE(SUM(demand * cost),0) AS demand_cost FROM analytics.customer_fsg_demand_shortage_view_final, master.material WHERE materialid=material_name GROUP BY materialid) AS demand_cost),0);
   --fsg_shortage := COALESCE((SELECT SUM(shortage_cost) FROM (SELECT COALESCE(SUM(shortage * cost),0) AS shortage_cost FROM analytics.fsg_material_consumption_rate_veiw_new, master.material WHERE materialid=material_name GROUP BY materialid) AS shortage_cost),0);
   fsg_shortage := COALESCE((SELECT SUM(shortage_cost) FROM (SELECT COALESCE(MAX(shortage) * cost,0) AS shortage_cost FROM analytics.fsg_material_consumption_rate_veiw_detail T1, master.material T2 WHERE T1.materialid=T2.material_name GROUP BY fsg_location,materialid,cost) AS shortage_cost),0);
END;
$$ LANGUAGE plpgsql;
 
-- Creates materialized view for aggregation details of Total inventory.
DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_overview_dollar_value_summary_view;
CREATE MATERIALIZED VIEW validstage.fsg_overview_dollar_value_summary_view AS 
SELECT * FROM validstage.fsg_overview_dollar_value_summary();

---- ********************* FSG Overview db script end  ***************************---------------



CREATE SEQUENCE analytics.fsg_material_demand_detail_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.fsg_material_demand_detail_new AS
Select nextval('analytics.customer_material_demand_detail_seq'::regclass) AS id,
actual_data.project,actual_data.fiscal_week,actual_data.year,
  actual_data.fsg_order_num,actual_data.currentweek,actual_data.customerId,
  actual_data.materialid,actual_data.demand_qty,actual_data.storage_location
  from
(Select distinct smartsheet.project,smartsheet.fiscal_week, smartsheet.transaction_year as year,
smartsheet.fsg_order_num,
cur_wk.current_week as currentweek,smartsheet.customer as customerId,
demand.material materialid,demand.quantity demand_qty,
demand.storage_location
from 
(Select extract(week from now())as current_week)cur_wk,
(Select extract(year from now())as current_year)cur_yr,
validstage.customer_install_demand smartsheet,
validstage.inventory_sp_demand demand
where
((smartsheet.fiscal_week>=cur_wk.current_week and smartsheet.transaction_year=cur_yr.current_year)
or
(smartsheet.transaction_year>cur_yr.current_year))
and smartsheet.fsg_order_num is null
and smartsheet.project=demand.project_definition)actual_data;



CREATE SEQUENCE analytics.fsg_material_demand_overview_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.fsg_material_demand_overview_new AS
Select nextval('analytics.fsg_material_demand_overview_seq'::regclass) AS id,
coalesce(sum(demand.demand_qty),0) AS demand,
demand.Storage_Location fsg_location,demand.materialid materialid,
demand.fiscal_week fiscal_week,demand.year as year
from analytics.fsg_material_demand_detail_new  demand 
Group by demand.materialid ,demand.Storage_Location,demand.fiscal_week,demand.year;



 CREATE SEQUENCE analytics.fsg_material_customer_demand_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.fsg_material_customer_demand_view AS
 Select nextval('analytics.fsg_material_customer_demand_seq'::regclass) AS id,
 consumption_view.storage_location,consumption_view.demand  as demand_qty,consumption_view.customerid,cust.customer_desc,
 consumption_view.material as materialid,consumption_view.fiscal_week,consumption_view.year,consumption_view.shortage 
 from analytics.FSG_ACTUAL_DEMAND_STOCK consumption_view
 left Join master.Customer cust on consumption_view.customerId=cust.customer_name;
 
 

CREATE MATERIALIZED VIEW analytics.fsg_customer_demand_master_view_ordered AS
Select coalesce(NULLIF(Fsg_Material_Demand_master.fsg_location,''),Fsg_Inv_Master.fsg_loc) as storage_location,
coalesce(NULLIF(Fsg_Material_Demand_master.materialid,''),Fsg_Inv_Master.material) as materialid,
Fsg_Material_Demand_master.demand as demand,Fsg_Material_Demand_master.fiscal_week as fiscal_week,
Fsg_Material_Demand_master.year as year,Fsg_Inv_Master.inventory as stock,
Fsg_Inv_Master.transit as transit,Fsg_Material_Demand_master.customerid as customerid from
(Select demand_overview.demand demand,demand_overview.Storage_Location fsg_location,demand_overview.customerid,
demand_overview.materialid materialid,demand_overview.fiscal_week fiscal_week,demand_overview.year
from analytics.customer_fsg_material_demand_overview demand_overview)Fsg_Material_Demand_master
 FULL Join
(Select material,fsg_loc,greatest(0,transit) transit,greatest(0,inventory)inventory from analytics.fsg_inventory_summary_view )Fsg_Inv_Master
On Fsg_Material_Demand_master.fsg_location=Fsg_Inv_Master.fsg_loc
and Fsg_Material_Demand_master.materialid=Fsg_Inv_Master.material
order by Fsg_Material_Demand_master.fiscal_week,Fsg_Material_Demand_master.year, Fsg_Material_Demand_master.materialid,
Fsg_Material_Demand_master.fsg_location,Fsg_Material_Demand_master.customerid;





CREATE OR REPLACE FUNCTION analytics.save_FSG_actual_demand_stock()
RETURNS integer AS
$$
DECLARE
  demand_stock_row RECORD;
  total_stock Decimal;
  transit_record Decimal;
   stock_record Decimal;
   actualstock Decimal;
  actual_demand Decimal;
  shortage Decimal;
    
BEGIN
    Truncate analytics.FSG_ACTUAL_DEMAND_STOCK;
    FOR demand_stock_row in Select Materialid,customerid,Storage_Location,demand,fiscal_week,year,stock,transit
from analytics.fsg_customer_demand_master_view_ordered  
   
    LOOP


   actual_demand = demand_stock_row.demand;
   transit_record = demand_stock_row.transit;
   stock_record = demand_stock_row.stock;
   
   IF stock_record IS NULL THEN
   stock_record=0;
   END IF;
   IF transit_record IS NULL THEN
   transit_record=0;
   END IF;
      
   total_stock = stock_record+transit_record;

     
    actualstock:=(Select min(actual_stock) from analytics.FSG_ACTUAL_DEMAND_STOCK where Material=demand_stock_row.materialid
   and Storage_Location=demand_stock_row.Storage_Location);
     
   shortage=0;
   IF actualstock IS NULL THEN
      actualstock=total_stock;
   END IF;
   IF actual_demand is NULL THEN 
shortage=null;  
        actualstock=total_stock;
   ELSEIF actual_demand > actualstock THEN
      shortage=greatest(0,(actual_demand-actualstock));
      actualstock=0;    
   ELSEIF actual_demand < actualstock THEN
       actualstock=actualstock-actual_demand;
      shortage=0;
   ELSEIF actual_demand =actualstock THEN
     actualstock=0;
     shortage=0;
   END IF;  
   
        
   Insert Into analytics.FSG_ACTUAL_DEMAND_STOCK(Material,customerid,Storage_Location,demand,fiscal_week,year,stock,transit,actual_stock,shortage)
  VALUES(demand_stock_row.Materialid,demand_stock_row.customerid,demand_stock_row.Storage_Location,demand_stock_row.demand,
  demand_stock_row.fiscal_week,demand_stock_row.year,stock_record,transit_record,actualstock,shortage);             
    
   END LOOP;
   return 1;
    exception when others then
        raise 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise '% %', SQLERRM, SQLSTATE;
  return 0;    

  
END;
$$
LANGUAGE 'plpgsql';



CREATE MATERIALIZED VIEW analytics.fsg_customer_demand_master_view_ordered AS
Select coalesce(NULLIF(Fsg_Material_Demand_master.fsg_location,''),Fsg_Inv_Master.fsg_loc) as storage_location,
coalesce(NULLIF(Fsg_Material_Demand_master.materialid,''),Fsg_Inv_Master.material) as materialid,
Fsg_Material_Demand_master.demand as demand,Fsg_Material_Demand_master.fiscal_week as fiscal_week,
Fsg_Material_Demand_master.year as year,Fsg_Inv_Master.inventory as stock,
Fsg_Inv_Master.transit as transit,Fsg_Material_Demand_master.customerid as customerid from
(Select demand_overview.demand demand,demand_overview.Storage_Location fsg_location,demand_overview.customerid,
demand_overview.materialid materialid,demand_overview.fiscal_week fiscal_week,demand_overview.year
from analytics.customer_fsg_material_demand_overview demand_overview)Fsg_Material_Demand_master
 FULL Join
(Select material,fsg_loc,greatest(0,transit) transit,greatest(0,inventory)inventory from analytics.fsg_inventory_summary_view )Fsg_Inv_Master
On Fsg_Material_Demand_master.fsg_location=Fsg_Inv_Master.fsg_loc
and Fsg_Material_Demand_master.materialid=Fsg_Inv_Master.material
order by Fsg_Material_Demand_master.fiscal_week,Fsg_Material_Demand_master.year, Fsg_Material_Demand_master.materialid,
Fsg_Material_Demand_master.fsg_location,Fsg_Material_Demand_master.customerid;


 