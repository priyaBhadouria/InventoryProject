CREATE SCHEMA master;
CREATE SCHEMA staging;
CREATE SCHEMA validstage;
CREATE SCHEMA analytics;
CREATE SCHEMA audit;

-- master schema
--sequence
CREATE SEQUENCE master."address_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 9110
   CACHE 1
   NO CYCLE;
--2
CREATE SEQUENCE master."customer_key_id_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 6116
   CACHE 1
   NO CYCLE;
--3
CREATE SEQUENCE master."email_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
--4
CREATE SEQUENCE master."file_format_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 2
   CACHE 1
   NO CYCLE;
--5
CREATE SEQUENCE master."fsg_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 52
   CACHE 1
   NO CYCLE;
--6
CREATE SEQUENCE master."ge_storage_location_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
--7
CREATE SEQUENCE master."loc_type_id_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 3
   CACHE 1
   NO CYCLE;
--8
CREATE SEQUENCE master."loc_type_mapping_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 6194
   CACHE 1
   NO CYCLE;
   --9
   CREATE SEQUENCE master."material_key_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1828
   CACHE 1
   NO CYCLE;
--10
CREATE SEQUENCE master."plant_id_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 32
   CACHE 1
   NO CYCLE;
--11
CREATE SEQUENCE master."site_key_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
--12
CREATE SEQUENCE master."status_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 6
   CACHE 1
   NO CYCLE;
   --13
   CREATE SEQUENCE master."transaction_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 2
   CACHE 1
   NO CYCLE;
--14
  CREATE SEQUENCE master."unitofmeasure_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 21
   CACHE 1
   NO CYCLE;
--15
   CREATE SEQUENCE master."prop_id_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 21
   CACHE 1
   NO CYCLE;

CREATE SEQUENCE master."security_key_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
   --tables
   
 --1
 CREATE TABLE master.address (
   address_id   integer   DEFAULT NEXTVAL ('master.address_id_seq') NOT NULL   PRIMARY KEY,
   street   character varying(255),
   city   character varying(255),
   state   character varying(255),
   zipcode   character varying(255),
   country   character varying(255),
   lat   integer,
   long   integer,
   creation_date   timestamp without time zone
);
--2
CREATE TABLE master.customer (
   customer_key_id   integer  DEFAULT NEXTVAL ('master.customer_key_id_seq')   NOT NULL   PRIMARY KEY,
   customer_name   character varying(255)   NOT NULL   UNIQUE,
   address_id   integer   REFERENCES master.address(address_id),
   creation_date   timestamp without time zone,
   customer_desc   character varying(255)
);
 ALTER TABLE master.customer ADD COLUMN CUSTOMER_CODE character varying (255);
--3
CREATE TABLE master."div_app_prop" (
	properties_id_seq  integer  DEFAULT NEXTVAL ('master.prop_id_seq')   NOT NULL,
   property_name   character varying(50)   NOT NULL   PRIMARY KEY,
   property_value   character varying(50)
);
--4

CREATE TABLE master."file_format" (
   file_format_id   integer  DEFAULT NEXTVAL ('master.file_format_id_seq')  NOT NULL   PRIMARY KEY,
   format_name   character varying(255) NOT NULL   UNIQUE,
   creation_date   timestamp without time zone
);


--5
CREATE TABLE master.email (

	email_id_seq  integer  DEFAULT NEXTVAL ('master.email_id_seq')   NOT NULL,
   email_id   character varying(255)   NOT NULL   PRIMARY KEY,
   system   character varying(255),
   file_format   integer   REFERENCES master.file_format(file_format_id),
   creation_date   timestamp without time zone
);
--6
CREATE TABLE master.fsg (
   fsg_party_id   integer DEFAULT NEXTVAL ('master.fsg_id_seq')  NOT NULL   PRIMARY KEY,
   fsg_party_name   character varying(255)   NOT NULL   UNIQUE,
   is_hub   character varying(1),
   address_id   integer   REFERENCES master.address(address_id),
   creation_date   timestamp without time zone
);
alter table master.fsg add column fsg_desc character varying(255);
--7
CREATE TABLE master."loc_type" (
   loc_type_id   integer  DEFAULT NEXTVAL ('master.loc_type_id_seq')  NOT NULL   PRIMARY KEY,
   loc_type   character varying(255)   NOT NULL   UNIQUE,
   creation_date   timestamp without time zone
);


