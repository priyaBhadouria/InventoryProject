-- master data

INSERT INTO master.file_format(file_format_id,format_name,creation_date) VALUES(nextval('master.file_format_id_seq'),'CSV',now());
COMMIT;


INSERT INTO master.loc_type(loc_type,creation_date) values('GE',now());
INSERT INTO master.loc_type(loc_type,creation_date) values('FSG',now());
INSERT INTO master.loc_type(loc_type,creation_date) values('CUSTOMER',now()); 


INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'RECEIPT','RECEIPT',now());
INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'ISSUED','ISSUED',now());
INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'ACTIVE','ACTIVE',now());
INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'CANCEL','CANCEL',now());
INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'CONSUMED','CONSUMED',now());
INSERT INTO master.status(status_id,status_name,status_desc,creation_date) VALUES(nextval('master.status_seq'),'IN TRANSIT','IN TRANSIT',now());


INSERT INTO master.TRANSACTION_TYPE(transaction_id,transaction_type_name,transaction_type_desc,creation_date) VALUES(nextval('master.transaction_seq'),'RECEIPT','RECEIPT',now());
INSERT INTO master.TRANSACTION_TYPE(transaction_id,transaction_type_name,transaction_type_desc,creation_date) VALUES(nextval('master.transaction_seq'),'ISSUED','ISSUED',now());

INSERT INTO master.customer(customer_name,creation_date,customer_desc) VALUES('SAFETY STOCK',now(),'SAFETY STOCK');

COMMIT;





INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'FSG RECEIPT REPORT','FSG RECEIPT REPORT','FSG RECEIPT',22,'FSG_RECEIPT_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');

INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'FSG ISSUED REPORT','FSG ISSUED REPORT','FSG ISSUED',22,'FSG_ISSUED_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');


INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'SAP STO REPORT','GE LED SHIPMENT','SAP STO REPORT',21,'PLANT_SAP_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');


INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'FSG DEMAND REPORT','FSG DEMAND REPORT','FSG DEMAND REPORT',17,'FSG_DEMAND_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');



INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'CORE SHIPMENT REPORT','GE CORE SHIPMENT','CORE SHIPMENT REPORT',16,'CORE_SHIPMENT_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');


INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'INSTALL CERTIFICATE REPORT','INSTALL CERTIFICATE REPORT','INSTALL CERTIFICATE REPORT',17,'ASSET_INSTALLED_CERTIFICATE','Y',current_timestamp, current_timestamp,'502342435','502342435','validstage');


INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'CUSTOMER INSTALL DEMAND','SMART SHEET','CUSTOMER INSTALL DEMAND',9,'CUSTOMER_INSTALL_DEMAND_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');

INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'SAP PURCHASING ORDER','SAP PURCHASING ORDER','SAP PURCHASING ORDER',19,'SAP_PURCHASING_ORDER_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');


INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'FSG DAILY STOCK','FSG DAILY STOCK','FSG DAILY STOCK',10,'FSG_DAILY_STOCK_STAGE','Y',current_timestamp, current_timestamp,'502342435','502342435','staging');



INSERT INTO staging.XLS_MASTER(XLS_ID,XLS_NAME,xls_desc,download_name,TOTAL_COLUMNS,db_table_name,active,create_dtm,update_dtm,created_by,updated_by,schema_name) VALUES(nextval('staging.XLS_MASTER_ID_SEQ'),'INSTALLER RECEIPT REPORT','INSTALLER RECEIPT REPORT','INSTALLER RECEIPT REPORT',23,'INSTALLER_RECEIVED_STAGE','Y',current_timestamp, current_timestamp,'502723658','502723658','staging');

COMMIT;





