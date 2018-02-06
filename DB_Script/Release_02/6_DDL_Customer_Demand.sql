CREATE SEQUENCE analytics."customer_material_demand_summary_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;


CREATE MATERIALIZED VIEW analytics.customer_material_demand_summary AS
Select nextval('analytics.customer_material_demand_summary_seq'::regclass) AS id,
materialid as material,material_description,sum(demand) as total_demand,sum(shortage) as total_shortage,fiscal_week,year,storage_location as serving_location from analytics.customer_material_demand_drill_down_view group by material,material_description,fiscal_week,year,serving_location;