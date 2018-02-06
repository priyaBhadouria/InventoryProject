
---- ********************* Dependent view's For Total Inventory  ***************************---------------

CREATE MATERIALIZED VIEW analytics.customer_fsg_demand_master_view_ordered AS
Select * from analytics.customer_fsg_demand_master_view order by fiscal_week,year, materialid,storage_location,customerid;


CREATE OR REPLACE FUNCTION analytics.save_actual_demand_stock()
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
  Truncate analytics.ACTUAL_DEMAND_STOCK;
    FOR demand_stock_row in Select Materialid,customerid,Storage_Location,demand,fiscal_week,year,stock,transit,transit_customer
  from analytics.customer_fsg_demand_master_view_ordered  
  
    LOOP
    actual_demand = demand_stock_row.demand;
   transit_record = demand_stock_row.transit;
     stock_record = demand_stock_row.stock;
     total_stock = stock_record+transit_record;

     
    actualstock:=(Select min(actual_stock) from analytics.ACTUAL_DEMAND_STOCK where Material=demand_stock_row.materialid
   and Storage_Location=demand_stock_row.Storage_Location);
     
    shortage=0;
   IF actualstock IS NULL THEN
      actualstock=total_stock;
   END IF;
    
   IF actual_demand > actualstock THEN
      shortage=greatest(0,(actual_demand-actualstock-demand_stock_row.transit_customer));
      actualstock=0;    
   ELSEIF actual_demand < actualstock THEN
       actualstock=actualstock-actual_demand;
      shortage=0;
   ELSEIF actual_demand =actualstock THEN
     actualstock=0;
     shortage=0;
   END IF;  
    
        
  Insert Into analytics.ACTUAL_DEMAND_STOCK(Material,customerid,Storage_Location,demand,fiscal_week,year,stock,transit,transit_customer,actual_stock,shortage)
  VALUES(demand_stock_row.Materialid,demand_stock_row.customerid,demand_stock_row.Storage_Location,demand_stock_row.demand,
  demand_stock_row.fiscal_week,demand_stock_row.year,demand_stock_row.stock,demand_stock_row.transit,
  demand_stock_row.transit_customer,actualstock,shortage);             
    

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




CREATE SEQUENCE analytics.customer_material_demand_detail_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.customer_material_demand_detail;
CREATE MATERIALIZED VIEW analytics.customer_material_demand_detail AS
Select nextval('analytics.customer_material_demand_detail_seq'::regclass) AS id,
smartsheet.project,smartsheet.fiscal_week, smartsheet.transaction_year as year,
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
and smartsheet.project=demand.project_definition;


CREATE SEQUENCE analytics.customer_fsg_material_demand_overview_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.customer_fsg_material_demand_overview;
CREATE MATERIALIZED VIEW analytics.customer_fsg_material_demand_overview AS
Select demand.storage_location,coalesce(sum(demand.demand_qty),0) AS demand,
demand.materialid materialid,demand.customerId,
demand.fiscal_week fiscal_week,demand.year as year
from analytics.customer_material_demand_detail  demand 
Group by demand.customerId,demand.storage_location,demand.materialid,demand.fiscal_week,demand.year;




DROP MATERIALIZED VIEW IF EXISTS analytics.customer_fsg_demand_master_view;
CREATE MATERIALIZED VIEW analytics.customer_fsg_demand_master_view AS
Select demand_overview.customerid,demand_overview.materialid, demand_overview.storage_location,demand_overview.demand,demand_overview.fiscal_week,demand_overview.year,
coalesce(FSGINV.stock,0)stock,coalesce(FSGTRANSIT.transit,0)transit,coalesce(Master_Fsg_Customer .transit_customer,0)transit_customer
from  analytics.customer_fsg_material_demand_overview demand_overview
LEFT JOIN
(Select source,location customter,material,greatest(0,SUM(in_bound_transit_qty)) transit_customer   
FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'AND SOURCE_TYPE='FSG'
group by source,location,material)Master_Fsg_Customer 
ON demand_overview.customerid=Master_Fsg_Customer.customter and demand_overview.materialid=Master_Fsg_Customer.material
and demand_overview.storage_location=Master_Fsg_Customer.source
LEFT JOIN
(Select material,location,greatest(0,SUM(current_qty)) AS stock
from analytics.div_transaction WHERE LOCATION_type='FSG' GROUP BY material,location)FSGINV
ON FSGINV.location=demand_overview.storage_location and FSGINV.material=demand_overview.materialid
LEFT JOIN
(Select material,location,sum(transit) as transit from
(Select material,location,greatest(0,SUM(in_bound_transit_qty)) transit 
FROM analytics.div_transaction WHERE LOCATION_type='FSG' GROUP BY material,location having SUM(in_bound_transit_qty)>0 
UNION
 SELECT plant_sap_valid_stage.material,
    plant_sap_valid_stage.storage_location AS location,
    COALESCE(sum(plant_sap_valid_stage.quantity), 0::numeric) AS transit
   FROM validstage.plant_sap_valid_stage
  WHERE plant_sap_valid_stage.status = 'T' GROUP BY location, plant_sap_valid_stage.material) as fsg_intransit group by material,location)FSGTRANSIT