--SAP DTO EXCEL to DB Mapping

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),2,'INTEGER','Delivery Number','DELIVERY_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),3,'INTEGER','Delivery Item','DELIVERY_ITEM_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),4,'DATE','Del.CrDat','DELIVERY_CR_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),17,'TEXT','Material Number','material',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),18,'TEXT','Plant','plant',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),20,'NUMERIC',' Del.Qty','quantity',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),25,'TEXT','Rec Plant','REC_PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),26,'TEXT','Rec Str.Loc','storage_location',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),27,'NUMERIC','Order Num','sto',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),28,'INTEGER','Ord Itm','sto_item',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),36,'TEXT','Mat.Desc','material_description',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),48,'INTEGER','Shipment Number','SHIPMENT_NUM',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),49,'DATE','Shipment CRD','SHIPMENT_CRD',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),56,'TEXT','Ship-to Country','SHIPMENT_TO_COUNTRY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),57,'TEXT','Ship-to Name','SHIPMENT_TO_NAME',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),58,'TEXT','Ship-to Street','SHIPMENT_TO_STREET',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),59,'TEXT','Ship-to Postal Code','SHIPMENT_TO_ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),60,'TEXT','Ship-to City','SHIPMENT_TO_CITY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),69,'TEXT','Carrier Name','CARRIER_NAME',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),70,'TEXT','Pro number','PRO_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP STO REPORT'),23,'TEXT','UoM','UNIT_OF_MEASURE',current_timestamp,current_timestamp,'502342435','502342435');




--isued report	

/* 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),1,'INTEGER','STO#','sto',current_timestamp,current_timestamp,'502342435','502342435'); */

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),2,'TEXT','Mtl#','material',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),3,'TEXT','Desc','material_description',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),4,'NUMERIC','QtySent','QUANTITY_SHIPPED',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),5,'TEXT','Track#','GE_FSG_TRACKING_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),6,'TEXT','CustNM','SHIP_TO_CUSTOMER',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),7,'DATE','ShipDT','ISSUED_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),8,'TEXT','CustPO','CUSTOMER_PURCHASE_ORDER_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),9,'TEXT','IssueTo','ISSUE_TO_TYPE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),10,'TEXT','IssueNM','ISSUED_FROM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),11,'TEXT','IssueAdd','ISSUED_FROM_ADDRESS',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),12,'TEXT','IssueCity','ISSUED_FROM_CITY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),13,'TEXT','IssueSt','ISSUED_FROM_STATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),14,'TEXT','IssueZip','ISSUED_FROM_ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),15,'TEXT','IssueCtry','ISSUED_FROM_COUNTRY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),16,'TEXT','ReceiveNm','RECEIVED_TO',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),17,'TEXT','ReceiveAdd','RECEIVED_TO_ADDRESS',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),18,'TEXT','ReceiveCity','RECEIVED_TO_CITY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),19,'TEXT','ReceiveST','RECEIVED_TO_STATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),20,'TEXT','ReceiveZip','RECEIVED_TO_ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),21,'TEXT','ReceiveCntry','RECEIVED_TO_COUNTRY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG ISSUED REPORT'),22,'DATE','Date','FILE_CURRENT_DATE',current_timestamp,current_timestamp,'502342435','502342435');

COMMIT;



--RECEIPT


--INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
--((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),1,'INTEGER','STO#','sto',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),2,'TEXT','Mtl#','material',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),3,'TEXT','Desc','material_description',current_timestamp,current_timestamp,'502342435','502342435');
 
--INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
--((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),4,'TEXT','PLANT','plant',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),5,'NUMERIC','QtyShipped','PLANNED_QUANTITY',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),6,'NUMERIC','QtyRcv','ACTUAL_QUANTITY',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),7,'TEXT','GE PRO#','GE_FSG_TRACKING_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),8,'DATE','ReceiptDt','RECEIPT_DATE',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),9,'TEXT','CustPO#','CUSTOMER_PURCHASE_ORDER_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),10,'TEXT','Rcv Fm','RECEIVE_FROM_TYPE',current_timestamp,current_timestamp,'502342435','502342435');
 
 INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),11,'TEXT','Name Of Issuer','ISSUED_FROM',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),12,'TEXT','Addr of Issuer','ISSUED_FROM_ADDRESS',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),13,'TEXT','City of Issuer','ISSUED_FROM_CITY',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),14,'TEXT','Issuer St','ISSUED_FROM_STATE',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),15,'TEXT','Issuer Zip','ISSUED_FROM_ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');
 
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),16,'TEXT','Country','ISSUED_FROM_COUNTRY',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),17,'TEXT','Receiver Nm','RECEIVED_TO',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),18,'TEXT','Receiver Add','RECEIVED_TO_ADDRESS',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),19,'TEXT','Receiver City','RECEIVED_TO_CITY',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),20,'TEXT','Receiver St','RECEIVED_TO_STATE',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),21,'TEXT','Receiver Zip','RECEIVED_TO_ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');
 
INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),22,'TEXT','Receiver Ctry','RECEIVED_TO_COUNTRY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),23,'TEXT','Date','FILE_CURRENT_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG RECEIPT REPORT'),24,'TEXT','FSG#','FSG_PO',current_timestamp,current_timestamp,'502342435','502342435');
 



 



--FSG DEMAND REPORT to DB Mapping

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),1,'TEXT','Material','MATERIAL',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),2,'TEXT','Material text','MATERIAL_DESCRIPTION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),3,'NUMERIC','Quantity in UnE','QUANTITY',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),4,'TEXT','Plant','PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),5,'TEXT','Storage location','STORAGE_LOCATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),6,'TEXT','Project definition','PROJECT_DEFINITION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),7,'DATE','Requirements date','REQUIREMENT_DATE',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),8,'TEXT','WBS element','WBS_ELEMENT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),9,'TEXT','Network','NETWORK',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),10,'TEXT','Activity','ACTIVITY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),11,'TEXT','Unit of entry','UNIT_OF_MEASURE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),12,'TEXT','Reservation/Purc.req','RESERVATION_PURC_REQ',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),13,'TEXT','Purchase requisition','PURCHASE_REQUISITION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),14,'INTEGER','Requisition item','REQUISITION_ITEM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),15,'TEXT','Purchase ord. exists','PURCHASE_ORD_EXISTS',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),16,'TEXT','Deletion Indicator','DELETION_INDICATOR',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DEMAND REPORT'),17,'TEXT','Reservation','RESERVATION',current_timestamp,current_timestamp,'502342435','502342435');






--CORE SHIPMENT



INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),1,'TEXT','Ship to Name','STORAGE_LOCATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),2,'NUMERIC','Order Number','ORDER_NUM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),3,'TEXT','Customer Purchase Order Number','CUSTOMER_PO',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),4,'DATE','Order Entry Date','ORDER_ENTRY_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),5,'DATE','Order Summary Del Req Date','ORDER_SUM_DEL_REQ_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),6,'TEXT','Product Code','MATERIAL',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),7,'TEXT','Product Description','MATERIAL_DESCRIPTION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),8,'NUMERIC','Order Item Quantity-UnExp','ORDER_ITEM_QTY_UNEXP',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),9,'NUMERIC','Order Item Shipped Qty-UnExp','ORDER_ITEM_SHIP_QTY_UNEXP',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),10,'TEXT','Ship Line Status Code','SHIP_LINE_STATUS_CODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),11,'TEXT','Pick Ticket Number','PICK_TICK_NUM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),12,'TEXT','Component Number','PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),13,'TEXT','BOL #','BOL',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),14,'TEXT','Carrier SCAC Code','CARRIER_SCAC_CODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),15,'TEXT','BOL Pro Number','BOL_PRO_NUMBER',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CORE SHIPMENT REPORT'),16,'DATE','Ship Line Ship Date','SHIP_LINE_SHIP_DATE',current_timestamp,current_timestamp,'502342435','502342435');





--INSTALL CERTIFICATE



INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),1,'TEXT','Material Document','MATERIAL_DOCUMENT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),2,'TEXT','Movement Type','MOVEMENT_TYPE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),3,'TEXT','Material','MATERIAL',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),4,'TEXT','Plant','PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),5,'TEXT','Storage Location','STORAGE_LOCATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),6,'TEXT','Currency','CURRENCY',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),7,'NUMERIC','Amount in LC','AMOUNT_IN_LC',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),8,'NUMERIC','Quantity','ASSET_INSTALLED',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),9,'TEXT','Base Unit of Measure','UNIT_OF_MEASURE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),10,'TEXT','Reservation','RESERVATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),11,'TEXT','Network','NETWORK',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),12,'TEXT','WBS Element','WBS_ELEMENT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),13,'TEXT','WBS Discription','WBS_DESCRIPTION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),14,'TEXT','WBS Code','WBS_CODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),15,'DATE','Posting Date','POSTING_DATE',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),16,'TEXT','Reference','REFERENCE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='INSTALL CERTIFICATE REPORT'),17,'TEXT','Delivery','DELIVERY',current_timestamp,current_timestamp,'502342435','502342435');