--8
CREATE TABLE master."ge_storage_location" (
   ge_storage_location_id   integer DEFAULT NEXTVAL ('master.ge_storage_location_id_seq')  NOT NULL   PRIMARY KEY,
   ge_storage_location_name   character varying(255)   NOT NULL   UNIQUE,
   ge_storage_location   character varying(255)   REFERENCES master.loc_type(loc_type),
   address_id   integer   REFERENCES master.address(address_id),
   ge_storage_location_desc   character varying(500),
   creation_date   timestamp without time zone
);
--9
CREATE TABLE master."loc_type_mapping" (
   loc_type_id   integer  DEFAULT NEXTVAL ('master.loc_type_mapping_id_seq') NOT NULL   PRIMARY KEY,
   loc_type_name   character varying(255)   NOT NULL   UNIQUE,
   loc_type   character varying(255)   NOT NULL   REFERENCES master.loc_type(loc_type),
   creation_date   timestamp without time zone
);
--10
CREATE TABLE master."unit_of_measure" (
   unit_of_measure_id   integer DEFAULT NEXTVAL ('master.unitofmeasure_seq')   NOT NULL   PRIMARY KEY,
   name   character varying(255)   NOT NULL   UNIQUE,
   description   character varying(255),
   creation_date   timestamp without time zone
);

--11
CREATE TABLE master.plant (
   plant_id   integer DEFAULT NEXTVAL ('master.plant_id_seq') NOT NULL   PRIMARY KEY,
   plant_name   character varying(255)   NOT NULL   UNIQUE,
   plant_description   character varying(255),
   address_id   integer   REFERENCES master.address(address_id),
   creation_date   timestamp without time zone
);
--12
CREATE TABLE master.site (
   site_key   integer DEFAULT NEXTVAL ('master.site_key_seq')  NOT NULL   PRIMARY KEY,
   site_id   integer   NOT NULL   UNIQUE,
   site_name   character varying(255)   NOT NULL,
   customer_name   character varying(255)   REFERENCES master.customer(customer_name),
   address_id   integer   REFERENCES master.address(address_id),
   creation_date   timestamp without time zone
);
--13
CREATE TABLE master.status (
   status_id   integer DEFAULT NEXTVAL ('master.status_seq')  NOT NULL   PRIMARY KEY,
   status_name   character varying(255)   NOT NULL   UNIQUE,
   status_desc   character varying(255),
   creation_date   timestamp without time zone
);
--14
CREATE TABLE master."transaction_type" (
   transaction_id   integer   DEFAULT NEXTVAL ('master.transaction_seq')  NOT NULL   PRIMARY KEY,
   transaction_type_name   character varying(255)   NOT NULL   UNIQUE,
   transaction_type_desc   character varying(255),
   creation_date   timestamp without time zone
);
--15
CREATE TABLE master.material (
   material_key   integer  DEFAULT NEXTVAL ('master.material_key_seq') NOT NULL   PRIMARY KEY,
   material_id   integer   UNIQUE,
   material_description   character varying(255)   NOT NULL,
   creation_date   timestamp without time zone,
   material_name   character varying(255)   NOT NULL   UNIQUE,
   cost   numeric(11,2),
   uom   character varying(255)   REFERENCES master.unit_of_measure(name),
   purchase_doc   character varying(100)
);



CREATE TABLE master."div_security" (
   sequerity_key   integer DEFAULT NEXTVAL ('master.security_key_seq')  NOT NULL   PRIMARY KEY,
   sso   character varying(255),
   group_name   character varying(255)   CHECK (group_name::text = ANY (ARRAY['ADMIN'::character varying, 'BASIC'::character varying]::text[])),
   sso_desc   character varying(255)
);

--Staging schema

--- SEQUENCE
--1
CREATE SEQUENCE staging."core_shipment_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 66037
   CACHE 1
   NO CYCLE;
