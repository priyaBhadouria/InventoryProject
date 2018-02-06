

CREATE OR REPLACE FUNCTION analytics.callallmaterializedviewsondemand() RETURNS void AS $$ 
DECLARE
totalCount integer;
   
    begin
    
---Total Inventory & Customer Consumption Overview  
REFRESH MATERIALIZED VIEW analytics.customer_material_demand_detail;
REFRESH MATERIALIZED VIEW analytics.customer_fsg_material_demand_overview;

REFRESH MATERIALIZED VIEW analytics.fsg_customer_demand_master_view_ordered;
totalCount := (select analytics.save_FSG_actual_demand_stock());

REFRESH MATERIALIZED VIEW analytics.customer_fsg_demand_master_view; 
REFRESH MATERIALIZED VIEW analytics.customer_fsg_demand_master_view_ordered;
totalCount := (select analytics.save_actual_demand_stock());

REFRESH MATERIALIZED VIEW analytics.customer_fsg_demand_shortage_week_view;
REFRESH MATERIALIZED VIEW analytics.customer_demand_shortage_view_new; -- change in seq name
REFRESH MATERIALIZED VIEW analytics.customer_consumed_view; -- diff
REFRESH MATERIALIZED VIEW analytics.customer_consumption_drilldown_variance_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumption_overview_view;
REFRESH MATERIALIZED VIEW analytics.customer_fsg_demand_shortage_view_final;
REFRESH MATERIALIZED VIEW analytics.total_inventory_dollar_value_summary_view;
REFRESH MATERIALIZED VIEW analytics.ge_shipment_drill_down_view;
REFRESH MATERIALIZED VIEW analytics.inventory_transit_to_fsg_drill_down_view; -- diff
REFRESH MATERIALIZED VIEW analytics.inventory_at_fsg_drill_down_view;
REFRESH MATERIALIZED VIEW validstage.fsg_receipt_valid_stage_view;
REFRESH MATERIALIZED VIEW validstage.fsg_issued_valid_stage_view;

-- refresh view for com and bo
totalCount := (select staging.insertvalidfsgdailystockvalidstage()); 
totalCount := (select analytics.save_fsg_stock_net_inventory());
REFRESH MATERIALIZED VIEW analytics.FSG_DAILY_STOCK_NET_INVENTORY_VIEW;


--Installer Warehouse
REFRESH MATERIALIZED VIEW analytics.installer_received_details_view;
REFRESH MATERIALIZED VIEW analytics.total_inventory_summary_view;
--
--REFRESH MATERIALIZED VIEW analytics.inventory_received_stock_issued_view;
REFRESH MATERIALIZED VIEW analytics.inventory_transit_to_customer_drill_down_view;
REFRESH MATERIALIZED VIEW analytics.inventory_at_customer_drill_down_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumed_inventory_drill_down_view;
REFRESH MATERIALIZED VIEW analytics.customer_demand_inventory_drill_down_view;
REFRESH MATERIALIZED VIEW analytics.customer_material_demand_drill_down_view;

-- Inactive Stock
REFRESH MATERIALIZED VIEW validstage.inactive_stock_details_view; 
REFRESH MATERIALIZED VIEW validstage.inactive_stock_ratio_view;

-- Network Visibility
REFRESH MATERIALIZED VIEW analytics.plant_to_fsg_names_view;
REFRESH MATERIALIZED VIEW analytics.fsg_to_fsg_names_view;
REFRESH MATERIALIZED VIEW analytics.fsg_to_customer_names_view;
REFRESH MATERIALIZED VIEW validstage.plant_names_view;
REFRESH MATERIALIZED VIEW analytics.tree_data_table_plant_level_view; 
REFRESH MATERIALIZED VIEW analytics.intransit_to_customer_view;
REFRESH MATERIALIZED VIEW analytics.intransit_to_fsg_and_stock_at_fsg_view;
REFRESH MATERIALIZED VIEW analytics.inventory_drilldown_view; 
REFRESH MATERIALIZED VIEW analytics.tree_data_table_for_customer_level_view;  
REFRESH MATERIALIZED VIEW analytics.tree_data_aggrigate_for_customer_level_view;

--Inventory Transaction
REFRESH MATERIALIZED VIEW analytics.total_inventory_transaction_view;

--FSG Consumption
REFRESH MATERIALIZED VIEW analytics.fsg_inventory_summary_view;
REFRESH MATERIALIZED VIEW analytics.fsg_material_demand_inv_veiw;
REFRESH MATERIALIZED VIEW analytics.fsg_material_consumption_rate_veiw_detail;
REFRESH MATERIALIZED VIEW validstage.fsg_overview_dollar_value_summary_view;

--Customer Consumption
REFRESH MATERIALIZED VIEW analytics.customer_summary_view;


--FSG Consumption
REFRESH MATERIALIZED VIEW analytics.fsg_material_demand_detail_new;
REFRESH MATERIALIZED VIEW analytics.fsg_material_demand_overview_new;
REFRESH MATERIALIZED VIEW analytics.fsg_inventory_summary_view;
REFRESH MATERIALIZED VIEW analytics.fsg_material_consumption_rate_veiw_detail;
REFRESH MATERIALIZED VIEW analytics.fsg_consumption_rate_all_veiw;
REFRESH MATERIALIZED VIEW analytics.All_Location_consumption_rate_veiw;
REFRESH MATERIALIZED VIEW analytics.fsg_material_customer_demand_view;
REFRESH MATERIALIZED VIEW analytics.fsg_material_demand_inv_veiw;
REFRESH MATERIALIZED VIEW analytics.fsg_material_consumption_rate_veiw_detail;
REFRESH MATERIALIZED VIEW validstage.fsg_overview_dollar_value_summary_view;

--Customer Consumption and FSG Trend
REFRESH MATERIALIZED VIEW validstage.fsg_issued_trend_details_view;
REFRESH MATERIALIZED VIEW validstage.fsg_receipt_trend_details_view;
REFRESH MATERIALIZED VIEW validstage.fsg_issued_valid_stage_drilldown_view;
REFRESH MATERIALIZED VIEW validstage.fsg_issued_valid_stage_drilldown_loc_view;
REFRESH MATERIALIZED VIEW validstage.fsg_trend_valid_stage_fsg_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumption_trend_view;
REFRESH MATERIALIZED VIEW validstage.customer_return_trend_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumption_trend_drilldown_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumption_trend_loc_drilldown_view;
REFRESH MATERIALIZED VIEW analytics.customer_consumption_trend_popup_view;


    end;
    $$ LANGUAGE plpgsql;
	  
	

	
	



	  