ON FSGTRANSIT.location=demand_overview.storage_location and FSGTRANSIT.material=demand_overview.materialid;



CREATE FUNCTION analytics."calculate_shortage"(transaction_yr integer, transaction_wk integer, customer character varying, location character varying,material character varying) RETURNS numeric AS $$  

DECLARE
shortage Decimal:=0;
actualdemand decimal:=0;
totaldemand decimal:=0;
currentstock decimal:=0;
fsgtransit decimal:=0;
custtransit decimal:=0;
current_wk integer;
current_yr integer;
BEGIN
    current_wk:=(Select extract(week from now()));
    current_yr:=(Select extract(year from now()));
    currentstock:=(Select stock from analytics.customer_fsg_demand_master_view where 
                                 materialid=material and customerid=customer and storage_location=location and fiscal_week=transaction_wk and year=transaction_yr);
    fsgtransit:=(Select transit from analytics.customer_fsg_demand_master_view where materialid=material and storage_location=location and customerid=customer and fiscal_week=transaction_wk and year=transaction_yr);
custtransit:=(Select transit_customer from analytics.customer_fsg_demand_master_view where materialid=material and storage_location=location and customerid=customer and fiscal_week=transaction_wk and year=transaction_yr);
   IF transaction_yr>current_yr THEN
     FOR i in current_wk..52 Loop
    actualdemand :=(Select demand from analytics.customer_fsg_demand_master_view where materialid=material and storage_location=location and customerid=customer and fiscal_week=i and year=current_yr);
        IF actualdemand is NOT NULL THEN
        totaldemand =totaldemand+actualdemand;
        END IF;
      END LOOP;
     

    FOR i in 0..transaction_wk Loop
      actualdemand :=(Select demand from analytics.customer_fsg_demand_master_view where materialid=material and storage_location=location and customerid=customer and fiscal_week=i and year=transaction_yr);
          IF actualdemand is NOT NULL THEN
           totaldemand=totaldemand+actualdemand; 
          END IF;
     END LOOP;    

  ELSE IF current_yr=transaction_yr THEN
      FOR i IN current_wk..transaction_wk LOOP
       actualdemand :=(Select demand from analytics.customer_fsg_demand_master_view where materialid=material and storage_location=location and customerid=customer and fiscal_week=i and year=transaction_yr);
        IF actualdemand is NOT NULL THEN
        totaldemand =totaldemand+actualdemand;
        END IF;
       END LOOP;  
    END IF;    
   END IF; 
    
    IF totaldemand>0 THEN
    shortage =totaldemand-(currentstock+fsgtransit+custtransit);
    shortage =greatest(0,shortage);
   END IF;
   

    return shortage ;
   END
$$ LANGUAGE plpgsql;


CREATE SEQUENCE analytics.customer_fsg_demand_shortage_week_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.customer_fsg_demand_shortage_week_view;
CREATE MATERIALIZED VIEW analytics.customer_fsg_demand_shortage_week_view AS
 SELECT customer_fsg_demand_master_view.customerid,
    customer_fsg_demand_master_view.materialid,
    customer_fsg_demand_master_view.storage_location,
    customer_fsg_demand_master_view.demand,
    customer_fsg_demand_master_view.fiscal_week,
    customer_fsg_demand_master_view.year,
    customer_fsg_demand_master_view.stock,
    customer_fsg_demand_master_view.transit,
    customer_fsg_demand_master_view.transit_customer,
    analytics.calculate_shortage(customer_fsg_demand_master_view.year, customer_fsg_demand_master_view.fiscal_week, customer_fsg_demand_master_view.customerid, customer_fsg_demand_master_view.storage_location, customer_fsg_demand_master_view.materialid::character varying) AS shortage
   FROM analytics.customer_fsg_demand_master_view;



