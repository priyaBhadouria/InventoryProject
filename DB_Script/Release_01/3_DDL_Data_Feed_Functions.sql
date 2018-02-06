



  
create or replace function staging.updateMaterialFromSAP() returns integer AS $$
   DECLARE
   count integer :=0;
  begin
  update staging.plant_sap_stage set material=LTRIM(material,'0');
  update staging.sap_purchasing_order_stage set material=LTRIM(material,'0');
  update staging.fsg_demand_stage set material=LTRIM(material,'0');
  update validstage.ASSET_INSTALLED_CERTIFICATE set material=LTRIM(material,'0');
  return count;
  end;
   $$ LANGUAGE plpgsql VOLATILE; 



--Function for inserting into Plant from Plant Sap staging Table


--NEW

  create or replace function staging.insertMasterDataPlantFromSAP()
  returns integer as
  $BODY$
  DECLARE
  c cursor  for select * from staging.plant_sap_stage where is_processed = 'N' ;
  count integer;
  plantRecord RECORD;
  begin
   count := (select staging.updateMaterialFromSAP());
  count:=0;
  open c;
  LOOP
  fetch c into plantRecord;
  exit when not found; 
  if (trim(plantRecord.plant) not in(select plant_name from master.plant)) then 
   insert into master.plant(plant_name,creation_date) select trim(plantRecord.plant),now() ;
    count:=count+1; 
    end if;
    
      if(trim(plantRecord.plant) not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'GE',trim(plantRecord.plant),now();
        end if;
   END LOOP;
   close c;
   return count;
   end;
  $BODY$
  LANGUAGE plpgsql VOLATILE;  
  
--old---
 create or replace function staging.insertMasterDataPlantFromSAP()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select * from staging.plant_sap_stage where is_processed = 'N' ;
	count integer;
	plantRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into plantRecord;
	exit when not found; 
	if (trim(plantRecord.plant) not in(select plant_name from master.plant)) then 
	 insert into master.plant(plant_name,creation_date) select trim(plantRecord.plant),now() ;
	  count:=count+1; 
	  end if;
	  
	  	if(trim(plantRecord.plant) not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'GE',trim(plantRecord.plant),now();
        end if;
   END LOOP;
   close c;
  select staging.updateMaterialFromSAP();
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;  
  
  --insertMasterDataMaterialFromSAP
       create or replace function staging.insertMasterDataMaterialFromSAP()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select MATERIAL, MATERIAL_DESCRIPTION,UNIT_OF_MEASURE from staging.plant_sap_stage where is_processed = 'N' group by MATERIAL,MATERIAL_DESCRIPTION,UNIT_OF_MEASURE;	
	count integer;
	addressCustomer integer;
	sapRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into sapRecord;
	exit when not found; 
	if (sapRecord.material IS NOT NULL) then
		if (trim(sapRecord.material) not in(select material_name from master.material)) then 
		
		 insert into master.material(material_name,material_description,creation_date,uom) select  trim(sapRecord.material),sapRecord.material_description,now(),sapRecord.UNIT_OF_MEASURE;
		 count:=count+1; 
		end if;
	end if;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE; 
   
     --Function for inserting into GE Storage Location from Plant Sap staging Table
create or replace function staging.insertMasterDataStorageLocationFromSAP()
                returns integer as
                $BODY$
                DECLARE
                c cursor  for select * from staging.plant_sap_stage where is_processed = 'N';
                count integer;
				addressIssueFromFSG integer;
                storageLocRecord RECORD;
                begin
               
                count:=0;
                open c;
                LOOP
                fetch c into storageLocRecord;
                exit when not found;
				if (storageLocRecord.storage_location IS NOT NULL) then
					if (trim(storageLocRecord.storage_location) not in(select fsg_party_name from master.fsg)) then 
		
						insert into master.address(street,city,zipcode,country,creation_date) select storageLocRecord.SHIPMENT_TO_STREET,storageLocRecord.SHIPMENT_TO_CITY,storageLocRecord.SHIPMENT_TO_ZIPCODE,storageLocRecord.SHIPMENT_TO_COUNTRY,now() RETURNING address_id INTO addressIssueFromFSG;
						
						insert into master.fsg(fsg_party_name,is_hub,creation_date,address_id) select  trim(storageLocRecord.storage_location),'Y',now(),addressIssueFromFSG ;
						
						insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'FSG',trim(storageLocRecord.storage_location),now();
						
						count:=count+1; 
					end if;
	  
					if(trim(storageLocRecord.storage_location) not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'FSG',trim(storageLocRecord.storage_location),now();
					end if;
					
					if((select address_id from master.fsg where fsg_party_name = trim(storageLocRecord.storage_location)) IS NULL) then
					insert into master.address(street,city,zipcode,country,creation_date) select storageLocRecord.SHIPMENT_TO_STREET,storageLocRecord.SHIPMENT_TO_CITY,storageLocRecord.SHIPMENT_TO_ZIPCODE,storageLocRecord.SHIPMENT_TO_COUNTRY,now() RETURNING address_id INTO addressIssueFromFSG;
						
	  
					UPDATE master.fsg SET creation_date = now(),address_id=addressIssueFromFSG  WHERE fsg_party_name = trim(storageLocRecord.storage_location);
					end if;
				end if;
	         
   END LOOP;
   close c;
   return count;
   end;
                $BODY$
  LANGUAGE plpgsql VOLATILE; 
  
  
  --Function for inserting into Unit_of_measure from Plant Sap staging Table
  create or replace function staging.insertMasterDataUnitOfMeasureFromSAP()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select * from staging.plant_sap_stage where is_processed = 'N';
	count integer;
	uomRec RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into uomRec;
	exit when not found; 
	if (trim(uomRec.UNIT_OF_MEASURE) not in(select name from master.unit_of_measure)) then 	 
	 insert into master.unit_of_measure(name,creation_date) select trim(uomRec.UNIT_OF_MEASURE),now() ;
	  count:=count+1;
	  end if;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE; 
  
  --insert valid shipment from staging to validstage
  
  CREATE OR REPLACE FUNCTION staging.insertvalidsaptovalidstage() RETURNS integer AS $$ 
  DECLARE
  c cursor  for select * from staging.plant_sap_stage where is_processed = 'N' and REC_PLANT='1PS1' and STORAGE_LOCATION IN ('FSIL','FSTX','FSCA') and shipment_crd >= '11/01/2016';
  count1 integer;
  sapStage1 RECORD;
  V_LOG TEXT;
  begin
    --TRUNCATE TABLE validstage.PLANT_SAP_VALID_STAGE;
  count1:=0;
  open c;
  LOOP
  fetch c into sapStage1;
  exit when not found; 
BEGIN
  V_LOG := (select log from staging.logger where upload_or_run_id=sapStage1.file_seq_number);
  
   insert into validstage.PLANT_SAP_VALID_STAGE(STO,STO_ITEM, MATERIAL,PLANT,STORAGE_LOCATION,WBS_ELEMENT,WBS_DESCRIPTION,QUANTITY,UNIT_OF_MEASURE,DELIVERY_DUE_DATE,GOOD_ISSUE_DATE,PRO_NUMBER,DELIVERY_NUMBER,DELIVERY_ITEM_NUMBER,CUSTOMER_NAME, CUSTOMER_PO, ORDER_STATUS,REC_PLANT,SHIPMENT_CRD,SHIPMENT_NUM,ADDRESS_ID,CARRIER_NAME,DELIVERY_CR_DATE,DATA_SOURCE, IS_PROCESSED,FILE_SEQ_NUMBER,creation_date) values(sapStage1.STO,sapStage1.STO_ITEM,trim(sapStage1.MATERIAL),trim(sapStage1.PLANT),trim(sapStage1.STORAGE_LOCATION),sapStage1.WBS_ELEMENT,sapStage1.WBS_DESCRIPTION,sapStage1.QUANTITY,trim(sapStage1.UNIT_OF_MEASURE),sapStage1.DELIVERY_DUE_DATE,sapStage1.GOOD_ISSUE_DATE,sapStage1.PRO_NUMBER,sapStage1.DELIVERY_NUMBER,sapStage1.DELIVERY_ITEM_NUMBER,trim(sapStage1.CUSTOMER_NAME),trim(sapStage1.CUSTOMER_PO),'ACTIVE',trim(sapStage1.REC_PLANT),sapStage1.SHIPMENT_CRD,sapStage1.SHIPMENT_NUM,(SELECT ADDRESS_ID from master.fsg where fsg_party_name=trim(sapStage1.STORAGE_LOCATION)),sapStage1.CARRIER_NAME,sapStage1.DELIVERY_CR_DATE,'S',sapStage1.IS_PROCESSED,sapStage1.FILE_SEQ_NUMBER,now());
    count1:=count1+1;
  
  
  UPDATE staging.plant_sap_stage SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = sapStage1.STAGE_SEQ_KEY;
  EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' '|| SQLERRM || ' '||sapStage1.STAGE_SEQ_KEY where upload_or_run_id=sapStage1.file_seq_number;
      UPDATE staging.plant_sap_stage SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = sapStage1.STAGE_SEQ_KEY;
  end;
  
   END LOOP;
   UPDATE staging.sap_upload SET  IS_PROCESSED = 'Y' where id = sapStage1.FILE_SEQ_NUMBER;
   close c;
   
    UPDATE staging.plant_sap_stage SET  IS_PROCESSED = 'F' where shipment_crd < '11/01/2016';
    --count = analytics.saveupdate_analytics_sap();
   return count1;
   end;
  $$ LANGUAGE plpgsql;
  
   --saveupdate_analytics_sap
  CREATE FUNCTION analytics."saveupdate_analytics_sap"() RETURNS integer AS $$    
DECLARE
      sap_stage_row RECORD; 
      div_analytic_FSG RECORD; 
      div_analytic_GE RECORD;   
BEGIN  
    For sap_stage_row in select PLANT_SAP_STAGE_ID,STO,
    MATERIAL,REC_PLANT,STORAGE_LOCATION,QUANTITY,
    UNIT_OF_MEASURE,QUANTITY,PRO_NUMBER,
    SHIPMENT_CRD from validstage.plant_sap_valid_stage 
    where is_processed='N'       
    LOOP
        BEGIN
         Select divtrans.transaction_id, divtrans.material,divtrans.location,divtrans.location_type,divtrans.source,divtrans.source_type,divtrans.shipment_tracking_number into div_analytic_FSG from analytics.div_transaction divtrans 
       where sap_stage_row.STORAGE_LOCATION=divtrans.location 
        and divtrans.location_type='FSG'
        and sap_stage_row.REC_PLANT=divtrans.source
        and divtrans.source_type='GE'
        and sap_stage_row.material=divtrans.material
    and sap_stage_row.sto = divtrans.sto;
         
       IF div_analytic_FSG is null THEN
       
          raise notice 'Insert data for  % %', sap_stage_row.STORAGE_LOCATION, sap_stage_row.material;
          INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,
                                             source,source_type,material,in_bound_transit_qty,
                                             shipment_tracking_number,created_dtm) 
          VALUES(nextval('analytics.div_transaction_seq'),sap_stage_row.STORAGE_LOCATION,'FSG',sap_stage_row.sto,
               sap_stage_row.REC_PLANT,'GE',sap_stage_row.material,sap_stage_row.quantity,
               sap_stage_row.pro_number,sap_stage_row.SHIPMENT_CRD); 
               
         ELSE 
       
           raise notice 'Update data for  % %', sap_stage_row.STORAGE_LOCATION, sap_stage_row.material;
             
           UPDATE analytics.div_transaction Set(in_bound_transit_qty)
           =(analytics.get_total_quantity(sap_stage_row.quantity,in_bound_transit_qty, 'A'))
           where transaction_id=div_analytic_FSG.transaction_id;
       
        END IF;
    
             
    
         Select divtrans.transaction_id,divtrans.material,divtrans.location,
        divtrans.location_type,divtrans.destination,
        divtrans.destination_type,divtrans.shipment_tracking_number
        into div_analytic_GE from analytics.div_transaction divtrans 
       where sap_stage_row.REC_PLANT=divtrans.location 
        and divtrans.location_type='GE'
        and sap_stage_row.STORAGE_LOCATION=divtrans.destination
        and divtrans.destination_type='FSG'
        and sap_stage_row.material=divtrans.material
    and sap_stage_row.sto = divtrans.sto;
     IF div_analytic_GE is null
     THEN 
     
         raise notice 'Insert data for  % %', sap_stage_row.REC_PLANT, sap_stage_row.material;
          
         INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,material,destination,destination_type,out_bound_transit_qty,shipment_tracking_number,created_dtm)
        VALUES(nextval('analytics.div_transaction_seq'),sap_stage_row.REC_PLANT,'GE',sap_stage_row.sto,sap_stage_row.material,sap_stage_row.STORAGE_LOCATION,'FSG',sap_stage_row.quantity,sap_stage_row.pro_number,sap_stage_row.SHIPMENT_CRD);      
     ELSE 
     
        raise notice 'Update data for  % %', sap_stage_row.REC_PLANT, sap_stage_row.material;
         
        UPDATE analytics.div_transaction Set(out_bound_transit_qty)
        =(analytics.get_total_quantity( sap_stage_row.quantity, out_bound_transit_qty,'A'))
        where transaction_id=div_analytic_GE.transaction_id ;
        
     END IF; 
      
          
        
     update  validstage.plant_sap_valid_stage set is_processed = 'P'
      where PLANT_SAP_STAGE_ID=sap_stage_row.PLANT_SAP_STAGE_ID;
                    
   
    exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise notice '% %', SQLERRM, SQLSTATE;   
     return 1;
  END;   
    END LOOP;
        
    return 1;   
END;
$$ LANGUAGE plpgsql;



--Core Shipment

--insert master data
 create or replace function staging.masterPlantFromCoreShipment()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select * from staging.CORE_SHIPMENT_STAGE where is_processed = 'N' ;
	count integer;
	plantCoreShipmentRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into plantCoreShipmentRecord;
	exit when not found; 
	if (trim(plantCoreShipmentRecord.PLANT) not in(select plant_name from master.plant)) then 
	 insert into master.PLANT(plant_name,creation_date) select trim(plantCoreShipmentRecord.PLANT),now() ;
	  count:=count+1; 
	  end if;
	  	if(trim(plantCoreShipmentRecord.PLANT) not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'GE',trim(plantCoreShipmentRecord.PLANT),now();
        end if;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;  
  
   create or replace function staging.insertMasterDataUnitOfMeasureFromCore()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select * from staging.SAP_PURCHASING_ORDER_STAGE  where is_processed = 'N';
	count integer;
	uomRec RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into uomRec;
	exit when not found; 
	if (trim(uomRec.ORDER_PRICE_UNIT) not in(select name from master.unit_of_measure)) then 	 
	 insert into master.unit_of_measure(name,creation_date) select trim(uomRec.ORDER_PRICE_UNIT),now() ;
	  count:=count+1;
	  end if;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE; 
  
  --material data from purchase order
  create or replace function staging.masterMaterialFromPurchasOrder()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select * from staging.SAP_PURCHASING_ORDER_STAGE where is_processed = 'N';	
	count integer;
	purchaseOrderRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into purchaseOrderRecord;
	exit when not found; 
	if (purchaseOrderRecord.material IS NOT NULL) then
		if (trim(purchaseOrderRecord.material) not in(select material_name from master.material)) then 
		
		 insert into master.material(material_name,material_description,uom,creation_date,purchase_doc) select  trim(purchaseOrderRecord.material),purchaseOrderRecord.material_description,
					purchaseOrderRecord.ORDER_UNIT,now(),purchaseOrderRecord.PURCHASING_DOCUMENT;
		 count:=count+1; 
		end if;
			if(trim(purchaseOrderRecord.material) in(select material_name from master.material)) then 
			UPDATE master.material SET  uom=purchaseOrderRecord.ORDER_UNIT,
			purchase_doc=purchaseOrderRecord.PURCHASING_DOCUMENT where material_name = trim(purchaseOrderRecord.material);
			 count:=count+1; 
			end if;
	end if;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE; 
  
  --valid core from staging to sap validstage
  CREATE OR REPLACE FUNCTION staging.insertvalidcoretovalidstage() RETURNS integer AS $$   
  DECLARE
  c cursor  for select * from staging.CORE_SHIPMENT_STAGE core inner join staging.SAP_PURCHASING_ORDER_STAGE purchase
on trim(core.CUSTOMER_PO)= trim(purchase.PURCHASING_DOCUMENT) where core.ORDER_ITEM_SHIP_QTY_UNEXP is not null and core.ship_line_ship_date >= '11/01/2016' and core.is_processed = 'N';
  count1 integer;
  coreStage1 RECORD;
  vStorageLocation TEXT;
  V_LOG TEXT;
  begin
  count1:=0;
  open c;
  LOOP
  fetch c into coreStage1;
  exit when not found; 
    
  
   if (coreStage1.STORAGE_LOCATION = 'FS TEXAS/CURRENT') then
      vStorageLocation := 'FSTX';
  else if(coreStage1.STORAGE_LOCATION = 'FS CALIFORNIA/CURRENT') then
      vStorageLocation := 'FSCA';
  else if(coreStage1.STORAGE_LOCATION = 'FS ILLINOIS/CURRENT') then
      vStorageLocation := 'FSIL';
    end if;
  end if;
  end if;
      
      BEGIN
  
  
  V_LOG := (select log from staging.logger where upload_or_run_id=coreStage1.file_seq_number);
  
    insert into validstage.PLANT_SAP_VALID_STAGE(STO,STO_ITEM, MATERIAL,PLANT,STORAGE_LOCATION,
    WBS_ELEMENT,WBS_DESCRIPTION,QUANTITY,UNIT_OF_MEASURE,DELIVERY_DUE_DATE,
    GOOD_ISSUE_DATE,PRO_NUMBER,DELIVERY_NUMBER,DELIVERY_ITEM_NUMBER,CUSTOMER_NAME, CUSTOMER_PO, ORDER_STATUS,REC_PLANT,
    SHIPMENT_CRD,SHIPMENT_NUM,ADDRESS_ID,
    CARRIER_NAME,DELIVERY_CR_DATE,DATA_SOURCE, IS_PROCESSED,FILE_SEQ_NUMBER,creation_date) values
    (coreStage1.ORDER_NUM,null, (select material from staging.SAP_PURCHASING_ORDER_STAGE where trim(purchasing_document)=trim(coreStage1.CUSTOMER_PO) limit 1),trim(coreStage1.PLANT),vStorageLocation,
    null, null,coreStage1.ORDER_ITEM_SHIP_QTY_UNEXP,(select ORDER_PRICE_UNIT from staging.SAP_PURCHASING_ORDER_STAGE where trim(purchasing_document)=trim(coreStage1.CUSTOMER_PO) limit 1),coreStage1.ORDER_SUM_DEL_REQ_DATE,
    coreStage1.SHIP_LINE_SHIP_DATE,coreStage1.BOL_PRO_NUMBER,null,null,null, trim(coreStage1.CUSTOMER_PO),'ACTIVE','1PS1',
    coreStage1.SHIP_LINE_SHIP_DATE,null,(SELECT ADDRESS_ID from master.fsg where fsg_party_name=vStorageLocation),
    coreStage1.CARRIER_SCAC_CODE, coreStage1.ORDER_ENTRY_DATE,'C',coreStage1.IS_PROCESSED,coreStage1.FILE_SEQ_NUMBER,now());
   
    count1:=count1+1;
  
  UPDATE staging.CORE_SHIPMENT_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = coreStage1.STAGE_SEQ_KEY;
  EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' ' || SQLERRM || ' ' || coreStage1.STAGE_SEQ_KEY where upload_or_run_id=coreStage1.file_seq_number;
    UPDATE staging.CORE_SHIPMENT_STAGE SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = coreStage1.STAGE_SEQ_KEY;
  end;
  
   END LOOP;
    UPDATE staging.sap_upload SET  IS_PROCESSED = 'Y' where id = coreStage1.FILE_SEQ_NUMBER;
   close c;
    --count = analytics.saveupdate_analytics_sap();
   return count1;
   end;
    $$ LANGUAGE plpgsql;
	
	
	--FSG RECEIPT
	
	--master data from fsg receipt
	
	CREATE OR REPLACE FUNCTION staging.insertmasterdatafromfsgreceipt() RETURNS integer AS $$ 
  DECLARE
  c cursor  for select * from staging.fsg_receipt_stage where is_processed = 'N';
  count integer;
  addressIssueFromGE integer;
  addressIssueFromFSG integer;
  addressIssueFromCust integer;
  addressFSG integer;
  varPlant TEXT;
  fsgReceipt RECORD;
  begin
  
  count:=0;
  open c;
  LOOP
  fetch c into fsgReceipt;
  exit when not found; 
  
    if(trim(fsgReceipt.ISSUED_FROM) not in(select loc_type_name from master.loc_type_mapping)) then
            insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select trim(UPPER(fsgReceipt.RECEIVE_FROM_TYPE)),fsgReceipt.ISSUED_FROM,now();
         end if;
        
    if(trim(UPPER(fsgReceipt.RECEIVED_TO)) not in(select loc_type_name from master.loc_type_mapping)) then
      insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'FSG',trim(UPPER(fsgReceipt.RECEIVED_TO)),now();
    end if;
     
    if (fsgReceipt.Plant not in(select plant_name from master.Plant)) then
      insert into master.Plant(plant_name,creation_date) select fsgReceipt.plant,now();
     end if;
  
   if fsgReceipt.RECEIVE_FROM_TYPE = 'GE' then
      if(fsgReceipt.ISSUED_FROM NOT IN(select plant_name from master.plant ) ) then
        insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromGE;
        insert into master.plant(plant_name,address_id,creation_date) values(  fsgReceipt.ISSUED_FROM,addressIssueFromGE,now()) ;
      end if;
      if(fsgReceipt.ISSUED_FROM IN(select plant_name from master.plant ) ) then

        if((select address_id from master.plant where plant_name = fsgReceipt.ISSUED_FROM) IS NULL) then
          insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromGE;
    
        UPDATE master.plant SET creation_date = now(),address_id=addressIssueFromGE  WHERE plant_name = fsgReceipt.ISSUED_FROM;
        end if;
      end if;
   end if;

   if fsgReceipt.RECEIVE_FROM_TYPE = 'FSG' then
    if(fsgReceipt.ISSUED_FROM NOT IN(select fsg_party_name from master.fsg ) ) then
   
      insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromFSG;
        insert into master.fsg(fsg_party_name,address_id,creation_date) select  fsgReceipt.ISSUED_FROM,addressIssueFromFSG,now() ;
        
      end if;
      if (fsgReceipt.ISSUED_FROM IN(select fsg_party_name from master.fsg ) ) then
      if((select address_id from master.fsg where fsg_party_name = fsgReceipt.ISSUED_FROM) IS NULL) then
        insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromFSG;
    
        UPDATE master.fsg SET creation_date = now(),address_id=addressIssueFromFSG  WHERE  fsg_party_name = fsgReceipt.ISSUED_FROM;
      end if;
    end if;
    end if;
   
   if UPPER(fsgReceipt.RECEIVE_FROM_TYPE) = 'CUSTOMER' then
   

    if(fsgReceipt.ISSUED_FROM NOT IN(select customer_name from master.Customer ) ) then
      insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromCust;
      insert into master.Customer(customer_name,address_id,creation_date) select  fsgReceipt.ISSUED_FROM,addressIssueFromCust,now() ;
      
    end if;
    if(fsgReceipt.ISSUED_FROM IN(select customer_name from master.Customer ) ) then
      if((select address_id from master.Customer where customer_name = fsgReceipt.ISSUED_FROM) IS NULL) then
        insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.issued_from_address,fsgReceipt.issued_from_city,fsgReceipt.issued_from_state,fsgReceipt.issued_from_zipcode,fsgReceipt.issued_from_country,now() RETURNING address_id INTO addressIssueFromCust;
    
      UPDATE master.Customer SET creation_date = now(),address_id=addressIssueFromCust  WHERE  customer_name = fsgReceipt.ISSUED_FROM;
      end if;
  
    end if;
  end if;
   
   if(fsgReceipt.RECEIVED_TO not in (select fsg_party_name from master.fsg )) then
  
    insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.received_to_address,fsgReceipt.received_to_city,fsgReceipt.received_to_state,fsgReceipt.received_to_zipcode,fsgReceipt.received_to_country,now() RETURNING address_id INTO addressFSG;
   
    insert into master.fsg(fsg_party_name,address_id,creation_date) select  fsgReceipt.RECEIVED_TO,addressFSG,now() ;
    end if;
    if (fsgReceipt.RECEIVED_TO in (select fsg_party_name from master.fsg )) then

      if((select address_id from master.fsg where fsg_party_name = fsgReceipt.RECEIVED_TO) IS NULL) then
        insert into master.address(street,city,state,zipcode,country,creation_date) select fsgReceipt.received_to_address,fsgReceipt.received_to_city,fsgReceipt.received_to_state,fsgReceipt.received_to_zipcode,fsgReceipt.received_to_country,now() RETURNING address_id INTO addressFSG;
   
        UPDATE master.fsg SET creation_date = now(),address_id=addressFSG  WHERE  fsg_party_name = fsgReceipt.RECEIVED_TO;
      end if;
    end if; 
    
    --if (fsgReceipt.UNIT_OF_MEASURE not in(select name from master.unit_of_measure)) then    
    --  insert into master.unit_of_measure(name,creation_date) select fsgReceipt.UNIT_OF_MEASURE,now() ;
    --  count:=count+1;
    --  end if;
    
    if (fsgReceipt.material IS NOT NULL) then
      if (fsgReceipt.material not in(select material_name from master.material)) then 
    
      insert into master.material(material_name,material_description,creation_date) select  fsgReceipt.material,fsgReceipt.material_description,now();
      count:=count+1; 
      end if;
    end if;
  
  count:=count+1;
  END LOOP;
   close c;
   return count;
   end;
  $$ LANGUAGE plpgsql;
  
  -- insert fsg receipt from staging to validstage
   CREATE OR REPLACE FUNCTION staging.insertvalidfsgrecipttovalidstage() RETURNS integer AS $$ 
                DECLARE
                c cursor  for select * from staging.FSG_RECEIPT_STAGE where is_processed = 'N';
                count integer;
                fsgReceiptRec RECORD;
        V_RECEIVED_TO  character varying (100);
        V_ISSUED_FROM  character varying (100);
		V_LOG TEXT;
                begin
               
                count:=0;
                open c;
                LOOP
                fetch c into fsgReceiptRec;
                exit when not found;
        
        
       if ((upper(fsgReceiptRec.RECEIVE_FROM_TYPE)) = 'CUSTOMER') then
      V_ISSUED_FROM := fsgReceiptRec.ISSUED_FROM;
       else if((upper(fsgReceiptRec.RECEIVE_FROM_TYPE)) = 'FSG') then
      V_ISSUED_FROM := concat('FS',fsgReceiptRec.ISSUED_FROM_STATE);
       else if(fsgReceiptRec.RECEIVE_FROM_TYPE = 'GE') then
      V_ISSUED_FROM := '1PS1';
      end if;
      end if;
      end if;
      
         V_RECEIVED_TO := concat('FS',fsgReceiptRec.RECEIVED_TO_STATE);
     BEGIN
	 
	   V_LOG := (select log from staging.logger where upload_or_run_id=fsgReceiptRec.file_seq_number);
	   
                 insert into validstage.FSG_RECEIPT_VALID_STAGE(FSG_RECEIPT_STAGE_ID,STO,MATERIAL,PLANT,PLANNED_QUANTITY,ACTUAL_QUANTITY,GE_FSG_TRACKING_NUMBER,RECEIPT_DATE,CUSTOMER_PURCHASE_ORDER_NUMBER,FSG_PO,RECEIVE_FROM_TYPE,ISSUED_FROM,RECEIVED_TO,FILE_CURRENT_DATE,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date,fiscal_week,transaction_year) values( nextval('validstage.FSG_RECEIPT_VALID_STAGE_SEQ'), fsgReceiptRec.STO,fsgReceiptRec.MATERIAL,fsgReceiptRec.PLANT,fsgReceiptRec.PLANNED_QUANTITY,fsgReceiptRec.ACTUAL_QUANTITY,fsgReceiptRec.GE_FSG_TRACKING_NUMBER,fsgReceiptRec.RECEIPT_DATE,fsgReceiptRec.CUSTOMER_PURCHASE_ORDER_NUMBER,fsgReceiptRec.FSG_PO,upper(fsgReceiptRec.RECEIVE_FROM_TYPE),V_ISSUED_FROM,V_RECEIVED_TO,fsgReceiptRec.FILE_CURRENT_DATE,fsgReceiptRec.IS_PROCESSED,fsgReceiptRec.FILE_SEQ_NUMBER,now(),(SELECT extract (week from fsgReceiptRec.RECEIPT_DATE)) ,(SELECT extract (year from fsgReceiptRec.RECEIPT_DATE)) );
               
                  count:=count+1;
                 
          UPDATE staging.FSG_RECEIPT_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = fsgReceiptRec.STAGE_SEQ_KEY;
		  EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' '||SQLERRM || ' '||fsgReceiptRec.STAGE_SEQ_KEY where upload_or_run_id=fsgReceiptRec.file_seq_number;
     UPDATE staging.FSG_RECEIPT_STAGE SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = fsgReceiptRec.STAGE_SEQ_KEY;
  end;
   END LOOP;
   close c;
    -- count = analytics.saveupdate_analytics_fsg_receipt();
   return count;
   end;
                $$ LANGUAGE plpgsql;
				
	--
	
  CREATE FUNCTION analytics."get_total_quantity"(additioanlqty numeric, currentqty numeric, type character) RETURNS numeric AS $$ 
DECLARE
totalQty numeric(11,2);
BEGIN
	IF additioanlqty is null then
	additioanlqty=0.00;
    IF type='A' THEN
    IF currentQty is null  THEN
        totalQty=additioanlQty;
      ELSE
      totalQty=additioanlQty+currentQty;   
         END IF;
    ELSE IF type= 'D'THEN
      IF   currentQty is null  THEN 
        totalQty=-(additioanlQty);
      ELSE
      totalQty=currentQty-additioanlQty; 
         END IF;    
    END IF;        
    END IF;
    
    return totalQty;
END
$$ LANGUAGE plpgsql;

 CREATE FUNCTION analytics."saveupdate_analytics_fsg_receipt"() RETURNS integer AS $$     
DECLARE
    fsg_receipt_row RECORD; 
    div_analytic_FSG RECORD;
	div_analytic_CUSTOMER RECORD;
    div_analytic_GE RECORD;
    plant_sap_valid_stage RECORD;
    qty_arrived numeric(11,2);
    sap_qty numeric(11,2);
    sap_status CHAR;
    v_sto numeric;
    
BEGIN  
    For fsg_receipt_row in select FSG_RECEIPT_STAGE_ID,STO,MATERIAL,ISSUED_FROM,
    RECEIVED_TO,CUSTOMER_PURCHASE_ORDER_NUMBER,
    ACTUAL_QUANTITY,PLANT,GE_FSG_TRACKING_NUMBER,
    RECEIVE_FROM_TYPE,RECEIPT_DATE 
    from validstage.fsg_receipt_valid_stage where is_processed='N'
    LOOP
       raise notice 'inside loop';
     BEGIN
	 sap_status := null;
	 
       Select divtrans.transaction_id, divtrans.sto,divtrans.location,divtrans.source,divtrans.source_type,divtrans.shipment_tracking_number,divtrans.in_bound_transit_qty,current_qty into div_analytic_FSG from analytics.div_transaction divtrans 
       where fsg_receipt_row.received_to=divtrans.location 
        and divtrans.location_type='FSG'
        and fsg_receipt_row.issued_from=divtrans.source
        and fsg_receipt_row.material=divtrans.material
        and divtrans.in_bound_transit_qty >0.0 
        and  divtrans.in_bound_transit_qty = fsg_receipt_row.ACTUAL_QUANTITY;
		
		
     
   qty_arrived = fsg_receipt_row.ACTUAL_QUANTITY;        
     IF fsg_receipt_row.RECEIVE_FROM_TYPE='CUSTOMER' THEN       
        IF qty_arrived < 0 THEN
           qty_arrived=-(qty_arrived);
        END IF;   
     END IF;
      
  -- START div_analytic_FSG is null 
    IF div_analytic_FSG is null 
    THEN 
        raise notice 'Insert data for  % %', fsg_receipt_row.RECEIVED_TO, fsg_receipt_row.material;
        
        INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,source,source_type,material,current_qty,shipment_tracking_number,customer_po,created_dtm)
        VALUES(nextval('analytics.div_transaction_seq'),fsg_receipt_row.received_to,'FSG',fsg_receipt_row.sto,fsg_receipt_row.issued_from,fsg_receipt_row.receive_from_type,fsg_receipt_row.material,qty_arrived,fsg_receipt_row.ge_fsg_tracking_number,fsg_receipt_row.customer_purchase_order_number,fsg_receipt_row.receipt_date);     
     ELSE  
     
        raise notice 'Update data for  % %', fsg_receipt_row.RECEIVED_TO, fsg_receipt_row.material;
        UPDATE analytics.div_transaction Set(current_qty)
        =(analytics.get_total_quantity(qty_arrived,div_analytic_FSG.current_qty, 'A'))
        where transaction_id=div_analytic_FSG.transaction_id; 
         
         IF fsg_receipt_row.RECEIVE_FROM_TYPE !='CUSTOMER' THEN
         
       raise notice 'Update inbound data for  % %', fsg_receipt_row.RECEIVED_TO, fsg_receipt_row.material;
        
            UPDATE analytics.div_transaction Set(in_bound_transit_qty)
             =(analytics.get_total_quantity(qty_arrived,div_analytic_FSG.in_bound_transit_qty, 'D'))
              where transaction_id=div_analytic_FSG.transaction_id; 

         END IF; 
    
     END IF; 
       -- END div_analytic_FSG is null 
     
        Select divtrans.transaction_id,divtrans.sto,divtrans.material,divtrans.location,divtrans.destination,divtrans.destination_type,divtrans.shipment_tracking_number,divtrans.out_bound_transit_qty,divtrans.created_dtm into div_analytic_GE from analytics.div_transaction divtrans 
      where fsg_receipt_row.issued_from=divtrans.location 
        and fsg_receipt_row.received_to=divtrans.destination
        and fsg_receipt_row.material=divtrans.material
        and divtrans.destination_type='FSG'
        and divtrans.location_type=fsg_receipt_row.receive_from_type
        and divtrans.out_bound_transit_qty >0.0
       -- and divtrans.out_bound_transit_qty <= fsg_receipt_row.ACTUAL_QUANTITY;
       
       /*and divtrans.shipment_tracking_number=sap_stage_row.pro_number into div_analytic_GE*/
    
	     -- STARTS div_analytic_FSG is null 
    IF div_analytic_GE is null
     THEN 
       IF fsg_receipt_row.RECEIVE_FROM_TYPE ='CUSTOMER' THEN
      
       raise notice 'Insert data for Cusotmer % %', fsg_receipt_row.issued_from, fsg_receipt_row.material;
       INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,destination,destination_type,material,current_qty,shipment_tracking_number,order_status,customer_po,created_dtm)
      VALUES(nextval('analytics.div_transaction_seq'),fsg_receipt_row.issued_from,fsg_receipt_row.receive_from_type,fsg_receipt_row.sto,fsg_receipt_row.received_to,'FSG',fsg_receipt_row.material,(analytics.get_total_quantity(fsg_receipt_row.ACTUAL_QUANTITY,0,'D')),fsg_receipt_row.ge_fsg_tracking_number,'RECEIPT',fsg_receipt_row.customer_purchase_order_number,fsg_receipt_row.receipt_date);     
         
      ELSE IF fsg_receipt_row.RECEIVE_FROM_TYPE ='FSG' THEN
      
       raise notice 'Insert data for  % %', fsg_receipt_row.issued_from, fsg_receipt_row.material;
         INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,destination,destination_type,material,out_bound_transit_qty,shipment_tracking_number,order_status,customer_po,created_dtm)
         VALUES(nextval('analytics.div_transaction_seq'),fsg_receipt_row.issued_from,fsg_receipt_row.receive_from_type,fsg_receipt_row.sto,fsg_receipt_row.received_to,'FSG',fsg_receipt_row.material,-(fsg_receipt_row.ACTUAL_QUANTITY),fsg_receipt_row.ge_fsg_tracking_number,'RECEIPT',fsg_receipt_row.customer_purchase_order_number,fsg_receipt_row.receipt_date);  
       END IF;
                                
	IF fsg_receipt_row.RECEIVE_FROM_TYPE ='GE' THEN
                                
                                
                                /* INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,destination,destination_type,material,current_qty,shipment_tracking_number,order_status,customer_po,created_dtm)
         VALUES(nextval('analytics.div_transaction_seq'),fsg_receipt_row.issued_from,fsg_receipt_row.receive_from_type,fsg_receipt_row.sto,fsg_receipt_row.received_to,'FSG',fsg_receipt_row.material,(fsg_receipt_row.ACTUAL_QUANTITY),fsg_receipt_row.ge_fsg_tracking_number,'RECEIPT',fsg_receipt_row.customer_purchase_order_number,fsg_receipt_row.receipt_date);
                                */
                                insert into validstage.plant_sap_valid_stage (plant_sap_stage_id,sto,material,storage_location,quantity,actual_received,status,is_processed,shipment_crd,creation_date,plant,rec_plant,data_source) values (nextval('validstage.plant_sap_valid_stage_seq'),nextval('validstage.auto_sto_number'),fsg_receipt_row.material,fsg_receipt_row.received_to,fsg_receipt_row.ACTUAL_QUANTITY,fsg_receipt_row.ACTUAL_QUANTITY,'S','P',fsg_receipt_row.receipt_date,now(),'1PS1','1PS1','S');
                                
                                 
 
                                END IF;
        
      END IF;
      ELSE 
    --div_analytic_GE IS NOT NULL
     IF fsg_receipt_row.RECEIVE_FROM_TYPE ='CUSTOMER' THEN
     raise notice 'Update data for  customer % %', fsg_receipt_row.issued_from, fsg_receipt_row.material;
     UPDATE analytics.div_transaction Set (current_qty)
        =(analytics.get_total_quantity(qty_arrived,div_analytic_GE.current_qty,'D'))
        where transaction_id=div_analytic_GE.transaction_id;

     
     ELSE
     raise notice 'Update data for m1  % %', fsg_receipt_row.issued_from, fsg_receipt_row.material;
     UPDATE analytics.div_transaction Set (out_bound_transit_qty)
        =(analytics.get_total_quantity(qty_arrived,div_analytic_GE.out_bound_transit_qty,'D'))
        where transaction_id=div_analytic_GE.transaction_id;
    
    IF fsg_receipt_row.RECEIVE_FROM_TYPE ='GE' THEN
      Select sap.sto, sap.material,sap.storage_location,sap.quantity,sap.shipment_crd into plant_sap_valid_stage from validstage.plant_sap_valid_stage sap 
      where sap.storage_location=div_analytic_GE.destination 
      and sap.material=div_analytic_GE.material
      and sap.shipment_crd=div_analytic_GE.created_dtm
      and sap.sto=div_analytic_GE.sto
    and status is null;
        
          
       IF plant_sap_valid_stage is not null THEN
        sap_qty := plant_sap_valid_stage.quantity - qty_arrived;
        IF (sap_qty = 0.00)THEN
          sap_status ='S';
        ELSE
         sap_status ='T';
        END IF;        
        UPDATE validstage.plant_sap_valid_stage Set actual_received=qty_arrived,status=sap_status      
        where storage_location=div_analytic_GE.destination 
        and material=div_analytic_GE.material
        and shipment_crd=div_analytic_GE.created_dtm
        and sto=div_analytic_GE.sto
    and status is null;
      END IF;
                  
    
    END IF;
     
     END IF;
         END IF;
       
      update  validstage.fsg_receipt_valid_stage set is_processed = 'P'
      where FSG_RECEIPT_STAGE_ID=fsg_receipt_row.FSG_RECEIPT_STAGE_ID;
        
   
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

