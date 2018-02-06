CREATE or replace FUNCTION staging.insertinstallerReceivedtovalidstage() RETURNS integer AS $$      
            DECLARE
            c cursor  for select * from staging.installer_received_stage where is_processed = 'N';
		V_LOG text;	
            count integer;
			installerRec record;
			
            begin
           
            count:=0;
            open c;
            LOOP
            fetch c into installerRec;
            exit when not found;
  
     V_LOG := (select log from staging.logger where upload_or_run_id=installerRec.file_seq_number);
      BEGIN
	 
             insert into validstage.installer_received_valid_stage(stage_seq_key,CHR_STATUS,CHR_ORDER_NUMBER,ORIGIN_PICKUP_NAME,ORIGIN_PICKUP_ADDRESS_1,ORIGIN_PICKUP_CITY,ORIGIN_PICKUP_STATE,DESTINATION_DELIVERY_NAME,DESTINATION_DELIVERY_ADDRESS_1,DESTINATION_DELIVERY_STATE,ACTUAL_PICK_UP_ARRIVAL_DATE,ACTUAL_DELIVERY_ARRIVAL_DATE,PAYER_REFERENCE_NUMBER,CUSTOMER_REFERENCE_NUMBER,ORIGIN_BOL,ORIGIN_PU,ORIGIN_REFNUM,DESTINATION_DEL,DESTINATION_MBOL,DESTINATION_REFNUM,CHR_NUMBER,ACTUAL_PALLETS,ACTUAL_WEIGHT,TRANSPORTATION_MODE,CARRIER_PRO_NUMBER,DESTINATION_SPECIAL_INSTRUCTIONS,IS_VALID,IS_PROCESSED,FILE_SEQ_NUMBER,CREATION_DATE) 
			 values( nextval('validstage.installer_received_valid_stage_seq'),installerRec.CHR_STATUS,installerRec.CHR_ORDER_NUMBER,installerRec.ORIGIN_PICKUP_NAME,installerRec.ORIGIN_PICKUP_ADDRESS_1,installerRec.ORIGIN_PICKUP_CITY,installerRec.ORIGIN_PICKUP_STATE,installerRec.DESTINATION_DELIVERY_NAME,installerRec.DESTINATION_DELIVERY_ADDRESS_1,installerRec.DESTINATION_DELIVERY_STATE,installerRec.ACTUAL_PICK_UP_ARRIVAL_DATE,installerRec.ACTUAL_DELIVERY_ARRIVAL_DATE,installerRec.PAYER_REFERENCE_NUMBER,installerRec.CUSTOMER_REFERENCE_NUMBER,installerRec.ORIGIN_BOL,installerRec.ORIGIN_PU,installerRec.ORIGIN_REFNUM,installerRec.DESTINATION_DEL,installerRec.DESTINATION_MBOL,installerRec.DESTINATION_REFNUM,installerRec.CHR_NUMBER,installerRec.ACTUAL_PALLETS,installerRec.ACTUAL_WEIGHT,installerRec.TRANSPORTATION_MODE,installerRec.CARRIER_PRO_NUMBER,installerRec.DESTINATION_SPECIAL_INSTRUCTIONS,'N',installerRec.IS_PROCESSED,installerRec.FILE_SEQ_NUMBER,now());
           
              count:=count+1;
        UPDATE staging.INSTALLER_RECEIVED_STAGE SET  IS_PROCESSED = 'Y' where STAGE_SEQ_KEY = installerRec.STAGE_SEQ_KEY;
    EXCEPTION
  when others then
    raise notice 'The transaction is in an uncommittable state.';
                 
        raise notice '% %', SQLERRM, SQLSTATE;
    -- select log from staging.logger where upload_or_run_id=installerRec.file_seq_number;
  update staging.logger set log=  V_LOG || SQLERRM || installerRec.STAGE_SEQ_KEY where upload_or_run_id=installerRec.file_seq_number;
   UPDATE staging.INSTALLER_RECEIVED_STAGE SET  IS_PROCESSED = 'F' where STAGE_SEQ_KEY = installerRec.STAGE_SEQ_KEY;
  end;
   END LOOP;
   close c;
   --count = analytics.saveupdate_analytics_fsg_issue();
   return count;
   end;
            $$ LANGUAGE plpgsql;
				
				--
				
				
				
CREATE OR REPLACE FUNCTION analytics."saveupdate_analytics_installer_stage"() RETURNS integer AS $$   
DECLARE
	
		count integer;
			count1 integer;
		installer_received_row RECORD; 
	   
		div_analytic_installer RECORD;
		div_analytic_fsg RECORD;
            V_ISSUED_FROM  character varying (100);
			
           		  
