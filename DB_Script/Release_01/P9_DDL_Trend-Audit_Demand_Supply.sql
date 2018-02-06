--CREATE SCHEMA audit;

DROP SEQUENCE IF EXISTS audit.intransit_to_fsg_history_table_id_seq;
CREATE SEQUENCE audit.intransit_to_fsg_history_table_id_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;


CREATE TABLE audit."intransit_to_fsg_history_table" (
   id   integer   NOT NULL   PRIMARY KEY,   
   material   character varying(255)   NOT NULL,
   material_description character varying(255)   NOT NULL,
   quantity   numeric(11,2),
   cost numeric(11,2),
   material_cost  numeric(11,2),
   unit_of_measure   character varying(255),
   to_location   character varying(255),
   from_location   character varying(255),
   pro_number   character varying(255),
   carrier_name   character varying(255),   
   created_dtm   date   NOT NULL
);

CREATE OR REPLACE FUNCTION audit."save_intransit_to_fsg_details_into_history_table"() RETURNS integer AS $$   
DECLARE
  intransit_to_fsg RECORD;
  temp_rec RECORD;
  inventory_date date := (select current_date-1);
BEGIN
  FOR intransit_to_fsg IN Select material, material_description, quantity, cost, material_cost, unit_of_measure, to_location, from_location, pro_number, carrier_name from analytics.inventory_transit_to_fsg_drill_down_view LOOP  
    BEGIN  
  
    Select material, material_description, quantity, cost, material_cost, unit_of_measure, to_location, from_location, pro_number, carrier_name into temp_rec from audit.intransit_to_fsg_history_table  
        where material=intransit_to_fsg.material 
        and material_description=intransit_to_fsg.material_description
        and quantity=intransit_to_fsg.quantity        
        and material_cost=intransit_to_fsg.material_cost		
		and to_location=intransit_to_fsg.to_location
		and from_location=intransit_to_fsg.from_location
		and pro_number=intransit_to_fsg.pro_number
		and carrier_name=intransit_to_fsg.carrier_name
		and created_dtm=inventory_date;
         
       IF temp_rec is null THEN
      INSERT INTO audit.intransit_to_fsg_history_table(id,material, material_description, quantity, cost, material_cost, unit_of_measure, to_location, from_location, pro_number, carrier_name,created_dtm) VALUES(nextval('audit.intransit_to_fsg_history_table_id_seq'),intransit_to_fsg.material,intransit_to_fsg.material_description,intransit_to_fsg.quantity,intransit_to_fsg.cost,intransit_to_fsg.material_cost,intransit_to_fsg.unit_of_measure,intransit_to_fsg.to_location,intransit_to_fsg.from_location,intransit_to_fsg.pro_number,intransit_to_fsg.carrier_name,inventory_date);
     END IF;
      exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
      raise notice '% %', SQLERRM, SQLSTATE;
      return 0;    
      END;
  END LOOP;
  return 1; 
END;
$$ LANGUAGE plpgsql;


DROP SEQUENCE IF EXISTS audit.stock_at_fsg_history_table_id_seq;
CREATE SEQUENCE audit.stock_at_fsg_history_table_id_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;


CREATE TABLE audit."stock_at_fsg_history_table" (
   id   integer   NOT NULL   PRIMARY KEY,   
   material   character varying(255)   NOT NULL,
   material_description character varying(255)   NOT NULL,
   quantity   numeric(11,2),
   cost numeric(11,2),
   material_cost  numeric(11,2),
   unit_of_measure   character varying(255),
   location   character varying(255),
   created_dtm   date   NOT NULL
);


CREATE OR REPLACE FUNCTION audit."save_stock_at_fsg_details_into_history_table"() RETURNS integer AS $$   
DECLARE
  stock_at_fsg RECORD;
  temp_rec RECORD;
  inventory_date date := (select current_date-1);