COMMIT;

-- customer install demand

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),4,'TEXT','BLDG_ID','Customer',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),2,'TEXT','FM Company','FM_COMPANY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),9,'DATE','Week of Install','Install_Date',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),41,'TEXT','FSG Order #','FSG_ORDER_NUM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),5,'TEXT','Street 1','STREET',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),6,'TEXT','City','CITY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),7,'TEXT','State/Region','STATE_REGION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),36,'TEXT','Ship-to Customer Code','CUSTOMER_CODE',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),37,'TEXT','Ship-to Customer Name','CUSTOMER_NAME',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),38,'TEXT','Zip Code','ZIPCODE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='CUSTOMER INSTALL DEMAND'),35,'TEXT','Project Definition','project_definition',current_timestamp,current_timestamp,'502342435','502342435');





--SAP purchasing order


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),1,'TEXT','Purchasing Document','PURCHASING_DOCUMENT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),2,'NUMERIC','Item','ITEM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),3,'TEXT','Vendor','VENDOR',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),4,'TEXT','Material Group','MATERIAL_GROUP',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),5,'TEXT','Material','MATERIAL',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),6,'TEXT','Purch. Organization','PURCH_ORGANIZATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),7,'TEXT','Purchasing Group','PURCH_GROUP',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),8,'TEXT','Plant','PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),9,'TEXT','Storage Location','STORAGE_LOCATION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),10,'DATE','Document Date','DOCUMENT_DATE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),11,'NUMERIC','Order Quantity','ORDER_QTY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),12,'TEXT','Order Unit','ORDER_UNIT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),13,'NUMERIC','Net Order Value','NET_ORDER_VALUE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),14,'TEXT','Currency','CURRENCY',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),15,'TEXT','Order Price Unit','ORDER_PRICE_UNIT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),16,'TEXT','Incomplete','INCOMPLETE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),17,'TEXT','Purchasing Doc. Type','PURCHASING_DOC_TYPE',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),18,'TEXT','Supplying Plant','SUPPLYING_PLANT',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='SAP PURCHASING ORDER'),19,'TEXT','Short Text','MATERIAL_DESCRIPTION',current_timestamp,current_timestamp,'502342435','502342435');




--FSG DAILY STOCK



INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),1,'TEXT','UPC','MATERIAL',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),2,'TEXT','Desc','MATERIAL_DESCRIPTION',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),3,'NUMERIC','FSCACom','FSCA_COM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),4,'NUMERIC','FSCABO','FSCA_BO',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),5,'NUMERIC','FSTXCom','FSTX_COM',current_timestamp,current_timestamp,'502342435','502342435');


INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),6,'NUMERIC','FSTXBO','FSTX_BO',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),7,'NUMERIC','FSILCom','FSIL_COM',current_timestamp,current_timestamp,'502342435','502342435');

INSERT INTO staging.XLS_COL_REF(xls_id,xls_column_index,data_type_postgres,input_header_text,db_column_name,create_dtm,update_dtm,created_by,updated_by) VALUES
((SELECT XLS_ID FROM staging.XLS_MASTER where XLS_NAME='FSG DAILY STOCK'),8,'NUMERIC','FSILBO','FSIL_BO',current_timestamp,current_timestamp,'502342435','502342435');



--security


insert into master.div_security(sso,group_name,sso_desc) values('212584649','ADMIN','SANTOSH');
insert into master.div_security(sso,group_name,sso_desc) values('320003386','ADMIN','BIJU');
insert into master.div_security(sso,group_name,sso_desc) values('320004781','ADMIN','SACHIN');
insert into master.div_security(sso,group_name,sso_desc) values('502685514','ADMIN','NARSI');
insert into master.div_security(sso,group_name,sso_desc) values('502723658','ADMIN','MALATHY');
--