-- FSG ISSUED

--insert master data from fsg issue
CREATE OR REPLACE FUNCTION staging.insertmasterdatafromfsgissue() RETURNS integer AS $$ 
                DECLARE
                c cursor  for select * from staging.fsg_issued_stage where is_processed = 'N';
                count integer;
                addressCust integer;
                addressFSG integer;
                addressGE integer;
                addressISSUEFSG integer;
                fsgIssued RECORD;
        V_RECEIVED_TO  character varying (100);
        V_ISSUED_FROM  character varying (100);
		vcustomer_desc character varying (100);
                begin
               
                count:=0;
                open c;
                LOOP
                fetch c into fsgIssued;
                exit when not found;
        
         
       if ((upper(fsgIssued.ISSUE_TO_TYPE) = 'CUSTOMER') AND (upper(fsgIssued.CUSTOMER_PURCHASE_ORDER_NUMBER) = 'SAFETY STOCK') )then
		V_RECEIVED_TO := trim(fsgIssued.SHIP_TO_CUSTOMER);
		vcustomer_desc := 'SAFETY STOCK';
	  else if ((upper(fsgIssued.ISSUE_TO_TYPE) = 'CUSTOMER') AND (upper(fsgIssued.CUSTOMER_PURCHASE_ORDER_NUMBER) != 'SAFETY STOCK') ) then
      V_RECEIVED_TO := trim(fsgIssued.CUSTOMER_PURCHASE_ORDER_NUMBER);
	  vcustomer_desc := trim(fsgIssued.CUSTOMER_PURCHASE_ORDER_NUMBER);
       else if(upper(fsgIssued.ISSUE_TO_TYPE) = 'FSG') then
      V_RECEIVED_TO := concat('FS',fsgIssued.RECEIVED_TO_STATE);
       else if(upper(fsgIssued.ISSUE_TO_TYPE) = 'GE') then
      V_RECEIVED_TO := '1PS1';
      end if;
      end if;
	   end if;
      end if;
      
      V_ISSUED_FROM := concat('FS',fsgIssued.ISSUED_FROM_STATE);
      
        if(V_RECEIVED_TO not in(select loc_type_name from master.loc_type_mapping)) then
                                    insert into master.loc_type_mapping(loc_type_name,loc_type,creation_date) select  V_RECEIVED_TO,upper(fsgIssued.ISSUE_TO_TYPE),now() ;
                end if;
        
        if(V_ISSUED_FROM not in(select loc_type_name from master.loc_type_mapping)) then
            insert into master.loc_type_mapping(loc_type_name,loc_type,creation_date) select  V_ISSUED_FROM,'FSG',now() ;
        end if;
          			
				
				              if upper(fsgIssued.ISSUE_TO_TYPE) = 'CUSTOMER' then
                
                    if (V_RECEIVED_TO not in(select customer_name from master.customer)) then
                  
              insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.received_to_address,fsgIssued.received_to_city,fsgIssued.received_to_state,fsgIssued.received_to_zipcode,fsgIssued.received_to_country,now() RETURNING address_id INTO addressCust;
              insert into master.Customer(customer_name,customer_desc,address_id,creation_date) select  V_RECEIVED_TO,vcustomer_desc,addressCust,now() ;       
          end if;
          if (V_RECEIVED_TO in(select customer_name from master.customer)) then
              if((select address_id from master.customer where customer_name = V_RECEIVED_TO) IS NULL) then
                insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.received_to_address,fsgIssued.received_to_city,fsgIssued.received_to_state,fsgIssued.received_to_zipcode,fsgIssued.received_to_country,now() RETURNING address_id INTO addressCust;
                UPDATE master.customer SET creation_date = now(),address_id=addressCust WHERE customer_name =V_RECEIVED_TO;
              end if;
          end if;
                end if;
                
        if upper(fsgIssued.ISSUE_TO_TYPE) = 'FSG' then
        
          
          if (V_RECEIVED_TO not in(select fsg_party_name from master.fsg)) then
                  
            insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.received_to_address,fsgIssued.received_to_city,fsgIssued.received_to_state,fsgIssued.received_to_zipcode,fsgIssued.received_to_country,now() RETURNING address_id INTO addressFSG;
             
            insert into master.fsg(fsg_party_name,address_id,creation_date) select  V_RECEIVED_TO,addressFSG,now() ;
          end if;
          if (V_RECEIVED_TO in(select fsg_party_name from master.fsg)) then

            if((select address_id from master.fsg where fsg_party_name = V_RECEIVED_TO) IS NULL) then
              insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.issued_from_address,fsgIssued.issued_from_city,fsgIssued.issued_from_state,fsgIssued.issued_from_zipcode,fsgIssued.issued_from_country,now() RETURNING address_id INTO addressFSG;
    
              UPDATE master.fsg SET creation_date = now(),address_id=addressFSG  WHERE  fsg_party_name = V_RECEIVED_TO;
            end if;
          end if;
        end if;
                 
                if upper(fsgIssued.ISSUE_TO_TYPE) = 'GE' then
        
        
          if (V_RECEIVED_TO not in(select plant_name from master.plant)) then
                  
            insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.received_to_address,fsgIssued.received_to_city,fsgIssued.received_to_state,fsgIssued.received_to_zipcode,fsgIssued.received_to_country,now() RETURNING address_id INTO addressGE;
                 
            insert into master.plant(plant_name,address_id,creation_date) values(  V_RECEIVED_TO ,addressGE,now()) ;
          end if;            
          if (V_RECEIVED_TO in(select ge_storage_location_name from master.ge_storage_location)) then

            if((select address_id from master.ge_storage_location where ge_storage_location_name = V_RECEIVED_TO ) IS NULL) then
  
              insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.received_to_address,fsgIssued.received_to_city,fsgIssued.received_to_state,fsgIssued.received_to_zipcode,fsgIssued.received_to_country,now() RETURNING address_id INTO addressGE;
                   
              UPDATE master.plant SET creation_date = now(),address_id=addressGE  WHERE plant_name = V_RECEIVED_TO;

            end if;
          end if;
                end if;
                  
                 
                if (fsgIssued.ISSUED_FROM not in(select fsg_party_name from master.fsg)) then
        
          
          
          insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.issued_from_address,fsgIssued.issued_from_city,fsgIssued.issued_from_state,fsgIssued.issued_from_zipcode,fsgIssued.issued_from_country,now() RETURNING address_id INTO addressISSUEFSG;
              
          insert into master.fsg(fsg_party_name,address_id,creation_date) select  fsgIssued.ISSUED_FROM,addressISSUEFSG,now() ;
        end if;  
        if(fsgIssued.ISSUED_FROM in(select fsg_party_name from master.fsg)) then

          if((select address_id from master.fsg where fsg_party_name = fsgIssued.ISSUED_FROM) IS NULL) then
            insert into master.address(street,city,state,zipcode,country,creation_date) select fsgIssued.issued_from_address,fsgIssued.issued_from_city,fsgIssued.issued_from_state,fsgIssued.issued_from_zipcode,fsgIssued.issued_from_country,now() RETURNING address_id INTO addressISSUEFSG;
               
            UPDATE master.fsg SET creation_date = now(),address_id=addressISSUEFSG  WHERE  fsg_party_name = fsgIssued.ISSUED_FROM;
                  
          end if;
                 end if;
                 
          count:=count+1;
   END LOOP;
   close c;
   return count;
   end;
                $$ LANGUAGE plpgsql;
				
	-- insert issue from staging to validstage
	CREATE or replace FUNCTION staging.insertvalidfsgissuedtovalidstage() RETURNS integer AS $$      
            DECLARE
            c cursor  for select * from staging.FSG_ISSUED_STAGE where is_processed = 'N';
            count integer;
            fsgIssuedRec RECORD;
      V_RECEIVED_TO_CUSTOMER  character varying (100);
     V_RECEIVED_TO_FSG  character varying (100);
       V_RECEIVED_TO_GE  character varying (100);
     V_RECEIVED_TO  character varying (100);
    V_ISSUE_TO_TYPE  character varying (100);
      V_ISSUED_FROM  character varying (100);
    V_LOG TEXT;
            begin
           
            count:=0;
            open c;
            LOOP
            fetch c into fsgIssuedRec;
            exit when not found;
           
     V_ISSUE_TO_TYPE :=upper(fsgIssuedRec.ISSUE_TO_TYPE);
       if ((V_ISSUE_TO_TYPE = 'CUSTOMER') AND (upper(fsgIssuedRec.CUSTOMER_PURCHASE_ORDER_NUMBER) = 'SAFETY STOCK') ) then
	   
	  V_RECEIVED_TO_CUSTOMER := trim(fsgIssuedRec.SHIP_TO_CUSTOMER);
	   
      V_RECEIVED_TO := trim(fsgIssuedRec.SHIP_TO_CUSTOMER);
	
	else  
	if ((upper(fsgIssuedRec.ISSUE_TO_TYPE) = 'CUSTOMER') AND (upper(fsgIssuedRec.CUSTOMER_PURCHASE_ORDER_NUMBER) != 'SAFETY STOCK') )then
		 V_RECEIVED_TO_CUSTOMER := trim(fsgIssuedRec.CUSTOMER_PURCHASE_ORDER_NUMBER);
	   
      V_RECEIVED_TO := trim(fsgIssuedRec.CUSTOMER_PURCHASE_ORDER_NUMBER);
       else if(V_ISSUE_TO_TYPE = 'FSG') then
      V_RECEIVED_TO_FSG := concat('FS',fsgIssuedRec.RECEIVED_TO_STATE);
    V_RECEIVED_TO := concat('FS',fsgIssuedRec.RECEIVED_TO_STATE);
       else if(V_ISSUE_TO_TYPE = 'GE') then
      V_RECEIVED_TO_GE := '1PS1';
     V_RECEIVED_TO :=  '1PS1';
      end if;
      end if;
      end if;
      end if;
      V_ISSUED_FROM := concat('FS',upper(fsgIssuedRec.ISSUED_FROM_STATE));
    
     V_LOG := (select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number);
      BEGIN
             insert into validstage.FSG_ISSUED_VALID_STAGE(FSG_ISSUED_STAGE_ID,STO,MATERIAL,QUANTITY_SHIPPED,GE_FSG_TRACKING_NUMBER,SHIP_TO_CUSTOMER,ISSUED_DATE,CUSTOMER_PURCHASE_ORDER_NUMBER,ISSUE_TO_TYPE,ISSUED_FROM,RECEIVED_TO,FILE_CURRENT_DATE,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date,fiscal_week,transaction_year) values( nextval('validstage.FSG_ISSUED_VALID_STAGE_SEQ'),null,trim(fsgIssuedRec.MATERIAL),fsgIssuedRec.QUANTITY_SHIPPED,fsgIssuedRec.GE_FSG_TRACKING_NUMBER,V_RECEIVED_TO_CUSTOMER,fsgIssuedRec.ISSUED_DATE,V_RECEIVED_TO_CUSTOMER,V_ISSUE_TO_TYPE,V_ISSUED_FROM,V_RECEIVED_TO,fsgIssuedRec.FILE_CURRENT_DATE,fsgIssuedRec.IS_PROCESSED,fsgIssuedRec.FILE_SEQ_NUMBER,now(),(SELECT extract (week from fsgIssuedRec.ISSUED_DATE)) ,(SELECT extract (year from fsgIssuedRec.ISSUED_DATE)));
           
              count:=count+1;
        UPDATE staging.FSG_ISSUED_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = fsgIssuedRec.STAGE_SEQ_KEY;
    EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log=  V_LOG || SQLERRM || fsgIssuedRec.STAGE_SEQ_KEY where upload_or_run_id=fsgIssuedRec.file_seq_number;
   UPDATE staging.FSG_ISSUED_STAGE SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = fsgIssuedRec.STAGE_SEQ_KEY;
  end;
   END LOOP;
   close c;
   --count = analytics.saveupdate_analytics_fsg_issue();
   return count;
   end;
            $$ LANGUAGE plpgsql;
				
				--