--2
CREATE SEQUENCE staging."customer_install_demand_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 66037
   CACHE 1
   NO CYCLE;
   
--3
   CREATE SEQUENCE staging."fsg_demand_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 66037
   CACHE 1
   NO CYCLE;
--4
    CREATE SEQUENCE staging."fsg_issued_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 66037
   CACHE 1
   NO CYCLE;
--5
    CREATE SEQUENCE staging."fsg_receipt_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 66037
   CACHE 1
   NO CYCLE;
--6
CREATE SEQUENCE staging."stage_seq_key_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1575039
   CACHE 1
   NO CYCLE;
--7
CREATE SEQUENCE staging."xls_master_id_seq"
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 10
   CACHE 1
   NO CYCLE;
--8
CREATE SEQUENCE staging."xls_upload_id_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 312
   CACHE 1
   NO CYCLE;
 --9
   CREATE SEQUENCE staging."core_purchase_order_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
--10

   CREATE SEQUENCE staging."fsg_daily_stock_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
---Tables

--1
CREATE TABLE staging."core_shipment_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('staging.core_shipment_stage_seq') NOT NULL   PRIMARY KEY,
   storage_location   character varying(100),
   order_num   integer,
   customer_po   character varying(100),
   order_entry_date   date,
   order_sum_del_req_date   date,
   material   text,
   material_description   character varying(500),
   order_item_qty_unexp   numeric(11,2),
   order_item_ship_qty_unexp   numeric(11,2),
   ship_line_status_code   character varying(255),
   pick_tick_num   character varying(255),
   plant   character varying(100),
   bol   character varying(255),
   carrier_scac_code   character varying(255),
   bol_pro_number   character varying(255),
   ship_line_ship_date   date,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);

--2
CREATE TABLE staging."customer_install_demand_stage" (
   cust_proj_def_id   integer  DEFAULT NEXTVAL ('staging.customer_install_demand_stage_seq')  NOT NULL   PRIMARY KEY,
   customer   character varying(255),
   fm_company   character varying(255),
   install_date   timestamp without time zone   NOT NULL,
   est_install_start   timestamp without time zone,
   est_install_complete   timestamp without time zone,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   fsg_order_num   character varying(255),
   project_definition   character varying(255),
   street   character varying(255),
   city   character varying(255),
   state_region   character varying(255),
   zipcode   character varying(255),
   customer_name   character varying(255)
);
 ALTER TABLE staging.customer_install_demand_stage ADD COLUMN CUSTOMER_CODE character varying (255);
--4
CREATE TABLE staging."fsg_demand_stage" (
   stage_seq_key   integer DEFAULT NEXTVAL ('staging.fsg_demand_stage_seq')  NOT NULL   PRIMARY KEY,
   material   text,
   material_description   character varying(500),
   quantity   numeric(11,2),
   plant   character varying(100),
   storage_location   character varying(100),
   project_definition   character varying(255),
   requirement_date   date,
   wbs_element   character varying(255),
   network   character varying(255),
   activity   character varying(255),
   unit_of_measure   character varying(255),
   reservation_purc_req   character varying(255),
   purchase_requisition   character varying(255),
   requisition_item   integer,
   purchase_ord_exists   character varying(255),
   deletion_indicator   character varying(255),
   reservation   character varying(255),
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);

--5
CREATE TABLE staging."fsg_issued_stage" (
   stage_seq_key   integer DEFAULT NEXTVAL ('staging.fsg_issued_stage_seq')  NOT NULL   PRIMARY KEY,
   sto   integer,
   material   character varying(255)   NOT NULL,
   material_description   character varying(255)   NOT NULL,
   quantity_shipped   numeric(11,2)   NOT NULL,
   ge_fsg_tracking_number   character varying(255),
   ship_to_customer   character varying(255),
   issued_date   timestamp without time zone   NOT NULL,
   customer_purchase_order_number   character varying(255),
   issue_to_type   character varying(255)   NOT NULL,
   issued_from   character varying(255)   NOT NULL,
   issued_from_address   character varying(255)   NOT NULL,
   issued_from_city   character varying(255)   NOT NULL,
   issued_from_state   character varying(255)   NOT NULL,
   issued_from_zipcode   character varying(255)   NOT NULL,
   issued_from_country   character varying(255)   NOT NULL,
   received_to   character varying(255)   NOT NULL,
   received_to_address   character varying(255)   NOT NULL,
   received_to_city   character varying(255)   NOT NULL,
   received_to_state   character varying(255)   NOT NULL,
   received_to_zipcode   character varying(255)   NOT NULL,
   received_to_country   character varying(255)   NOT NULL,
   file_current_date   timestamp without time zone   NOT NULL,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);