BEGIN 
		count:=0;
		

	   FOR installer_received_row in select * from validstage.installer_received_valid_stage where is_processed='N'
    LOOP
	count1:=0;
	 
		BEGIN  
		raise notice 'The transaction is in an uncommittable state. '
                 'Begin loop';
		Select divtrans.transaction_id, 
		divtrans.location,divtrans.source,
		divtrans.source_type,divtrans.shipment_tracking_number,
		coalesce(divtrans.in_bound_transit_qty,0.0),coalesce(current_qty,0.0) into div_analytic_installer from analytics.div_transaction divtrans where divtrans.location_type='CUSTOMER' and divtrans.shipment_tracking_number=installer_received_row.CHR_NUMBER;
		raise notice 'The transaction is in an uncommittable state. '
                 'Begin loop %',div_analytic_installer;
		IF div_analytic_installer is not null THEN 
			
				   raise notice 'The transaction is in an uncommittable state. '
                 'Customer IF';
				
				 UPDATE analytics.div_transaction set current_qty=(analytics.get_total_quantity(in_bound_transit_qty,current_qty,'A')) , in_bound_transit_qty=0  where shipment_tracking_number=installer_received_row.CHR_NUMBER and location_type='CUSTOMER'; 
					
				count1 :=count1+1;	
     END IF; 
		
		Select divtrans.transaction_id, 
	divtrans.location,
		coalesce(divtrans.out_bound_transit_qty,0.0),coalesce(current_qty,0.0) into div_analytic_fsg from analytics.div_transaction divtrans where divtrans.location_type='FSG' and divtrans.shipment_tracking_number=installer_received_row.CHR_NUMBER;
		
		raise notice 'The transaction is in an uncommittable state. '
                 'Begin loop FSG %',div_analytic_fsg;
		IF div_analytic_fsg is not null	THEN 
	
				   raise notice 'The transaction is in an uncommittable state. '
                 'FSG IF';
				  
				 UPDATE analytics.div_transaction set out_bound_transit_qty=0 ,current_qty=0
					where shipment_tracking_number=installer_received_row.CHR_NUMBER and location_type='FSG'; 
		count1 :=count1+1;
	-- END IF; 
      END IF; 
	  if(count1=2)then
	  
	    raise notice 'The transaction is in an uncommittable state. '
                 'Count IF';
				  
   UPDATE validstage.installer_received_valid_stage set IS_VALID='Y',is_processed = 'Y' where CHR_NUMBER=installer_received_row.CHR_NUMBER;
     end if;
	 
     -- update  validstage.installer_received_valid_stage set is_processed = 'Y'
    --  where stage_seq_key=installer_received_row.stage_seq_key;
        
    exception when others then 
        raise notice 'The transaction is in an uncommittable state. '
                 'Transaction was rolled back';
        raise notice '% %', SQLERRM, SQLSTATE;
		 update  validstage.installer_received_valid_stage set is_processed = 'N'
      where stage_seq_key=installer_received_row.stage_seq_key;
     return 0;
   END;
  END LOOP;
  return 1;   
      
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE SEQUENCE analytics.installer_received_details_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;
DROP MATERIALIZED VIEW IF EXISTS analytics.installer_received_details_view;
CREATE MATERIALIZED VIEW analytics.installer_received_details_view AS
(Select nextval('analytics.installer_received_details_view_seq'::regclass) AS id,
                T4.material AS material, COALESCE(T4.current_qty,0) AS quantity, COALESCE(T4.current_qty * T2.cost,0) AS amount, T2.uom AS unit_of_measure,
                T4.location AS customer_name, T3.chr_number AS chr_number,  T3.origin_pickup_name, T3.origin_pickup_address_1, 
T3.origin_pickup_city, T3.origin_pickup_state, T3.destination_delivery_name, T3.destination_delivery_address_1, T3.destination_delivery_state, T3.actual_pick_up_arrival_date, T3.actual_delivery_arrival_date               
                FROM  master.material T2, validstage.installer_received_valid_stage T3, analytics.div_transaction T4
                WHERE T4.material=T2.material_name and        T4.shipment_tracking_number=T3.chr_number and  T4.location_type='CUSTOMER' group by material,quantity,amount,unit_of_measure,customer_name,chr_number,origin_pickup_name,origin_pickup_address_1,
                origin_pickup_city,origin_pickup_state,destination_delivery_name,destination_delivery_address_1,destination_delivery_state,actual_pick_up_arrival_date,actual_delivery_arrival_date);