CREATE FUNCTION analytics."saveupdate_analytics_fsg_issue"() RETURNS integer AS $$   
DECLARE
    fsg_issue_row RECORD; 
    div_analytic_FSG RECORD;
    div_analytic_CUST RECORD;
    
BEGIN 

    FOR fsg_issue_row in select FSG_ISSUED_STAGE_ID,STO,MATERIAL,ISSUED_FROM,RECEIVED_TO,ISSUE_TO_TYPE,CUSTOMER_PURCHASE_ORDER_NUMBER,QUANTITY_SHIPPED,GE_FSG_TRACKING_NUMBER,ISSUED_DATE from validstage.fsg_issued_valid_stage
    where is_processed='N'       
    
    LOOP
          BEGIN   
       Select divtrans.transaction_id, divtrans.location,divtrans.source,divtrans.source_type,divtrans.shipment_tracking_number into div_analytic_CUST from analytics.div_transaction divtrans 
       where fsg_issue_row.received_to=divtrans.location 
        and divtrans.location_type=fsg_issue_row.issue_to_type
        and fsg_issue_row.issued_from=divtrans.source
        and fsg_issue_row.material=divtrans.material;
             
     IF div_analytic_CUST is null
     THEN 
       raise notice 'Insert data for  % %', fsg_issue_row.RECEIVED_TO, fsg_issue_row.material;
       
        INSERT INTO analytics.div_transaction(transaction_id,location,location_type,sto,source,source_type,material,in_bound_transit_qty,shipment_tracking_number,customer_po,created_dtm)
        VALUES(nextval('analytics.div_transaction_seq'),fsg_issue_row.received_to,fsg_issue_row.issue_to_type,fsg_issue_row.sto,fsg_issue_row.issued_from,'FSG',fsg_issue_row.material,fsg_issue_row.quantity_shipped,fsg_issue_row.ge_fsg_tracking_number,fsg_issue_row.customer_purchase_order_number,fsg_issue_row.issued_date);     
     ELSE  
        raise notice 'Update data for  % %', fsg_issue_row.RECEIVED_TO, fsg_issue_row.material;
      
        UPDATE analytics.div_transaction Set(in_bound_transit_qty)
        =(analytics.get_total_quantity(fsg_issue_row.quantity_shipped,in_bound_transit_qty,'A'))
        where transaction_id=div_analytic_CUST.transaction_id; 
            
     END IF; 
     
     
     Select divtrans.transaction_id,divtrans.location,divtrans.destination,divtrans.destination_type,divtrans.shipment_tracking_number into div_analytic_FSG from analytics.div_transaction divtrans 
      where fsg_issue_row.issued_from=divtrans.location 
        and fsg_issue_row.received_to=divtrans.destination
        and fsg_issue_row.material=divtrans.material
        and divtrans.destination_type=fsg_issue_row.issue_to_type
    and divtrans.location_type='FSG'
       
       /*and divtrans.shipment_tracking_number=sap_stage_row.pro_number into div_analytic_GE*/;
    
     IF div_analytic_FSG is null
     THEN 
        raise notice 'Insert data for  % %', fsg_issue_row.issued_from, fsg_issue_row.material;
      
         INSERT INTO analytics.div_transaction(transaction_id,location,location_type,
         sto,destination,destination_type,material,
         current_qty,out_bound_transit_qty,shipment_tracking_number,
         customer_po,created_dtm) 
          VALUES(nextval('analytics.div_transaction_seq'),fsg_issue_row.issued_from,'FSG',
          fsg_issue_row.sto,fsg_issue_row.received_to,fsg_issue_row.issue_to_type,fsg_issue_row.material,
          -(fsg_issue_row.quantity_shipped),
          fsg_issue_row.quantity_shipped,fsg_issue_row.ge_fsg_tracking_number,
          fsg_issue_row.customer_purchase_order_number,fsg_issue_row.issued_date);     
      ELSE         
         raise notice 'Update data for  % %', fsg_issue_row.issued_from, fsg_issue_row.material;
      
        UPDATE analytics.div_transaction Set (out_bound_transit_qty,current_qty)
        =(analytics.get_total_quantity(fsg_issue_row.quantity_shipped,out_bound_transit_qty,  'A'),
      analytics.get_total_quantity(fsg_issue_row.quantity_shipped,current_qty,'D'))
        where transaction_id=div_analytic_FSG.transaction_id; 
       
     END IF; 
      update  validstage.fsg_issued_valid_stage set is_processed = 'Y'
      where FSG_ISSUED_STAGE_ID=fsg_issue_row.FSG_ISSUED_STAGE_ID;
        
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