--6
CREATE TABLE staging."fsg_receipt_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('staging.fsg_receipt_stage_seq')  NOT NULL   PRIMARY KEY,
   sto   integer,
   material   character varying(255)   NOT NULL,
   material_description   character varying(255)   NOT NULL,
   plant   character varying(100),
   planned_quantity   numeric(11,2)   NOT NULL,
   actual_quantity   numeric(11,2)   NOT NULL,
   ge_fsg_tracking_number   character varying(255),
   receipt_date   timestamp without time zone   NOT NULL,
   customer_purchase_order_number   character varying(255),
   fsg_po   character varying(255),
   receive_from_type   character varying(255)   NOT NULL,
   issued_from   character varying(255)   NOT NULL,
   issued_from_address   character varying(255)   NOT NULL,
   issued_from_city   character varying(255)   NOT NULL,
   issued_from_state   character varying(255)   NOT NULL,
   issued_from_zipcode   character varying(255)   NOT NULL,
   issued_from_country   character varying(255)   NOT NULL,
   received_to   character varying(255)   NOT NULL,
   received_to_address   character varying(255)   NOT NULL,
   received_to_city   character varying(255)   NOT NULL,
   received_to_state   character varying(255)   NOT NULL,
   received_to_zipcode   character varying(255)   NOT NULL,
   received_to_country   character varying(255)   NOT NULL,
   file_current_date   timestamp without time zone   NOT NULL,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);



--7

CREATE TABLE staging.logger (
   upload_or_run_id   integer NOT NULL,
   log   text,
   create_dtm   timestamp without time zone   NOT NULL
);

--8
CREATE TABLE staging."plant_sap_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('staging.stage_seq_key_seq')  NOT NULL   PRIMARY KEY,
   sto   numeric   NOT NULL,
   sto_item   integer   NOT NULL,
   material   character varying(255)   NOT NULL,
   material_description   character varying(500)   NOT NULL,
   plant   character varying(100)   NOT NULL,
   storage_location   character varying(100)   NOT NULL,
   wbs_element   character varying(255),
   wbs_description   character varying(255),
   quantity   numeric(11,2)   NOT NULL,
   unit_of_measure   character varying(255)   NOT NULL,
   delivery_due_date   timestamp without time zone,
   good_issue_date   timestamp without time zone,
   pro_number   character varying(255),
   delivery_number   integer   NOT NULL,
   delivery_item_number   integer,
   customer_name   character varying(255),
   customer_po   character varying(100),
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   rec_plant   character varying(255),
   shipment_num   integer,
   shipment_crd   date,
   shipment_to_country   character varying(255),
   shipment_to_name   character varying(255),
   shipment_to_street   character varying(255),
   shipment_to_zipcode   character varying(255),
   shipment_to_city   character varying(255),
   carrier_name   character varying(255),
   delivery_cr_date   date
);


CREATE TABLE staging."fsg_daily_stock_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('staging.fsg_daily_stock_seq')  NOT NULL   PRIMARY KEY,
   material   character varying(255)   NOT NULL,
   material_description   character varying(255) ,
   fsca_com   numeric,
   fsca_bo   numeric,
   fstx_com   numeric,
   fstx_bo   numeric,
   fsil_com   numeric,
   fsil_bo   numeric,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);


