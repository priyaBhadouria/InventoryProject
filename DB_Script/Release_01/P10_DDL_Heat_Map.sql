CREATE OR REPLACE FUNCTION analytics.heatmaplandingpageview() RETURNS void AS $$  
BEGIN
REFRESH MATERIALIZED VIEW analytics.heatmap_landing_page_details_view;
 END;
    $$ LANGUAGE plpgsql;
	
	
CREATE  OR REPLACE FUNCTION analytics.heatmapfsgaddressdetailsview() RETURNS void AS $$  
BEGIN
REFRESH MATERIALIZED VIEW analytics.heatmap_fsg_address_details_view;
REFRESH MATERIALIZED VIEW  analytics.heatmap_fsg_to_fsg_connection_details_view;
REFRESH MATERIALIZED VIEW analytics.heatmap_fsg_customer_connection_details_view;
 END;
    $$ LANGUAGE plpgsql;
	
	


CREATE materialized VIEW audit.heatmap_fsg_address_details_view AS
 SELECT t1.location,
    t2.address_id,
    t3.street,
    t3.city,
    t3.state,
    t3.zipcode,
    t3.country,
    t3.lat,
    t3.long
   FROM ( SELECT DISTINCT t.location
           FROM ( SELECT DISTINCT inventory_transit_to_customer_drill_down_view.location
                   FROM analytics.inventory_transit_to_customer_drill_down_view
                UNION ALL
                 SELECT DISTINCT inventory_transit_to_fsg_drill_down_view.from_location
                   FROM analytics.inventory_transit_to_fsg_drill_down_view
                UNION ALL
                 SELECT DISTINCT inventory_transit_to_fsg_drill_down_view.to_location
                   FROM analytics.inventory_transit_to_fsg_drill_down_view) t) t1,
    master.fsg t2,
    master.address t3
  WHERE t1.location::text = t2.fsg_party_name::text AND t2.address_id = t3.address_id;
  
  
 CREATE materialized VIEW audit.heatmap_landing_page_details_view AS 
   SELECT t1.customer_code,
    t1.quantity,
    t3.lat,
    t3.long,
    t2.address_id
   FROM ( SELECT inventory_transit_to_customer_drill_down_view.customer_code,
            COALESCE(sum(inventory_transit_to_customer_drill_down_view.quantity), 0::numeric) AS quantity
           FROM analytics.inventory_transit_to_customer_drill_down_view
          GROUP BY inventory_transit_to_customer_drill_down_view.customer_code) t1,
    master.customer t2,
    master.address t3
  WHERE t1.customer_code::text = t2.customer_name::text AND t2.address_id = t3.address_id;
	