CREATE SEQUENCE analytics.customer_demand_shortage_view_new_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
  DROP MATERIALIZED VIEW IF EXISTS analytics.customer_demand_shortage_view_new;
   CREATE MATERIALIZED VIEW analytics.customer_demand_shortage_view_new AS
 Select nextval('analytics.customer_demand_shortage_view_new_seq'::regclass) AS id,
  CUST_DEMAND.customerid,customermaster.customer_desc,CUST_DEMAND.fiscal_week,CUST_DEMAND.year,CUST_DEMAND.demand,CUST_SHORTAGE.shortage
  from
  (Select customerid,sum(demand) demand,fiscal_week,year from analytics.ACTUAL_DEMAND_STOCK 
  group by customerid,fiscal_week,year)CUST_DEMAND
  INNER JOIN
  (Select customerid,sum(shortage) shortage,fiscal_week,year from analytics.ACTUAL_DEMAND_STOCK
  group by customerid,fiscal_week,year)CUST_SHORTAGE  
  On CUST_DEMAND.customerid=CUST_SHORTAGE.customerid and CUST_DEMAND.fiscal_week=CUST_SHORTAGE.fiscal_week and CUST_DEMAND.year=CUST_SHORTAGE.year
 LEFT Join
  master.customer customermaster On CUST_DEMAND.customerid=customermaster.customer_name
  Order by CUST_DEMAND.fiscal_week,CUST_DEMAND.year;

  
  
  
  
  ---- ********************* Total Inventory db script start  ***************************---------------