--10
CREATE TABLE staging."xls_master" (
   xls_id   integer  DEFAULT NEXTVAL ('staging.xls_master_id_seq') NOT NULL   PRIMARY KEY,
   xls_name   character varying(1000)   NOT NULL,
   xls_desc   character varying(1000)   NOT NULL,
   download_name   character varying(1000)   NOT NULL,
   total_columns   integer   NOT NULL,
   db_table_name   character varying(1000)   NOT NULL   UNIQUE,
   active   character(1)   NOT NULL,
   create_dtm   timestamp without time zone   NOT NULL,
   update_dtm   timestamp without time zone   NOT NULL,
   created_by   character varying(1000)   NOT NULL,
   updated_by   character varying(1000)   NOT NULL,
   schema_name   character(100)   NOT NULL
);


--11
CREATE TABLE staging."xls_col_ref" (
   xls_id   integer   NOT NULL   REFERENCES staging.xls_master(xls_id),
   xls_column_index   integer   NOT NULL,
   data_type_postgres   character varying(100)   NOT NULL,
   input_header_text   character varying(1000)   NOT NULL,
   db_column_name   character varying(1000)   NOT NULL,
   create_dtm   timestamp without time zone   NOT NULL,
   update_dtm   timestamp without time zone   NOT NULL,
   created_by   character varying(1000)   NOT NULL,
   updated_by   character varying(1000)   NOT NULL
);
--12
CREATE TABLE staging."xls_upload" (
   upload_id   integer  DEFAULT NEXTVAL ('staging.xls_upload_id_seq') NOT NULL   PRIMARY KEY,
   xls_id   integer   NOT NULL   REFERENCES staging.xls_master(xls_id),
   file_name   character varying(1000)   NOT NULL,
   csv_blob_store_location   character varying(1000)   NOT NULL,
   row_passed   integer,
   row_failed   integer,
   total_rows   integer,
   user_comment   text,
   db_processed   character(1),
   create_dtm   timestamp without time zone   NOT NULL,
   update_dtm   timestamp without time zone   NOT NULL,
   created_by   character varying(1000)   NOT NULL,
   updated_by   character varying(1000)   NOT NULL
);

--13
 CREATE TABLE  staging.SAP_PURCHASING_ORDER_STAGE(STAGE_SEQ_KEY INTEGER DEFAULT NEXTVAL ('staging.core_purchase_order_seq') PRIMARY KEY,
	PURCHASING_DOCUMENT  character varying (100),ITEM integer,VENDOR character varying (100), MATERIAL_GROUP character varying (100), MATERIAL character varying (100),
	PURCH_ORGANIZATION  character varying (100),PURCH_GROUP  character varying (100),PLANT  character varying (100),STORAGE_LOCATION character varying (100),DOCUMENT_DATE DATE,
	ORDER_QTY decimal(11,2),ORDER_UNIT character varying (100),NET_ORDER_VALUE decimal(11,2),CURRENCY character varying (100),ORDER_PRICE_UNIT character varying (100),
	INCOMPLETE character varying (100),PURCHASING_DOC_TYPE character varying (100),SUPPLYING_PLANT character varying (100),MATERIAL_DESCRIPTION  character varying (100),
	IS_PROCESSED character varying (1),FILE_SEQ_NUMBER INTEGER, creation_date   timestamp without time zone);
	
	
CREATE TABLE staging."sap_upload"(
   id   integer   DEFAULT NEXTVAL ('staging.xls_upload_id_seq')   NOT NULL   PRIMARY KEY,
   records_passed   integer,
   records_failed   integer,
   total_records   integer,
   is_processed   character varying(1),
   create_dtm   timestamp without time zone   NOT NULL,
   service_name   character varying(1000)   NOT NULL
);
--- Views
--1 fsg_demand_drill_down_view


--Validstage schema

--sequence
--1
CREATE SEQUENCE validstage."asset_installed_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 15546
   CACHE 1
   NO CYCLE;
   --2
   CREATE SEQUENCE validstage."auto_sto_number" 
   INCREMENT 1
   MINVALUE 1000
   MAXVALUE 9223372036854775807
   START 1357
   CACHE 1
   NO CYCLE;
--3
CREATE SEQUENCE validstage."customer_install_demand_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 43589
   CACHE 1
   NO CYCLE;
--4
CREATE SEQUENCE validstage."fsg_issued_valid_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 15876
   CACHE 1
   NO CYCLE;
--5
CREATE SEQUENCE validstage."fsg_receipt_valid_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 11545
   CACHE 1
   NO CYCLE;