-- FSG DEMAND
--demand

create or replace function staging.insertMasterDataPlant()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select plant from staging.FSG_DEMAND_STAGE where is_processed = 'N' group by plant;
	count integer;
	addressCustomer integer;
	demandRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into demandRecord;
	exit when not found; 
	if (demandRecord.PLANT IS NOT NULL) then
		if (demandRecord.PLANT not in(select plant_name from master.plant)) then 
		
		 insert into master.plant(plant_name,creation_date) select demandRecord.plant,now() ;
		 count:=count+1; 
		end if;
	  
	  	if(demandRecord.plant not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'GE',demandRecord.plant,now();
		end if;
	end if;
	  count:=count+1; 
	    END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;  

 create or replace function staging.insertMasterDataUoM()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select unit_of_measure from staging.FSG_DEMAND_STAGE where is_processed = 'N' group by unit_of_measure;	
	count integer;
	addressCustomer integer;
	demandRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into demandRecord;
	exit when not found; 
	if (demandRecord.unit_of_measure IS NOT NULL) then
		if (demandRecord.unit_of_measure not in(select name from master.unit_of_measure)) then 
		
		 insert into master.unit_of_measure(name,creation_date) select demandRecord.unit_of_measure,now() ;
		 count:=count+1; 
		end if;
	end if;
	  --count:=count+1; 
	  --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;  
  
   create or replace function staging.insertMasterDataMaterial()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select material, MATERIAL_DESCRIPTION,UNIT_OF_MEASURE from staging.FSG_DEMAND_STAGE where is_processed = 'N' group by material,MATERIAL_DESCRIPTION,UNIT_OF_MEASURE;	
	count integer;
	addressCustomer integer;
	demandRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into demandRecord;
	exit when not found; 
	if (demandRecord.material IS NOT NULL) then
	
		if (demandRecord.material not in(select material_name from master.material)) then 
		
		 insert into master.material(material_name,material_description,creation_date,uom) select  demandRecord.material,demandRecord.material_description,now(),demandRecord.UNIT_OF_MEASURE;
		 count:=count+1; 
		end if;
	end if;
	  --count:=count+1; 
	  --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE; 
  
  
   create or replace function staging.insertMasterDataFSG()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for select storage_location from staging.FSG_DEMAND_STAGE where is_processed = 'N' group by storage_location;
	count integer;
	addressCustomer integer;
	demandRecord RECORD;
	begin
	
	count:=0;
	open c;
	LOOP
	fetch c into demandRecord;
	exit when not found; 
	if (demandRecord.storage_location IS NOT NULL) then
		if (demandRecord.storage_location not in(select fsg_party_name from master.fsg)) then 
		
		 insert into master.fsg(fsg_party_name,is_hub,creation_date) select  demandRecord.storage_location,'Y',now() ;
		 count:=count+1; 
		end if;
	  
	  	if(demandRecord.storage_location not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'FSG',demandRecord.storage_location,now();
		end if;
	end if;
	  count:=count+1; 
	  --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;
  
  
create or replace function staging.insertMasterDataFromDemand() returns void AS $$
   DECLARE
	count integer =0;
	begin
	count=staging.insertMasterDataPlant();
	count=staging.insertMasterDataUoM();
	count=staging.insertMasterDataMaterial();
	count=staging.insertMasterDataFSG();
	end;
   $$ LANGUAGE plpgsql VOLATILE;  	
   
  
  
   --FSG DEMAND from staging to validstage
CREATE OR REPLACE FUNCTION staging.insertvaliddemandtovalidstage() RETURNS integer AS $$  
                DECLARE
          c cursor  for select * from staging.FSG_DEMAND_STAGE where is_processed = 'N' and PLANT='1PS1' and STORAGE_LOCATION IN ('FSIL','FSTX','FSCA');
                count1 integer;
    count2 integer;
	noOfRecords integer;
    fsgDemandRec RECORD;
    V_LOG TEXT;
                begin
				count1:=0;
        noOfRecords := (select count(*) from staging.FSG_DEMAND_STAGE where is_processed = 'N' and PLANT='1PS1' and STORAGE_LOCATION IN ('FSIL','FSTX','FSCA'));
		if(noOfRecords>0) then
		TRUNCATE TABLE validstage.INVENTORY_SP_DEMAND;
         end if;    
				count2:=0;
                open c;				
                LOOP
                fetch c into fsgDemandRec;
                exit when not found;
        
        BEGIN
          
          V_LOG := (select log from staging.logger where upload_or_run_id=fsgDemandRec.file_seq_number limit 1);

                 insert into validstage.INVENTORY_SP_DEMAND(MATERIAL,QUANTITY,PLANT,STORAGE_LOCATION,PROJECT_DEFINITION,REQUIREMENT_DATE,WBS_ELEMENT,NETWORK,ACTIVITY,UNIT_OF_MEASURE,RESERVATION_PURC_REQ,PURCHASE_REQUISITION,REQUISITION_ITEM,PURCHASE_ORD_EXISTS,DELETION_INDICATOR,RESERVATION,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date,fiscal_week,transaction_year) values( fsgDemandRec.MATERIAL,fsgDemandRec.QUANTITY,fsgDemandRec.PLANT,fsgDemandRec.STORAGE_LOCATION,fsgDemandRec.PROJECT_DEFINITION,fsgDemandRec.REQUIREMENT_DATE,fsgDemandRec.WBS_ELEMENT,fsgDemandRec.NETWORK,fsgDemandRec.ACTIVITY,fsgDemandRec.UNIT_OF_MEASURE,fsgDemandRec.RESERVATION_PURC_REQ,fsgDemandRec.PURCHASE_REQUISITION,fsgDemandRec.REQUISITION_ITEM,fsgDemandRec.PURCHASE_ORD_EXISTS,fsgDemandRec.DELETION_INDICATOR,fsgDemandRec.RESERVATION,fsgDemandRec.IS_PROCESSED,fsgDemandRec.FILE_SEQ_NUMBER,now(),(SELECT extract (week from fsgDemandRec.REQUIREMENT_DATE)) ,(SELECT extract (year from fsgDemandRec.REQUIREMENT_DATE)));
             
         count1:=count1+1;
         
           UPDATE staging.FSG_DEMAND_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = fsgDemandRec.STAGE_SEQ_KEY;
        EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' ' || SQLERRM || ' ' || fsgDemandRec.STAGE_SEQ_KEY where upload_or_run_id=fsgDemandRec.file_seq_number;
    UPDATE staging.FSG_DEMAND_STAGE SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = fsgDemandRec.STAGE_SEQ_KEY;
  end; 
                 
   END LOOP;
  
   UPDATE staging.sap_upload SET  IS_PROCESSED = 'Y' where id = fsgDemandRec.FILE_SEQ_NUMBER;
   close c;
    
--TRUNCATE TABLE staging.FSG_DEMAND_STAGE;
   return count1;
   END;
                $$ LANGUAGE plpgsql;
				
				
	--SMART SHEET
	
	--insert master data
	CREATE OR REPLACE FUNCTION staging.insertmasterdatacustomer() RETURNS integer AS $$  
  DECLARE
  c cursor  for select * from staging.CUSTOMER_INSTALL_DEMAND_STAGE where is_processed = 'N';
  count integer;
  addressCustomer integer;
  customerRecord RECORD;
  v_address_id integer;
  begin
  
  count:=0;
  open c;
  LOOP
  fetch c into customerRecord;
  exit when not found; 
  if (customerRecord.CUSTOMER IS NOT NULL) then
    if (customerRecord.CUSTOMER not in(select customer_name from master.customer)) then 
    
    insert into master.address(street,city,state,zipcode,country,creation_date) select customerRecord.STREET,customerRecord.CITY,customerRecord.STATE_REGION,customerRecord.ZIPCODE,'USA',now() RETURNING address_id INTO addressCustomer;

    insert into master.customer(customer_name,customer_code,creation_date,address_id,customer_desc) select  customerRecord.CUSTOMER,customerRecord.CUSTOMER_CODE,now(),addressCustomer,customerRecord.CUSTOMER_NAME;

    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'CUSTOMER',customerRecord.CUSTOMER,now();
  
    
    else if(customerRecord.CUSTOMER in(select customer_name from master.customer) ) then

    v_address_id = (select address_id from master.customer where customer_name = customerRecord.CUSTOMER);

    if (v_address_id is null) then
    insert into master.address(street,city,state,zipcode,country,creation_date) select customerRecord.STREET,customerRecord.CITY,customerRecord.STATE_REGION,customerRecord.ZIPCODE,'USA',now() RETURNING address_id INTO addressCustomer;
    
    update master.customer set creation_date=now(),customer_code=customerRecord.CUSTOMER_CODE,customer_desc=customerRecord.CUSTOMER_NAME,address_id=addressCustomer where customer_name=customerRecord.CUSTOMER;

    else 
      
    update master.address set street=customerRecord.STREET,city=customerRecord.CITY,state=customerRecord.STATE_REGION where address_id=v_address_id;
      
    update master.customer set creation_date=now(),customer_code=customerRecord.CUSTOMER_CODE,customer_desc=customerRecord.CUSTOMER_NAME,address_id=v_address_id where customer_name=customerRecord.CUSTOMER;
    end if;
    end if;
    
    end if;
  end if;
    count:=count+1; 
    --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
   close c;
   return count;
   end;
  $$ LANGUAGE plpgsql;
	
	--Function for inserting into Customer from Plant Sap staging Table
   create or replace function staging.insertMasterDataCustomerFromCustomerDemand()
	returns integer as
	$BODY$
	DECLARE
	c cursor  for   SELECT inventorySpDemand.PROJECT_DEFINITION, customerDemand.customer, customerDemand.customer_code
					FROM staging.CUSTOMER_INSTALL_DEMAND_STAGE customerDemand
					INNER JOIN validstage.inventory_sp_demand inventorySpDemand
					ON 
					customerDemand.PROJECT_DEFINITION=inventorySpDemand.PROJECT_DEFINITION
					group by inventorySpDemand.PROJECT_DEFINITION, customerDemand.customer,customerDemand.customer_code;

	count integer;
	customerDemandRecord RECORD;
	begin
	truncate validstage.CUSTOMER_PROJECT_DEFINITION;
	count:=0;
	open c;
	LOOP
	fetch c into customerDemandRecord;
	exit when not found; 
	insert into validstage.CUSTOMER_PROJECT_DEFINITION(Project,Customer,Ship_To) values (customerDemandRecord.PROJECT_DEFINITION,customerDemandRecord.customer,customerDemandRecord.customer_code);

 
	  count:=count+1; 
   END LOOP;
   close c;
   return count;
   end;
	$BODY$
  LANGUAGE plpgsql VOLATILE;  
  
  --insert smart sheet from staging to validstage

  CREATE OR REPLACE FUNCTION staging.insertmasterprojectdemand() RETURNS integer AS $$   
  DECLARE
  c cursor  for select * from staging.CUSTOMER_INSTALL_DEMAND_STAGE  where is_processed = 'N';

  noOfRows integer;
  count integer;
  customerProjectRecord RECORD;
    V_LOG TEXT;
  begin
   count:=0;
  noOfRows := (select count(*) from staging.CUSTOMER_INSTALL_DEMAND_STAGE  where is_processed = 'N');
   if (noOfRows >0) then 
    truncate validstage.CUSTOMER_INSTALL_DEMAND;
	  end if;
   open c;
  LOOP
  fetch c into customerProjectRecord;
  
  exit when not found; 
    
       
      if (customerProjectRecord.CUSTOMER IS NOT NULL) then
    if (customerProjectRecord.CUSTOMER not in(select customer_name from master.customer)) then 
    insert into master.customer(customer_name,creation_date) select  customerProjectRecord.CUSTOMER,now() ;
    end if;
  
    if(customerProjectRecord.CUSTOMER not in(select loc_type_name from master.loc_type_mapping)) then
                    insert into master.loc_type_mapping(loc_type,loc_type_name,creation_date) select 'CUSTOMER',customerProjectRecord.CUSTOMER,now();
                end if;
    end if;   
  
  BEGIN
      if((SELECT extract (week from customerProjectRecord.INSTALL_DATE) >= (SELECT extract (week from now()))) AND ((SELECT extract (year from customerProjectRecord.INSTALL_DATE))>=(SELECT extract (year from now()))) AND (customerProjectRecord.FSG_ORDER_NUM IS NULL) ) then
	  
	     V_LOG := (select log from staging.logger where upload_or_run_id=customerProjectRecord.file_seq_number limit 1);
            
         insert into validstage.CUSTOMER_INSTALL_DEMAND(Project,Customer,FM_COMPANY,Install_Date,EST_Install_Start,EST_Install_complete,
          IS_PROCESSED,FILE_SEQ_NUMBER,creation_date,FISCAL_WEEK,TRANSACTION_YEAR,FSG_ORDER_NUM) values (customerProjectRecord.project_definition,customerProjectRecord.Customer,customerProjectRecord.FM_COMPANY,customerProjectRecord.Install_Date,
          customerProjectRecord.EST_Install_Start,customerProjectRecord.EST_Install_complete,customerProjectRecord.IS_PROCESSED,customerProjectRecord.FILE_SEQ_NUMBER,now(),
          (SELECT extract (week from customerProjectRecord.INSTALL_DATE)) , (SELECT extract (year from customerProjectRecord.INSTALL_DATE)),customerProjectRecord.FSG_ORDER_NUM);
              
         count:=count+1;
        end if;
        if((SELECT extract (week from customerProjectRecord.INSTALL_DATE) < (SELECT extract (week from now()))) AND ((SELECT extract (year from customerProjectRecord.INSTALL_DATE))>(SELECT extract (year from now()))) AND (customerProjectRecord.FSG_ORDER_NUM IS NULL)) then
                insert into validstage.CUSTOMER_INSTALL_DEMAND(Project,Customer,FM_COMPANY,Install_Date,EST_Install_Start,EST_Install_complete,
          IS_PROCESSED,FILE_SEQ_NUMBER,creation_date,FISCAL_WEEK,TRANSACTION_YEAR,FSG_ORDER_NUM) values (customerProjectRecord.project_definition,customerProjectRecord.Customer,customerProjectRecord.FM_COMPANY,customerProjectRecord.Install_Date,
          customerProjectRecord.EST_Install_Start,customerProjectRecord.EST_Install_complete,customerProjectRecord.IS_PROCESSED,customerProjectRecord.FILE_SEQ_NUMBER,now(),
          (SELECT extract (week from customerProjectRecord.INSTALL_DATE)) , (SELECT extract (year from customerProjectRecord.INSTALL_DATE)),customerProjectRecord.FSG_ORDER_NUM);
              
         count:=count+1;
         
         
      end if;
   UPDATE staging.CUSTOMER_INSTALL_DEMAND_STAGE SET  IS_PROCESSED = 'Y' where CUST_PROJ_DEF_ID = customerProjectRecord.CUST_PROJ_DEF_ID;
 EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' ' || SQLERRM || ' ' || customerProjectRecord.CUST_PROJ_DEF_ID where upload_or_run_id=customerProjectRecord.file_seq_number;
   UPDATE staging.CUSTOMER_INSTALL_DEMAND_STAGE SET  IS_PROCESSED = 'F' where CUST_PROJ_DEF_ID = customerProjectRecord.CUST_PROJ_DEF_ID;
  end;
    
   END LOOP;
   close c;

   return count;
   end;
  $$ LANGUAGE plpgsql;
  
   --install certificate
  --new---
  
  CREATE OR REPLACE FUNCTION analytics."saveupdate_analytics_certificate"() RETURNS integer AS $$  
DECLARE
    fsg_cerficate_row RECORD; 
    certificateRecord RECORD; 
    noOfRows integer;
    count integer;
	
    
		c cursor  for select Material,UNIT_OF_MEASURE from validstage.ASSET_INSTALLED_CERTIFICATE certifcate where is_processed = 'N' group by material,UNIT_OF_MEASURE;	
begin
	open c;
	LOOP
	fetch c into certificateRecord;
	count:=0;
	exit when not found; 
	if (certificateRecord.material IS NOT NULL) then
		if (certificateRecord.material not in(select material_name from master.material)) then 
		
		 insert into master.material(material_name,creation_date,uom) select  certificateRecord.material,now(),certificateRecord.UNIT_OF_MEASURE;
		 count:=count+1; 
		end if;
	end if;
	  --count:=count+1; 
	  --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
  close c; 
BEGIN 

     FOR fsg_cerficate_row in select certifcate.stage_seq_key,certifcate.Material,certifcate.Storage_Location,certifcate.unit_of_measure,
  certifcate.Asset_Installed as AssetInstalled ,installation.Customer,certifcate.posting_date as Install_Date
  from validstage.ASSET_INSTALLED_CERTIFICATE certifcate inner join
  validstage.INVENTORY_SP_DEMAND demand on certifcate.NETWORK=demand.Network and
  certifcate.Material=demand.Material and certifcate.Storage_Location=demand.Storage_Location
  inner Join validstage.customer_project_definition installation on installation.Project=demand.project_definition
  and certifcate.is_processed = 'N'
  Group By certifcate.Network,certifcate.Material,certifcate.Storage_Location,certifcate.unit_of_measure,
  installation.Customer,certifcate.posting_date,certifcate.Asset_Installed,certifcate.stage_seq_key
    LOOP
       BEGIN     
	   
    INSERT INTO analytics.Analytics_Installation(ASSET_INSTALLED_ID,Material,Customer,Storage_Location,
  AssetInstalled,Unit_Measure,Installation_Date,Create_Dtm,is_processed) 
    VALUES(nextval('analytics.Analytics_Installation_SEQ'),fsg_cerficate_row.Material,fsg_cerficate_row.Customer, fsg_cerficate_row.Storage_Location,
  fsg_cerficate_row.AssetInstalled, fsg_cerficate_row.unit_of_measure,fsg_cerficate_row.Install_Date,now(),'N');             
         exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise notice '% %', SQLERRM, SQLSTATE;
		update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'F'
      where STAGE_SEQ_KEY=fsg_cerficate_row.STAGE_SEQ_KEY;
      return 0;  
    END;
	 update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'P'
      where STAGE_SEQ_KEY=fsg_cerficate_row.STAGE_SEQ_KEY;
END LOOP;
	update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'F'
      where is_processed !='P' AND is_processed !='F';
    return 1;
  end;
END;
$$ LANGUAGE plpgsql;

  
  
  
  
  
  
  
  -----------------old--------
  CREATE OR REPLACE FUNCTION analytics."saveupdate_analytics_certificate"() RETURNS integer AS $$  
DECLARE
    fsg_cerficate_row RECORD; 
	certificateRecord RECORD; 
	noOfRows integer;
	  count integer;
	
    
		c cursor  for select Material,UNIT_OF_MEASURE from validstage.ASSET_INSTALLED_CERTIFICATE certifcate where is_processed = 'N' group by material,UNIT_OF_MEASURE;	
begin
	open c;
	LOOP
	fetch c into certificateRecord;
	count:=0;
	exit when not found; 
	if (certificateRecord.material IS NOT NULL) then
		if (certificateRecord.material not in(select material_name from master.material)) then 
		
		 insert into master.material(material_name,creation_date,uom) select  certificateRecord.material,now(),certificateRecord.UNIT_OF_MEASURE;
		 count:=count+1; 
		end if;
	end if;
	  --count:=count+1; 
	  --UPDATE staging.CUSTOMER_SITES_BOM_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = customerRecord.STAGE_SEQ_KEY;
   END LOOP;
   close c;
  end;
BEGIN 

     FOR fsg_cerficate_row in select certifcate.stage_seq_key,certifcate.Material,certifcate.Storage_Location,certifcate.unit_of_measure,
  certifcate.Asset_Installed as AssetInstalled ,installation.Customer,certifcate.posting_date as Install_Date
  from validstage.ASSET_INSTALLED_CERTIFICATE certifcate inner join
  validstage.INVENTORY_SP_DEMAND demand on certifcate.NETWORK=demand.Network and
  certifcate.Material=demand.Material and certifcate.Storage_Location=demand.Storage_Location
  inner Join validstage.customer_project_definition installation on installation.Project=demand.project_definition
  and certifcate.is_processed = 'N'
  Group By certifcate.Network,certifcate.Material,certifcate.Storage_Location,certifcate.unit_of_measure,
  installation.Customer,certifcate.posting_date,certifcate.Asset_Installed,certifcate.stage_seq_key
    LOOP
       BEGIN     
	   
    INSERT INTO analytics.Analytics_Installation(ASSET_INSTALLED_ID,Material,Customer,Storage_Location,
  AssetInstalled,Unit_Measure,Installation_Date,Create_Dtm) 
    VALUES(nextval('analytics.Analytics_Installation_SEQ'),fsg_cerficate_row.Material,fsg_cerficate_row.Customer, fsg_cerficate_row.Storage_Location,
  fsg_cerficate_row.AssetInstalled, fsg_cerficate_row.unit_of_measure,fsg_cerficate_row.Install_Date,now());             
         exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise notice '% %', SQLERRM, SQLSTATE;
		update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'F'
      where STAGE_SEQ_KEY=fsg_cerficate_row.STAGE_SEQ_KEY;
      return 0;  
    END;
	 update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'P'
      where STAGE_SEQ_KEY=fsg_cerficate_row.STAGE_SEQ_KEY;
END LOOP;
	update  validstage.ASSET_INSTALLED_CERTIFICATE set is_processed = 'F'
      where is_processed !='P' AND is_processed !='F';
    return 1;
END;
$$ LANGUAGE plpgsql;

--
CREATE FUNCTION analytics."save_fsg_actual_demand_stock"() RETURNS integer AS $$ 
DECLARE
  demand_stock_row RECORD;
  total_stock Decimal;
  transit_record Decimal;
   stock_record Decimal;
   actualstock Decimal;
  actual_demand Decimal;
  shortage Decimal;
    
BEGIN
    Truncate analytics.FSG_ACTUAL_DEMAND_STOCK;
    FOR demand_stock_row in Select Materialid,customerid,Storage_Location,demand,fiscal_week,year,stock,transit
from analytics.fsg_customer_demand_master_view_ordered  
   
    LOOP


   actual_demand = demand_stock_row.demand;
   transit_record = demand_stock_row.transit;
   stock_record = demand_stock_row.stock;
   
   IF stock_record IS NULL THEN
   stock_record=0;
   END IF;
   IF transit_record IS NULL THEN
   transit_record=0;
   END IF;
      
   total_stock = stock_record+transit_record;

     
    actualstock:=(Select min(actual_stock) from analytics.FSG_ACTUAL_DEMAND_STOCK where Material=demand_stock_row.materialid
   and Storage_Location=demand_stock_row.Storage_Location);
     
   shortage=0;
   IF actualstock IS NULL THEN
      actualstock=total_stock;
   END IF;
   IF actual_demand is NULL THEN 
shortage=null;  
        actualstock=total_stock;
   ELSEIF actual_demand > actualstock THEN
      shortage=greatest(0,(actual_demand-actualstock));
      actualstock=0;    
   ELSEIF actual_demand < actualstock THEN
       actualstock=actualstock-actual_demand;
      shortage=0;
   ELSEIF actual_demand =actualstock THEN
     actualstock=0;
     shortage=0;
   END IF;  
   
        
   Insert Into analytics.FSG_ACTUAL_DEMAND_STOCK(Material,customerid,Storage_Location,demand,fiscal_week,year,stock,transit,actual_stock,shortage)
  VALUES(demand_stock_row.Materialid,demand_stock_row.customerid,demand_stock_row.Storage_Location,demand_stock_row.demand,
  demand_stock_row.fiscal_week,demand_stock_row.year,stock_record,transit_record,actualstock,shortage);             
    
   END LOOP;
   return 1;
    exception when others then
        raise 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise '% %', SQLERRM, SQLSTATE;
  return 0;    

  
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION staging.insertvalidfsgdailystockvalidstage() RETURNS integer AS $$  
                DECLARE
          c cursor  for select material,fsca_com,fsca_bo,fstx_bo,fstx_com,fsil_com,fsil_bo,file_seq_number from staging.FSG_DAILY_STOCK_STAGE where is_processed = 'N' group by material,fsca_com,fsca_bo,fstx_bo,fstx_com,fsil_com,fsil_bo,file_seq_number ;
    count1 integer;
    count2 integer;
	noOfRecords integer;
    fsgDailyStockRec RECORD;
    V_LOG TEXT;
                begin
				count1:=0;
        noOfRecords := (select count(*) from staging.FSG_DAILY_STOCK_STAGE where is_processed = 'N' );
		if(noOfRecords>0) then
		TRUNCATE TABLE validstage.FSG_DAILY_STOCK_VALID_STAGE;
         end if;    
				count2:=0;
                open c;				
                LOOP
                fetch c into fsgDailyStockRec;
                exit when not found;
        
        BEGIN

          V_LOG := (select log from staging.logger where upload_or_run_id=fsgDailyStockRec.file_seq_number limit 1);

                 insert into validstage.FSG_DAILY_STOCK_VALID_STAGE(STORAGE_LOCATION,MATERIAL, COM, BO,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date) values('FSCA',fsgDailyStockRec.MATERIAL, fsgDailyStockRec.fsca_com, fsgDailyStockRec.fsca_bo,'N',fsgDailyStockRec.FILE_SEQ_NUMBER,now());
				 
				insert into validstage.FSG_DAILY_STOCK_VALID_STAGE(STORAGE_LOCATION,MATERIAL, COM, BO,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date) values('FSTX',fsgDailyStockRec.MATERIAL, fsgDailyStockRec.fstx_com, fsgDailyStockRec.fstx_bo,'N',fsgDailyStockRec.FILE_SEQ_NUMBER,now());
					 
					 
			    insert into validstage.FSG_DAILY_STOCK_VALID_STAGE(STORAGE_LOCATION,MATERIAL, COM, BO,IS_PROCESSED,FILE_SEQ_NUMBER,creation_date) values('FSIL',fsgDailyStockRec.MATERIAL, fsgDailyStockRec.fsil_com, fsgDailyStockRec.fsil_bo,'N',fsgDailyStockRec.FILE_SEQ_NUMBER,now());
             
         count1:=count1+1;
         
           UPDATE staging.FSG_DAILY_STOCK_STAGE SET  IS_PROCESSED = 'Y' where material = fsgDailyStockRec.MATERIAL and file_seq_number=fsgDailyStockRec.FILE_SEQ_NUMBER;
        EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=fsgIssuedRec.file_seq_number;
  update staging.logger set log= V_LOG || ' ' || SQLERRM where upload_or_run_id=fsgDailyStockRec.file_seq_number;
    UPDATE staging.FSG_DAILY_STOCK_STAGE SET  IS_PROCESSED = 'F' where material = fsgDailyStockRec.MATERIAL and file_seq_number=fsgDailyStockRec.FILE_SEQ_NUMBER;
  end; 
                 
   END LOOP;
  
  -- UPDATE staging.FSG_DAILY_STOCK_STAGE SET  IS_PROCESSED = 'Y' where id = fsgDailyStockRec.FILE_SEQ_NUMBER;
   close c;
    
--TRUNCATE TABLE staging.FSG_DEMAND_STAGE;
   return count1;
   END;
                $$ LANGUAGE plpgsql;
				
				
	-- 
	
	--FINAL
	
	CREATE OR REPLACE FUNCTION analytics."save_fsg_stock_net_inventory"() RETURNS integer AS $$   
DECLARE
    fsg_stock_net_inventory_row RECORD; 
  noOfRows integer;
  stock_V numeric;
  curr_stock_V numeric;
  received_V numeric;
  yesterdayStock_V numeric;
  stageId_V integer;
    
BEGIN 

  noOfRows := (select count(*) from   validstage.FSG_DAILY_STOCK_VALID_STAGE  where is_processed = 'N');
   if (noOfRows >0) then 
    Truncate analytics.FSG_DAILY_STOCK_NET_INVENTORY;    

     FOR fsg_stock_net_inventory_row in select coalesce(NULLIF(DIV_FSG_STOCK.material,' '),DIV_FSG_STOCK.material_name) as material,coalesce(NULLIF(DIV_FSG_STOCK.storage_location,' '),DIV_FSG_STOCK.fsg_loc) as Storage_Location,coalesce(NULLIF(DIV_FSG_STOCK.curr_stock,0.0),0.0) as curr_stock,coalesce(NULLIF(ISSUED_RECEIVED.received,0.0),0.0) as received,coalesce(NULLIF(ISSUED_RECEIVED.issued,0.0),0.0)as issued,coalesce(NULLIF(DIV_FSG_STOCK.com,0.0),0.0) as com,coalesce(NULLIF(DIV_FSG_STOCK.bo,0.0),0.0)as bo,coalesce(NULLIF((DIV_FSG_STOCK.curr_stock-DIV_FSG_STOCK.com),0),0) as net from
((SELECT material,location AS storage_location,coalesce(SUM(current_qty),0.0) curr_stock 
  FROM analytics.div_transaction WHERE LOCATION_type='FSG' 
  GROUP BY location,material)DIV_TRANSACTION_STOCK
  FULL JOIN
   (SELECT fsg_daily_stock_valid_stage.material as material_name,
    fsg_daily_stock_valid_stage.storage_location as fsg_loc,
  coalesce(SUM(fsg_daily_stock_valid_stage.com ),0.0)AS Com,
    coalesce(SUM(fsg_daily_stock_valid_stage.bo ),0.0) AS bo
   FROM validstage.fsg_daily_stock_valid_stage
   GROUP BY fsg_loc,material_name)FSG_DAILY_STOCK
   on DIV_TRANSACTION_STOCK.storage_location=FSG_DAILY_STOCK.fsg_loc
  and DIV_TRANSACTION_STOCK.material=FSG_DAILY_STOCK.material_name)DIV_FSG_STOCK
   FULL JOIN
   ((select  material as material,received_to as Storage_Location, SUM(COALESCE(actual_quantity,0.0)) AS received from validstage.fsg_receipt_valid_stage WHERE receipt_date >= (SELECT CURRENT_DATE -1) group by material,received_to)RECEIVED_QTY
    FULL JOIN 
(select material as material_name,issued_from as fsg_loc, SUM(COALESCE(quantity_shipped,0.0)) AS issued from validstage.fsg_issued_valid_stage WHERE issued_date >= (SELECT CURRENT_DATE -1) group by material,issued_from) ISSUED_QTY
  on RECEIVED_QTY.Storage_Location=ISSUED_QTY.fsg_loc
  and RECEIVED_QTY.material=ISSUED_QTY.material_name) ISSUED_RECEIVED

  on DIV_FSG_STOCK.fsg_loc=ISSUED_RECEIVED.Storage_Location
  and DIV_FSG_STOCK.material=ISSUED_RECEIVED.material
  and DIV_FSG_STOCK.fsg_loc=ISSUED_RECEIVED.fsg_loc
  and DIV_FSG_STOCK.material=ISSUED_RECEIVED.material_name
    LOOP
       BEGIN  

      received_V := fsg_stock_net_inventory_row.received;
   stock_V := coalesce(NULLIF(fsg_stock_net_inventory_row.curr_stock,0.0),0.0);
   curr_stock_V := coalesce(NULLIF(fsg_stock_net_inventory_row.curr_stock,0.0),0.0);

   --
   -- logic
  
 if(fsg_stock_net_inventory_row.issued >0.0) then
  if(fsg_stock_net_inventory_row.curr_stock=0.0) then
    received_V :=0.0;
    stock_V :=0.0;
    else if (fsg_stock_net_inventory_row.curr_stock !=0.0) then
     yesterdayStock_V := fsg_stock_net_inventory_row.curr_stock +fsg_stock_net_inventory_row.issued -fsg_stock_net_inventory_row.received;
     if(yesterdayStock_V < fsg_stock_net_inventory_row.issued) then
      received_V := yesterdayStock_V +fsg_stock_net_inventory_row.received-fsg_stock_net_inventory_row.issued;
      stock_V :=0.0;
      else if(yesterdayStock_V > fsg_stock_net_inventory_row.issued) then
    
    stock_V := yesterdayStock_V - fsg_stock_net_inventory_row.issued;
      else if(yesterdayStock_V = fsg_stock_net_inventory_row.issued) then
      stock_V :=0.0;
      end if;
     end if;
    end if;
     end if;
     end if;
  else if(fsg_stock_net_inventory_row.issued =0.0) then 
    stock_V := fsg_stock_net_inventory_row.curr_stock-received_V;  
     end if;
     
  end if;
     
  --logic end
   --
   
   if((curr_stock_V-fsg_stock_net_inventory_row.COM)!=fsg_stock_net_inventory_row.NET) then
		--fsg_stock_net_inventory_row.NET:=curr_stock_V-fsg_stock_net_inventory_row.COM;
		
    if(fsg_stock_net_inventory_row.COM is null OR fsg_stock_net_inventory_row.COM=0) then
  fsg_stock_net_inventory_row.COM:=0;
  fsg_stock_net_inventory_row.NET=curr_stock_V;
 
  
  end if;
  end if;
     
    INSERT INTO analytics.FSG_DAILY_STOCK_NET_INVENTORY(fsg_daily_stock_id,Material,Storage_Location,
  curr_STOCK,issued,received,prev_stock,COM,BO,NET,created_dtm) 
    VALUES(nextval('analytics.analytics_fsg_stock_seq'),fsg_stock_net_inventory_row.Material,fsg_stock_net_inventory_row.Storage_Location,
  fsg_stock_net_inventory_row.curr_STOCK,fsg_stock_net_inventory_row.issued,received_V,stock_V, fsg_stock_net_inventory_row.COM,fsg_stock_net_inventory_row.BO,fsg_stock_net_inventory_row.NET,now());   

 stageId_V := (select stage_seq_key from validstage.FSG_DAILY_STOCK_VALID_STAGE where Material=fsg_stock_net_inventory_row.Material and Storage_Location=fsg_stock_net_inventory_row.Storage_Location limit 1);  
         exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise notice '% %', SQLERRM, SQLSTATE;
    update  validstage.fsg_daily_stock_valid_stage set is_processed = 'F'
        where STAGE_SEQ_KEY=stageId_V;
  --return 0;    
    END;
     update  validstage.fsg_daily_stock_valid_stage set is_processed = 'P'
     where STAGE_SEQ_KEY=stageId_V;
  END LOOP;
  update  validstage.fsg_daily_stock_valid_stage set is_processed = 'F'
     where is_processed != 'P' and is_processed != 'F';
     end if;
    return 1;
END;
$$ LANGUAGE plpgsql;




