
---xls-col-ref



INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),1,'TEXT','CHR Status','CHR_STATUS',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),2,'TEXT','CHR Order Number','CHR_ORDER_NUMBER',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),3,'TEXT','Origin Pickup Name','ORIGIN_PICKUP_NAME',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),4,'TEXT','Origin Pickup Address 1','ORIGIN_PICKUP_ADDRESS_1',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),5,'TEXT','Origin Pickup City','ORIGIN_PICKUP_CITY',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),6,'TEXT','Origin Pickup State','ORIGIN_PICKUP_STATE',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),7,'TEXT','Destination Delivery Name','DESTINATION_DELIVERY_NAME',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),8,'TEXT','Destination Delivery Address 1','DESTINATION_DELIVERY_ADDRESS_1',current_timestamp,current_timestamp,'502723658','502723658');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),9,'TEXT','Destination Delivery State','DESTINATION_DELIVERY_STATE',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),10,'DATE','Actual Pick-up Arrival Date','ACTUAL_PICK_UP_ARRIVAL_DATE',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),11,'DATE','Actual Delivery Arrival Date','ACTUAL_DELIVERY_ARRIVAL_DATE',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),12,'TEXT','Payer Reference Number','PAYER_REFERENCE_NUMBER',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),13,'TEXT','Customer Reference Number','CUSTOMER_REFERENCE_NUMBER',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),14,'TEXT','Origin BOL','ORIGIN_BOL',current_timestamp,current_timestamp,'502723658','502723658');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),15,'TEXT','Origin PU','ORIGIN_PU',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),16,'TEXT','Origin RefNum','ORIGIN_REFNUM',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),17,'TEXT','Destination DEL','DESTINATION_DEL',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),18,'TEXT','Destination MBOL','DESTINATION_MBOL',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),19,'TEXT','Destination RefNum','DESTINATION_REFNUM',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),20,'TEXT','CHR Number','CHR_NUMBER',current_timestamp,current_timestamp,'502723658','502723658');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),21,'NUMERIC','Actual Pallets','ACTUAL_PALLETS',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),22,'NUMERIC','Actual Weight','ACTUAL_WEIGHT',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),23,'TEXT','Mode','TRANSPORTATION_MODE',current_timestamp,current_timestamp,'502723658','502723658');INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),24,'TEXT','Carrier Pro Number','CARRIER_PRO_NUMBER',current_timestamp,current_timestamp,'502723658','502723658');
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALLER RECEIPT REPORT'),25,'TEXT','Destination Special Instructions','DESTINATION_SPECIAL_INSTRUCTIONS',current_timestamp,current_timestamp,'502723658','502723658');


--validstage
 CREATE SEQUENCE validstage."installer_received_valid_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;


CREATE TABLE validstage."installer_received_valid_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('validstage.installer_received_valid_stage_seq') NOT NULL   PRIMARY KEY,
   CHR_STATUS character varying(255) ,
	CHR_ORDER_NUMBER  character varying(255)  ,
   ORIGIN_PICKUP_NAME   character varying(255),
   ORIGIN_PICKUP_ADDRESS_1   character varying(255),
   ORIGIN_PICKUP_CITY   character varying(255),
   ORIGIN_PICKUP_STATE   character varying(255),
   DESTINATION_DELIVERY_NAME   character varying(255),
   DESTINATION_DELIVERY_ADDRESS_1  character varying(255),
   DESTINATION_DELIVERY_STATE   character varying(255),
   ACTUAL_PICK_UP_ARRIVAL_DATE   timestamp without time zone,
   ACTUAL_DELIVERY_ARRIVAL_DATE   timestamp without time zone,
   PAYER_REFERENCE_NUMBER   character varying(255),
   CUSTOMER_REFERENCE_NUMBER   character varying(255),
   ORIGIN_BOL character varying(255),
   ORIGIN_PU   character varying(255),
   ORIGIN_REFNUM   character varying(255),
   DESTINATION_DEL   character varying(255),
   DESTINATION_MBOL  character varying(255),
   DESTINATION_REFNUM   character varying(255),
	CHR_NUMBER   character varying(255) NOT NULL,
	ACTUAL_PALLETS  integer,
	ACTUAL_WEIGHT   numeric(11,2),
	TRANSPORTATION_MODE   character varying(255),
    CARRIER_PRO_NUMBER   character varying(255),
	DESTINATION_SPECIAL_INSTRUCTIONS character varying(255),
	IS_VALID character varying(1),
	IS_PROCESSED   character varying(1),
   FILE_SEQ_NUMBER   integer,
   CREATION_DATE   timestamp without time zone
);