--6

CREATE SEQUENCE validstage."inventory_sp_demand_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1814256
   CACHE 1
   NO CYCLE;
--7
CREATE SEQUENCE validstage."plant_sap_valid_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 64674
   CACHE 1
   NO CYCLE;

CREATE SEQUENCE validstage.CUSTOMER_PROJECT_DEFINITION_SEQ 
INCREMENT 1   
MINVALUE 1   
MAXVALUE 9223372036854775807   
START 1   
CACHE 1   
NO CYCLE;



CREATE SEQUENCE validstage.FSG_DAILY_STOCK_SEQ 
INCREMENT 1   
MINVALUE 1   
MAXVALUE 9223372036854775807   
START 1   
CACHE 1   
NO CYCLE;


--tables
--1
CREATE TABLE validstage."asset_installed_certificate" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('validstage.asset_installed_seq')   NOT NULL   PRIMARY KEY,
   material_document   character varying(255),
   movement_type   character varying(255),
   material   text   REFERENCES master.material(material_name),
   plant   character varying(100)   REFERENCES master.plant(plant_name),
   storage_location   character varying(100)   REFERENCES master.fsg(fsg_party_name),
   currency   character varying(100),
   amount_in_lc   numeric(11,2),
   asset_installed   numeric(11,2),
   unit_of_measure   character varying(255)   REFERENCES master.unit_of_measure(name),
   reservation   character varying(255),
   network   character varying(255),
   wbs_element   character varying(255),
   wbs_description   character varying(255),
   wbs_code   character varying(255),
   posting_date   date,
   reference   character varying(255),
   delivery   character varying(255),
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);
--2
CREATE TABLE validstage."customer_install_demand" (
   cust_proj_def_id   integer DEFAULT NEXTVAL ('validstage.customer_install_demand_seq')   NOT NULL   PRIMARY KEY,
   project   character varying(255)   NOT NULL,
   customer   character varying(255)   NOT NULL,
   fm_company   character varying(255),
   install_date   timestamp without time zone   NOT NULL,
   est_install_start   timestamp without time zone,
   est_install_complete   timestamp without time zone,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   fiscal_week   integer,
   transaction_year   integer,
   fsg_order_num   character varying(255)
);

 ALTER TABLE validstage.customer_install_demand ADD COLUMN CUSTOMER_CODE character varying (255);