CREATE OR REPLACE FUNCTION analytics.total_inventory_summary(
 OUT total_quantity DECIMAL, 
 OUT transit_to_FSG DECIMAL, 
 OUT at_FSG DECIMAL, 
 OUT transit_to_customer DECIMAL, 
 OUT at_customer DECIMAL, 
 OUT total_consuption DECIMAL,
 OUT total_customer_demand DECIMAL
) AS $$
BEGIN
  /* total_quantity := COALESCE((SELECT SUM(quantity) FROM validstage.plant_sap_valid_stage),0); 
     total_quantity := COALESCE((select sum(quantity) from validstage.plant_sap_valid_stage),0) + 223476;   
   transit_to_FSG := COALESCE((SELECT SUM(in_bound_transit_qty) FROM analytics.div_transaction WHERE LOCATION_type='FSG' AND (source_type='FSG' OR source_type='GE')),0);
   */
   transit_to_FSG := COALESCE((SELECT SUM(quantity) FROM validstage.plant_sap_valid_stage WHERE status is null OR status ='T'),0) + COALESCE((SELECT SUM(in_bound_transit_qty) FROM analytics.div_transaction WHERE location_type='FSG' AND source_type='FSG'),0);
   at_FSG := COALESCE((SELECT SUM(current_qty) FROM analytics.div_transaction WHERE LOCATION_type='FSG'),0);
   transit_to_customer := COALESCE((SELECT SUM(in_bound_transit_qty) FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'),0);
   at_customer := COALESCE((SELECT SUM(current_qty) FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'),0);
   total_consuption := COALESCE((SELECT SUM(current_qty) FROM analytics.div_transaction WHERE LOCATION_type='CUSTOMER'),0);
   total_quantity := COALESCE((SELECT SUM(quantity) FROM validstage.plant_sap_valid_stage),0);
   --total_customer_demand := COALESCE((SELECT SUM(demand_qty) AS qty FROM analytics.fsg_material_demand_detail),0);
   total_customer_demand := COALESCE((SELECT SUM(demand) FROM analytics.customer_demand_shortage_view_new),0);
END;
$$ LANGUAGE plpgsql;
 
-- Creates materialized view for aggregation details of Total inventory.
DROP MATERIALIZED VIEW IF EXISTS analytics.total_inventory_summary_view;
CREATE MATERIALIZED VIEW analytics.total_inventory_summary_view AS 
SELECT * FROM analytics.total_inventory_summary();



-- Creating materialized view and view sequence for GE total shipment drill down details.
DROP SEQUENCE IF EXISTS analytics.ge_shipment_drill_down_view_seq; 
CREATE SEQUENCE analytics.ge_shipment_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.ge_shipment_drill_down_view;
CREATE materialized VIEW analytics.ge_shipment_drill_down_view AS
SELECT nextval('analytics.ge_shipment_drill_down_view_seq'::regclass) AS vid, material, material_description, SUM(COALESCE(quantity,0)) AS quantity, cost, SUM(COALESCE(quantity * cost,0)) AS material_cost, uom AS unit_of_measure, storage_location AS location, status FROM validstage.plant_sap_valid_stage sap,master.material mm WHERE sap.material=mm.material_name GROUP BY material,material_description,cost,storage_location,uom,status;


-- Intransit to FSG
DROP SEQUENCE IF EXISTS analytics.inventory_transit_to_fsg_drill_down_view_seq;
CREATE SEQUENCE analytics.inventory_transit_to_fsg_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;


CREATE materialized VIEW analytics.inventory_transit_to_fsg_drill_down_view AS
   SELECT nextval('analytics.inventory_transit_to_fsg_drill_down_view_seq'::regclass) AS id,
    sap.material,
    mm.material_description,
    sum(sap.quantity) AS quantity,
    mm.cost,
    COALESCE(sum(sap.quantity) * mm.cost, 0::numeric) AS material_cost,
    mm.uom AS unit_of_measure,
    sap.storage_location AS to_location,
    sap.data_source AS from_location,
    sap.pro_number,
    sap.carrier_name
   FROM validstage.plant_sap_valid_stage sap,
    master.material mm
  WHERE sap.material::text = mm.material_name::text AND (sap.status IS NULL OR sap.status = 'T'::bpchar)
  GROUP BY sap.material, mm.material_description, mm.cost, mm.uom, sap.storage_location, sap.data_source, sap.pro_number, sap.carrier_name
UNION ALL
 SELECT nextval('analytics.inventory_transit_to_fsg_drill_down_view_seq'::regclass) AS id,
    div.material,
    mm.material_description,
    sum(COALESCE(div.in_bound_transit_qty, 0::numeric)) AS quantity,
    mm.cost,
    sum(COALESCE(div.in_bound_transit_qty * mm.cost, 0::numeric)) AS material_cost,
    mm.uom AS unit_of_measure,
    div.location AS to_location,
    div.source AS from_location,
    ''::character varying AS pro_number,
    ''::character varying AS carrier_name
   FROM analytics.div_transaction div,
    master.material mm
  WHERE div.material::text = mm.material_name::text AND div.location_type::text = 'FSG'::text AND div.source_type::text = 'FSG'::text
  GROUP BY div.material, mm.material_description, mm.cost, mm.uom, div.location, div.source;
  

--Stock at Service Provider
DROP SEQUENCE IF EXISTS analytics.inventory_at_fsg_drill_down_view_seq;
CREATE SEQUENCE analytics.inventory_at_fsg_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.inventory_at_fsg_drill_down_view; 
CREATE materialized VIEW analytics.inventory_at_fsg_drill_down_view AS
SELECT nextval('analytics.inventory_at_fsg_drill_down_view_seq'::regclass) AS id, material, material_description, sum(COALESCE(current_qty,0)) AS quantity, cost,sum(COALESCE(current_qty * cost,0)) AS material_cost, uom AS unit_of_measure, location, order_status FROM analytics.div_transaction div,master.material mm WHERE div.material=mm.material_name AND current_qty !=0 AND location_type='FSG' GROUP BY material,material_description,cost,location,uom,order_status;

DROP SEQUENCE IF EXISTS validstage.fsg_issued_valid_stage_view_seq;
CREATE SEQUENCE validstage.fsg_issued_valid_stage_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_issued_valid_stage_view; 
CREATE materialized VIEW validstage.fsg_issued_valid_stage_view AS
SELECT nextval('validstage.fsg_issued_valid_stage_view_seq'::regclass) AS id, T1.material, T2.material_description, T1.issued_from, SUM(COALESCE(T1.quantity_shipped,0)) AS quantity, T2.cost, SUM(COALESCE(T1.quantity_shipped * T2.cost,0)) AS material_cost, T2.uom AS unit_of_measure FROM validstage.fsg_issued_valid_stage T1, master.material T2  WHERE issued_date >= (SELECT CURRENT_DATE -1) AND T1.material=T2.material_name GROUP BY T1.material,T1.issued_from,T2.material_description,T2.cost,T2.uom;

DROP SEQUENCE IF EXISTS validstage.fsg_receipt_valid_stage_view_seq;
CREATE SEQUENCE validstage.fsg_receipt_valid_stage_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_receipt_valid_stage_view; 
CREATE materialized VIEW validstage.fsg_receipt_valid_stage_view AS
SELECT nextval('validstage.fsg_receipt_valid_stage_view_seq'::regclass) AS id, T1.material, T2.material_description, T1.received_to, SUM(COALESCE(T1.actual_quantity,0)) AS quantity, T2.cost, SUM(COALESCE(T1.actual_quantity * T2.cost,0)) AS material_cost, T2.uom AS unit_of_measure FROM validstage.fsg_receipt_valid_stage T1, master.material T2 WHERE T1.receipt_date >= (SELECT CURRENT_DATE -1) AND T1.material=T2.material_name GROUP BY T1.material, T1.received_to, T2.material_description, T2.cost, T2.uom;

-- each fsg aggregated values like on_hand,demand,shortage,in_transit

create materialized view analytics.summary_view_stock_at_service_provider as select * from (
select storage_location, coalesce(sum(prev_stock),0.0) as on_hand,sum(coalesce((prev_stock* cost),0.0)) as on_hand_cost from analytics.FSG_DAILY_STOCK_NET_INVENTORY fsg_daily_stock,master.material master_mat where fsg_daily_stock.material=master_mat.material_name group by storage_location) fsg_inventory
left join
(select fsg_location,fsg_desc,coalesce(sum(demand),0.0) as demand,coalesce(sum(shortage),0.0) as shortage,sum(coalesce((demand* cost),0.0)) as demand_cost,sum(coalesce((shortage* cost),0.0)) as shortage_cost from analytics.fsg_material_consumption_rate_veiw_detail all_fsg,master.material master_mat,master.fsg master_fsg where all_fsg.materialid=master_mat.material_name and all_fsg.fsg_location=master_fsg.fsg_party_name group by fsg_location,fsg_desc) all_fsg_consumption
on all_fsg_consumption.fsg_location=fsg_inventory.storage_location
left join
(
select to_location,coalesce(sum(quantity),0.0) as intransit,sum(coalesce((quantity*cost),0.0)) as transit_cost from analytics.inventory_transit_to_fsg_drill_down_view intransit_fsg group by to_location
)transit_fsg
on all_fsg_consumption.fsg_location=transit_fsg.to_location;



--- FINAL BO,COM
DROP MATERIALIZED VIEW IF EXISTS analytics.FSG_DAILY_STOCK_NET_INVENTORY_VIEW;
CREATE SEQUENCE analytics.FSG_DAILY_STOCK_NET_INVENTORY_VIEW_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
CREATE MATERIALIZED VIEW analytics.FSG_DAILY_STOCK_NET_INVENTORY_VIEW AS
select nextval('analytics.FSG_DAILY_STOCK_NET_INVENTORY_VIEW_seq'::regclass) as fsg_daily_stock_id,STORAGE_LOCATION,material,material_description,prev_stock,Received,Issued,com,bo,curr_stock,net,uom as unit_of_measure,coalesce(NULLIF(cost,0),0)*curr_stock as cost,created_dtm from analytics.FSG_DAILY_STOCK_NET_INVENTORY netInventory ,master.material mm WHERE netInventory.material=mm.material_name;





--END
--Stock at Service Provider Ends
--In Transit to Customer
DROP SEQUENCE IF EXISTS analytics.inventory_transit_to_customer_drill_down_view_seq; 
CREATE SEQUENCE analytics.inventory_transit_to_customer_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.inventory_transit_to_customer_drill_down_view;
CREATE materialized VIEW analytics.inventory_transit_to_customer_drill_down_view AS
SELECT nextval('analytics.inventory_transit_to_customer_drill_down_view_seq'::regclass) AS id, source AS location, material, material_description, SUM(COALESCE(in_bound_transit_qty,0)) AS quantity, cost, SUM(COALESCE(in_bound_transit_qty * cost,0)) AS material_cost,uom AS unit_of_measure, location AS customer_code, customer_desc AS customer_name, created_dtm AS iusse_date FROM analytics.div_transaction div,master.material mm, master.customer cust WHERE div.material=mm.material_name AND div.location=cust.customer_name AND in_bound_transit_qty !=0 AND location_type='CUSTOMER' GROUP BY source, material, material_description,cost, uom, div.location, customer_code, customer_desc, created_dtm;



--Inventory at Customer (No data)
DROP SEQUENCE IF EXISTS analytics.inventory_at_customer_drill_down_view_seq;
CREATE SEQUENCE analytics.inventory_at_customer_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.inventory_at_customer_drill_down_view;
CREATE materialized VIEW analytics.inventory_at_customer_drill_down_view AS
SELECT nextval('analytics.inventory_at_customer_drill_down_view_seq'::regclass) AS id, material, material_description, SUM(COALESCE(current_qty,0)) AS quantity,cost, SUM(COALESCE(current_qty * cost,0)) AS material_cost, uom AS unit_of_measure, location AS customer_code, customer_desc AS customer_name, source AS received_from,customer_po AS po_number,created_dtm AS received_date FROM analytics.div_transaction div,master.material mm, master.customer cust WHERE div.material=mm.material_name AND div.location=cust.customer_name AND current_qty !=0 AND location_type='CUSTOMER' GROUP BY material, material_description,cost,uom, location, customer_desc, source, customer_po,created_dtm;

-- Customer Consumption
DROP SEQUENCE IF EXISTS analytics.customer_consumed_inventory_drill_down_view_seq;
CREATE SEQUENCE analytics.customer_consumed_inventory_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumed_inventory_drill_down_view;
CREATE materialized VIEW analytics.customer_consumed_inventory_drill_down_view AS
SELECT nextval('analytics.customer_consumed_inventory_drill_down_view_seq'::regclass) AS id, material,  material_description, SUM(COALESCE(assetinstalled,0)) AS quantity,cost, SUM(COALESCE(assetinstalled * cost,0)) AS material_cost, uom AS unit_of_measure, customer AS customer_code, customer_desc AS customer_name, storage_location AS received_from, installation_date FROM analytics.analytics_installation install,master.material mm, master.customer cust WHERE install.material=mm.material_name AND install.customer=cust.customer_name AND assetinstalled !=0 GROUP BY material, material_description,cost,uom, customer, customer_desc, storage_location,installation_date;


--Customer Demand
DROP SEQUENCE IF EXISTS analytics.customer_demand_inventory_drill_down_view_seq;
CREATE SEQUENCE analytics.customer_demand_inventory_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_demand_inventory_drill_down_view;
CREATE MATERIALIZED VIEW analytics.customer_demand_inventory_drill_down_view AS
 SELECT customer_demand_shortage_view_new.id,
    customer_demand_shortage_view_new.customerid,
    customer_demand_shortage_view_new.customer_desc,
    customer_demand_shortage_view_new.fiscal_week,
    customer_demand_shortage_view_new.year,
    customer_demand_shortage_view_new.demand,
    customer_demand_shortage_view_new.shortage
   FROM analytics.customer_demand_shortage_view_new;


--Customer Demand Second Drill down
CREATE SEQUENCE analytics.customer_fsg_demand_shortage_view_final_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.customer_fsg_demand_shortage_view_final;
CREATE MATERIALIZED VIEW analytics.customer_fsg_demand_shortage_view_final AS
 Select nextval('analytics.customer_fsg_demand_shortage_view_final_seq'::regclass) AS id,
 customerid,material as materialid,matmaster.material_description,storage_location,demand,fiscal_week, year,shortage
 from analytics.ACTUAL_DEMAND_STOCK actual_stock_table
 LEFT JOIN
 master.material matmaster on  actual_stock_table.material=matmaster.material_name
 order by fiscal_week, year,material;

  

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_material_demand_drill_down_view;
CREATE MATERIALIZED VIEW analytics.customer_material_demand_drill_down_view AS
 SELECT customer_fsg_demand_shortage_view_final.id,
    customer_fsg_demand_shortage_view_final.customerid,
    customer_fsg_demand_shortage_view_final.materialid,
    customer_fsg_demand_shortage_view_final.material_description,
    customer_fsg_demand_shortage_view_final.storage_location,
    customer_fsg_demand_shortage_view_final.demand,
    customer_fsg_demand_shortage_view_final.fiscal_week,
    customer_fsg_demand_shortage_view_final.year,
    customer_fsg_demand_shortage_view_final.shortage
   FROM analytics.customer_fsg_demand_shortage_view_final;



--Dollar amount for Header
CREATE OR REPLACE FUNCTION analytics.total_inventory_dollar_value_summary(
 OUT total_quantity DECIMAL, 
 OUT transit_to_FSG DECIMAL, 
 OUT at_FSG DECIMAL, 
 OUT transit_to_customer DECIMAL, 
 OUT at_customer DECIMAL, 
 OUT total_consuption DECIMAL,
 OUT customer_demand DECIMAL
) AS $$
BEGIN
  -- total_quantity := COALESCE((SELECT SUM(quantity) FROM validstage.plant_sap_valid_stage),0);   
   --transit_to_FSG := COALESCE((SELECT SUM(material_cost) FROM (SELECT SUM(in_bound_transit_qty * cost) AS material_cost, material, SUM(in_bound_transit_qty) AS qty, cost FROM analytics.div_transaction div,master.material mm WHERE LOCATION_type='FSG' AND (source_type='FSG' OR source_type='GE') AND div.material=mm.material_name GROUP BY material,cost) AS div_transaction),0);
   transit_to_FSG := COALESCE((SELECT SUM(material_cost) FROM (SELECT material,SUM(quantity) AS qty, cost, SUM(quantity * cost) AS material_cost FROM validstage.plant_sap_valid_stage sap,master.material mm WHERE sap.material=mm.material_name AND (status IS null OR status ='T') GROUP BY material,cost) AS sap),0) + COALESCE((SELECT SUM(material_cost) FROM (SELECT material,SUM(in_bound_transit_qty) AS qty, cost, SUM(in_bound_transit_qty * cost) AS material_cost FROM analytics.div_transaction,master.material WHERE material=material_name AND location_type='FSG' AND source_type='FSG' GROUP BY material,cost) AS div),0);
   at_FSG := COALESCE((SELECT SUM(material_cost) FROM (SELECT SUM(current_qty * cost) AS material_cost,cost,sum(current_qty) AS qty, material FROM analytics.div_transaction div,master.material mm WHERE LOCATION_type='FSG' AND div.material=mm.material_name AND current_qty!=0 GROUP BY material,cost) AS div_transaction),0);
   transit_to_customer := COALESCE((SELECT SUM(material_cost) FROM (SELECT SUM(in_bound_transit_qty * cost) AS material_cost, material, SUM(in_bound_transit_qty) AS qty,cost FROM analytics.div_transaction div,master.material mm WHERE LOCATION_type='CUSTOMER' AND div.material=mm.material_name GROUP BY material,cost) AS div_transaction),0);
   at_customer := COALESCE((SELECT SUM(material_cost) FROM (SELECT SUM(current_qty * cost) AS material_cost, material, SUM(current_qty) AS qty,cost FROM analytics.div_transaction div,master.material mm WHERE LOCATION_type='CUSTOMER' AND div.material=mm.material_name GROUP BY material,cost) AS div_transaction),0);
   total_consuption := COALESCE((SELECT SUM(material_cost) FROM (SELECT SUM(assetinstalled * cost) AS material_cost, material, SUM(assetinstalled) AS qty,cost FROM analytics.analytics_installation install,master.material mm WHERE install.material=mm.material_name GROUP BY material,cost) AS analytics_installation ),0);
   --customer_demand := COALESCE((SELECT SUM(demand_qty * cost) AS cost_of_material FROM analytics.fsg_material_demand_detail demand, master.material mm WHERE demand.materialid=mm.material_name),0);
   total_quantity := COALESCE((SELECT SUM(material_cost) FROM (SELECT material,SUM(quantity) AS qty, cost, SUM(quantity * cost) AS material_cost FROM validstage.plant_sap_valid_stage sap,master.material mm WHERE sap.material=mm.material_name GROUP BY material,cost) AS sap),0);
   customer_demand := COALESCE((SELECT SUM(demand_cost) FROM (SELECT COALESCE(SUM(demand * cost),0) AS demand_cost FROM analytics.customer_fsg_demand_shortage_view_final, master.material WHERE materialid=material_name GROUP BY materialid) AS demand_cost),0);
END;
$$ LANGUAGE plpgsql;
 
-- Creates materialized view for aggregation details of Total inventory.
DROP MATERIALIZED VIEW IF EXISTS analytics.total_inventory_dollar_value_summary_view;
CREATE MATERIALIZED VIEW analytics.total_inventory_dollar_value_summary_view AS 
SELECT * FROM analytics.total_inventory_dollar_value_summary();

---- ********************* Total Inventory db script end  ***************************---------------
