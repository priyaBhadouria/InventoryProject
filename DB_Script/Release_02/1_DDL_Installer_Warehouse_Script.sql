----installer_received_stage

-------xls-master

INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'INSTALLER RECEIPT REPORT','INSTALLER RECEIPT REPORT','INSTALLER RECEIPT REPORT',23,'INSTALLER_RECEIVED_STAGE','Y',current_timestamp, current_timestamp,'502723658','502723658','staging');

COMMIT;

 CREATE SEQUENCE staging."installer_received_stage_seq" 
   INCREMENT 1
   MINVALUE 1
   MAXVALUE 9223372036854775807
   START 1
   CACHE 1
   NO CYCLE;
---Tables

CREATE TABLE staging."installer_received_stage" (
   stage_seq_key   integer  DEFAULT NEXTVAL ('staging.installer_received_stage_seq') NOT NULL   PRIMARY KEY,
   CHR_STATUS character varying(255),
  CHR_ORDER_NUMBER  character varying(255),
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
	CHR_NUMBER   character varying(255),
   ACTUAL_PALLETS  integer,
   ACTUAL_WEIGHT   numeric(11,2),
	TRANSPORTATION_MODE   character varying(255),
    CARRIER_PRO_NUMBER   character varying(255),
  DESTINATION_SPECIAL_INSTRUCTIONS character varying(255),
	IS_PROCESSED   character varying(1),
   FILE_SEQ_NUMBER   integer,
   CREATION_DATE   timestamp without time zone
);




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
