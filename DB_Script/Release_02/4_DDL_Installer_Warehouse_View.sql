  ---- ********************* Total Inventory db script start  ***************************---------------
CREATE OR REPLACE FUNCTION analytics.total_inventory_summary(
 OUT total_quantity DECIMAL, 
 OUT transit_to_FSG DECIMAL, 
 OUT at_FSG DECIMAL, 
 OUT transit_to_customer DECIMAL, 
 OUT at_customer DECIMAL, 
 OUT total_consuption DECIMAL,
 OUT total_customer_demand DECIMAL,
 OUT total_installer_recieved DECIMAL
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
   total_installer_recieved=COALESCE((SELECT SUM(quantity) FROM analytics.installer_received_details_view),0);
END;
$$ LANGUAGE plpgsql;
 
-- Creates materialized view for aggregation details of Total inventory.
DROP MATERIALIZED VIEW IF EXISTS analytics.total_inventory_summary_view;
CREATE MATERIALIZED VIEW analytics.total_inventory_summary_view AS 
SELECT * FROM analytics.total_inventory_summary();