--3
CREATE TABLE validstage."fsg_issued_valid_stage" (
   fsg_issued_stage_id   integer  DEFAULT NEXTVAL ('validstage.fsg_issued_valid_stage_seq')  NOT NULL   PRIMARY KEY,
   sto   integer,
   material   character varying(255)   NOT NULL   REFERENCES master.material(material_name),
   quantity_shipped   numeric(11,2)   NOT NULL,
   ge_fsg_tracking_number   character varying(255),
   ship_to_customer   character varying(255)   REFERENCES master.customer(customer_name),
   issued_date   timestamp without time zone   NOT NULL,
   customer_purchase_order_number   character varying(255),
   issue_to_type   character varying(255)   NOT NULL   REFERENCES master.loc_type(loc_type),
   issued_from   character varying(255)   NOT NULL   REFERENCES master.loc_type_mapping(loc_type_name),
   received_to   character varying(255)   NOT NULL   REFERENCES master.loc_type_mapping(loc_type_name),
   file_current_date   timestamp without time zone   NOT NULL,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   fiscal_week   integer,
   transaction_year   integer
);
--4
CREATE TABLE validstage."fsg_receipt_valid_stage" (
   fsg_receipt_stage_id   integer DEFAULT NEXTVAL ('validstage.fsg_receipt_valid_stage_seq')   NOT NULL   PRIMARY KEY,
   sto   integer,
   material   character varying(255)   NOT NULL   REFERENCES master.material(material_name),
   plant   character varying(100)   REFERENCES master.plant(plant_name),
   planned_quantity   numeric(11,2)   NOT NULL,
   actual_quantity   numeric(11,2)   NOT NULL,
   ge_fsg_tracking_number   character varying(255),
   receipt_date   timestamp without time zone   NOT NULL,
   customer_purchase_order_number   character varying(255),
   fsg_po   character varying(255),
   receive_from_type   character varying(255)   NOT NULL   REFERENCES master.loc_type(loc_type),
   issued_from   character varying(255)   NOT NULL   REFERENCES master.loc_type_mapping(loc_type_name),
   received_to   character varying(255)   NOT NULL   REFERENCES master.loc_type_mapping(loc_type_name),
   file_current_date   timestamp without time zone   NOT NULL,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   fiscal_week   integer,
   transaction_year   integer
);
--5
CREATE TABLE validstage."inventory_sp_demand" (
   stage_seq_key   integer DEFAULT NEXTVAL ('validstage.inventory_sp_demand_seq')   NOT NULL   PRIMARY KEY,
   material   text   REFERENCES master.material(material_name),
   quantity   numeric(11,2),
   plant   character varying(100)   REFERENCES master.plant(plant_name),
   storage_location   character varying(100)   REFERENCES master.fsg(fsg_party_name),
   project_definition   character varying(255),
   requirement_date   date,
   wbs_element   character varying(255),
   network   character varying(255),
   activity   character varying(255),
   unit_of_measure   character varying(255)   REFERENCES master.unit_of_measure(name),
   reservation_purc_req   character varying(255),
   purchase_requisition   character varying(255),
   requisition_item   integer,
   purchase_ord_exists   character varying(255),
   deletion_indicator   character varying(255),
   reservation   character varying(255),
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   fiscal_week   integer,
   transaction_year   integer
);
--6
CREATE TABLE validstage."plant_sap_valid_stage" (
   plant_sap_stage_id   integer DEFAULT NEXTVAL ('validstage.plant_sap_valid_stage_seq')   NOT NULL   PRIMARY KEY,
   sto   numeric   NOT NULL,
   sto_item   integer,
   material   character varying(255)   NOT NULL   REFERENCES master.material(material_name),
   plant   character varying(100)   REFERENCES master.plant(plant_name),
   storage_location   character varying(100)   NOT NULL   REFERENCES master.fsg(fsg_party_name),
   wbs_element   character varying(255),
   wbs_description   character varying(255),
   quantity   numeric(11,2)   NOT NULL,
   unit_of_measure   character varying(255)   REFERENCES master.unit_of_measure(name),
   delivery_due_date   timestamp without time zone,
   good_issue_date   timestamp without time zone,
   pro_number   character varying(255),
   delivery_number   integer,
   delivery_item_number   integer,
   customer_name   character varying(255)   REFERENCES master.customer(customer_name),
   customer_po   character varying(100),
   order_status   character varying(255)   REFERENCES master.status(status_name),
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone,
   data_source   character varying(1),
   rec_plant   character varying(255),
   shipment_num   integer,
   shipment_crd   date,
   shipment_to_name   character varying(255),
   carrier_name   character varying(255),
   delivery_cr_date   date,
   address_id   integer,
   actual_received   numeric(11,2),
   status   character(1)
);



 
 
 CREATE TABLE  validstage.CUSTOMER_PROJECT_DEFINITION(CUST_PROJ_DEF_ID INTEGER DEFAULT NEXTVAL ('validstage.CUSTOMER_PROJECT_DEFINITION_SEQ') NOT NULL PRIMARY KEY,
 Project character varying (255) NOT NULL,
 Customer character varying (255) NOT NULL NOT NULL REFERENCES master.customer(customer_name),
 Ship_To character varying (255)
 );
 
 
 CREATE TABLE validstage."fsg_daily_stock_valid_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('validstage.fsg_daily_stock_seq')  NOT NULL   PRIMARY KEY,
   STORAGE_LOCATION   character varying(255)   NOT NULL   REFERENCES master.fsg(fsg_party_name),
   material   character varying(255)  NOT NULL  REFERENCES master.material(material_name),
   com   numeric,
   bo   numeric,
   is_processed   character varying(1),
   file_seq_number   integer,
   creation_date   timestamp without time zone
);


--14
--Analytics schema

--sequence