BEGIN
  FOR stock_at_fsg IN Select material, material_description, quantity, cost, material_cost, unit_of_measure, location from analytics.inventory_at_fsg_drill_down_view LOOP  
    BEGIN  
  
    Select material, material_description, quantity, cost, material_cost, unit_of_measure, location into temp_rec from audit.stock_at_fsg_history_table  
        where material=stock_at_fsg.material 
        and material_description=stock_at_fsg.material_description
        and quantity=stock_at_fsg.quantity        
        and material_cost=stock_at_fsg.material_cost     
        and location=stock_at_fsg.location    
        and created_dtm=inventory_date;
         
       IF temp_rec is null THEN
      INSERT INTO audit.stock_at_fsg_history_table(id,material, material_description, quantity, cost, material_cost, unit_of_measure, location, created_dtm) VALUES(nextval('audit.stock_at_fsg_history_table_id_seq'),stock_at_fsg.material,stock_at_fsg.material_description,stock_at_fsg.quantity,stock_at_fsg.cost,stock_at_fsg.material_cost, stock_at_fsg.unit_of_measure, stock_at_fsg.location, inventory_date);
     END IF;
      exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
      raise notice '% %', SQLERRM, SQLSTATE;
      return 0;    
      END;
  END LOOP;
  return 1; 
END;
$$ LANGUAGE plpgsql;

DROP SEQUENCE IF EXISTS audit.customer_demand_shortage_history_table_id_seq;
CREATE SEQUENCE audit.customer_demand_shortage_history_table_id_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;


CREATE TABLE audit."customer_demand_shortage_history_table" (
   id   integer   NOT NULL   PRIMARY KEY,
   customer_id   character varying(255)   NOT NULL,
   material_id   character varying(255)   NOT NULL,
   material_description character varying(255)   NOT NULL,
   storage_location   character varying(255),
   demand   numeric(11,2),
   shortage   numeric(11,2),
   fiscal_week INTEGER,
   year  INTEGER,   
   backup_date   date   NOT NULL
);

CREATE OR REPLACE FUNCTION audit."backup_customer_demand_shortage_details_into_history_table"() RETURNS integer AS $$   
DECLARE
  demand_shortage_rec RECORD;
  temp_rec RECORD;
  inventory_date date := (select current_date-1);
BEGIN
  FOR demand_shortage_rec IN Select * from analytics.customer_fsg_demand_shortage_view_final LOOP  
    BEGIN  
  
    Select customer_id, material_id, material_description, storage_location, demand, shortage, fiscal_week, year into temp_rec from audit.customer_demand_shortage_history_table  
        where customer_id=demand_shortage_rec.customerid 
		and material_id=demand_shortage_rec.materialid
        and material_description=demand_shortage_rec.material_description
        and storage_location=demand_shortage_rec.storage_location        
        and demand=demand_shortage_rec.demand     
        and shortage=demand_shortage_rec.shortage  
		and fiscal_week=demand_shortage_rec.fiscal_week     
        and year=demand_shortage_rec.year  		
        and backup_date=inventory_date;
         
       IF temp_rec is null THEN
      INSERT INTO audit.customer_demand_shortage_history_table(id,customer_id, material_id, material_description, storage_location, demand, shortage, fiscal_week, year, backup_date) VALUES(nextval('audit.customer_demand_shortage_history_table_id_seq'),demand_shortage_rec.customerid,demand_shortage_rec.materialid,demand_shortage_rec.material_description,demand_shortage_rec.storage_location,demand_shortage_rec.demand,demand_shortage_rec.shortage, demand_shortage_rec.fiscal_week, demand_shortage_rec.year, inventory_date);
     END IF;
      exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
      raise notice '% %', SQLERRM, SQLSTATE;
      return 0;    
      END;
  END LOOP;
  return 1; 
END;
$$ LANGUAGE plpgsql;

DROP MATERIALIZED VIEW IF EXISTS audit.stock_at_fsg_history_table_view;
CREATE materialized VIEW audit.stock_at_fsg_history_table_view AS
SELECT * FROM audit.stock_at_fsg_history_table;

DROP MATERIALIZED VIEW IF EXISTS audit.intransit_to_fsg_history_table_view;
CREATE materialized VIEW audit.intransit_to_fsg_history_table_view AS
SELECT * FROM audit.intransit_to_fsg_history_table;

DROP MATERIALIZED VIEW IF EXISTS audit.customer_demand_shortage_history_table_view;
CREATE materialized VIEW audit.customer_demand_shortage_history_table_view AS
SELECT * FROM audit.customer_demand_shortage_history_table;