CREATE SEQUENCE analytics."div_transaction_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 51826
   CACHE 1
   NO CYCLE;
   CREATE SEQUENCE analytics."analytics_installation_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 43946
   CACHE 1
   NO CYCLE;
   
   CREATE SEQUENCE analytics."analytics_fsg_stock_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
--tables
--1
CREATE TABLE analytics."analytics_installation" (
   asset_installed_id   integer   DEFAULT NEXTVAL ('analytics.analytics_installation_seq') NOT NULL   PRIMARY KEY,
   material   character varying(255)   NOT NULL   REFERENCES master.material(material_name),
   customer   character varying(255)   NOT NULL   REFERENCES master.customer(customer_name),
   storage_location   character varying(255)   NOT NULL   REFERENCES master.fsg(fsg_party_name),
   assetinstalled   numeric   NOT NULL,
   unit_measure   character varying(255)   NOT NULL   REFERENCES master.unit_of_measure(name),
   installation_date   timestamp without time zone,
   create_dtm   timestamp without time zone
);
ALTER TABLE analytics."analytics_installation" add column is_processed character varying(1);
--2
CREATE TABLE analytics."div_transaction" (
   transaction_id   integer  DEFAULT NEXTVAL ('analytics.div_transaction_seq')  NOT NULL   PRIMARY KEY,
   location   character varying(255)   NOT NULL,
   location_type   character varying(255)   REFERENCES master.loc_type(loc_type),
   sto   numeric,
   source   character varying(255)   REFERENCES master.loc_type_mapping(loc_type_name),
   source_type   character varying(255)   REFERENCES master.loc_type(loc_type),
   material   character varying(255)   NOT NULL   REFERENCES master.material(material_name),
   in_bound_transit_qty   numeric(11,2),
   current_qty   numeric(11,2),
   out_bound_transit_qty   numeric(11,2),
   shipment_tracking_number   character varying(255),
   destination   character varying(255)   REFERENCES master.loc_type_mapping(loc_type_name),
   destination_type   character varying(255)   REFERENCES master.loc_type(loc_type),
   order_status   character varying(255)   REFERENCES master.status(status_name),
   customer_po   character varying(100),
   created_dtm   timestamp without time zone   NOT NULL
);




CREATE  TABLE  analytics.FSG_ACTUAL_DEMAND_STOCK(
 Material character varying (255) NOT NULL,
 customerid character varying (255), 
 Storage_Location character varying (255) NOT NULL,
 demand Decimal,
 fiscal_week INTEGER,
 year INTEGER,
 stock Decimal,
 transit Decimal,
 transit_customer Decimal,
 actual_stock Decimal,
 shortage Decimal 
 );

  
 CREATE  TABLE  analytics.ACTUAL_DEMAND_STOCK(
 Material character varying (255) NOT NULL,
 customerid character varying (255) NOT NULL, 
 Storage_Location character varying (255) NOT NULL,
 demand Decimal,
 fiscal_week INTEGER,
 year INTEGER,
 stock Decimal,
 transit Decimal,
 transit_customer Decimal,
 actual_stock Decimal,
 shortage Decimal 
 );
 
  CREATE  TABLE  analytics.FSG_DAILY_STOCK_NET_INVENTORY(
   fsg_daily_stock_id   integer  DEFAULT NEXTVAL ('analytics.analytics_fsg_stock_seq')  NOT NULL   PRIMARY KEY,
   STORAGE_LOCATION   character varying(255)   NOT NULL   REFERENCES master.fsg(fsg_party_name),
   material   character varying(255)  NOT NULL  REFERENCES master.material(material_name),
   prev_stock Decimal,
   Received Decimal,
   Issued Decimal,
   com   Decimal,
   bo   Decimal,
   curr_stock Decimal,
   net Decimal,
   created_dtm   timestamp without time zone   NOT NULL
 );
 

 
 CREATE SEQUENCE staging."div_processondemand_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
   
 CREATE  TABLE  staging.PROCESS_ON_DEMAND(
 process_id   integer  DEFAULT NEXTVAL ('staging.div_processondemand_seq')  NOT NULL   PRIMARY KEY,
 created_by character varying (255) NOT NULL, 
 created_dtm DATE NOT NULL,
 is_process_triggered  character(1) NOT NULL
 );



--end