DROP SEQUENCE IF EXISTS audit.demand_supply_inventory_graph_view_seq;
CREATE SEQUENCE audit.demand_supply_inventory_graph_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_inventory_graph_view;
CREATE materialized VIEW audit.demand_supply_inventory_graph_view AS
SELECT nextval('audit.demand_supply_inventory_graph_view_seq'::regclass) AS id, SUM(COALESCE(quantity,0)) AS stock_quantity, created_dtm AS backup_date FROM audit.stock_at_fsg_history_table_view GROUP BY created_dtm ORDER BY created_dtm;

DROP SEQUENCE IF EXISTS audit.demand_supply_in_transit_graph_view_seq;
CREATE SEQUENCE audit.demand_supply_in_transit_graph_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_in_transit_graph_view;
CREATE materialized VIEW audit.demand_supply_in_transit_graph_view AS
SELECT nextval('audit.demand_supply_in_transit_graph_view_seq'::regclass) AS id, SUM(COALESCE(quantity,0)) AS intransit_quantity, created_dtm AS backup_date FROM audit.intransit_to_fsg_history_table_view GROUP BY created_dtm ORDER BY created_dtm;

DROP SEQUENCE IF EXISTS audit.demand_supply_demand_graph_view_seq;
CREATE SEQUENCE audit.demand_supply_demand_graph_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_demand_graph_view;
CREATE materialized VIEW audit.demand_supply_demand_graph_view AS
SELECT nextval('audit.demand_supply_demand_graph_view_seq'::regclass) AS id, SUM(COALESCE(demand,0)) AS demand_quantity, backup_date FROM audit.customer_demand_shortage_history_table_view GROUP BY backup_date ORDER BY backup_date;

DROP SEQUENCE IF EXISTS audit.demand_supply_shortage_graph_view_seq;
CREATE SEQUENCE audit.demand_supply_shortage_graph_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_shortage_graph_view;
CREATE materialized VIEW audit.demand_supply_shortage_graph_view AS
SELECT nextval('audit.demand_supply_shortage_graph_view_seq'::regclass) AS id, SUM(COALESCE(shortage,0)) AS shortage_quantity, backup_date FROM audit.customer_demand_shortage_history_table_view GROUP BY backup_date ORDER BY backup_date;

DROP SEQUENCE IF EXISTS audit.demand_supply_inventory_drill_down_view_seq;
CREATE SEQUENCE audit.demand_supply_inventory_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_inventory_drill_down_view;
CREATE materialized VIEW audit.demand_supply_inventory_drill_down_view AS
SELECT nextval('audit.demand_supply_inventory_drill_down_view_seq'::regclass) AS id, material, material_description, SUM(quantity) AS quantity, created_dtm FROM audit.stock_at_fsg_history_table_view GROUP BY material,material_description,created_dtm ORDER BY created_dtm;

DROP SEQUENCE IF EXISTS audit.demand_supply_intransit_drill_down_view_seq;
CREATE SEQUENCE audit.demand_supply_intransit_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_intransit_drill_down_view;
CREATE materialized VIEW audit.demand_supply_intransit_drill_down_view AS
SELECT nextval('audit.demand_supply_intransit_drill_down_view_seq'::regclass) AS id, material, material_description, sum(quantity) AS quantity, created_dtm from audit.intransit_to_fsg_history_table_view group by material,material_description,created_dtm order by created_dtm;


DROP SEQUENCE IF EXISTS audit.demand_supply_demand_shortage_drill_down_view_seq;
CREATE SEQUENCE audit.demand_supply_demand_shortage_drill_down_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS audit.demand_supply_demand_shortage_drill_down_view;
CREATE materialized VIEW audit.demand_supply_demand_shortage_drill_down_view AS
SELECT nextval('audit.demand_supply_demand_shortage_drill_down_view_seq'::regclass) AS id, material_id, material_description, SUM(demand) AS demand, SUM(shortage) AS shortage , backup_date FROM audit.customer_demand_shortage_history_table_view GROUP BY material_id, material_description, backup_date ORDER BY backup_date;


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
	