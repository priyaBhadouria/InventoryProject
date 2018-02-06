---- ********************* Inactive Stocks db script start ***************************---------------

DROP SEQUENCE IF EXISTS validstage.inactive_stock_details_view_seq;
CREATE SEQUENCE validstage.inactive_stock_details_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;


DROP MATERIALIZED VIEW IF EXISTS validstage.inactive_stock_details_view;
CREATE materialized VIEW validstage.inactive_stock_details_view AS
SELECT nextval('validstage.inactive_stock_details_view_seq'::regclass) AS id, T4.material, T6.material_description, SUM(COALESCE(T5.current_qty,0)) AS quantity, T6.uom AS unit_of_measure, T6.cost, SUM(COALESCE(T5.current_qty * T6.cost,0)) AS material_cost, T4.received_to AS fsg, T4.inactive_days FROM (SELECT material,received_to,MAX(inactive_days) AS inactive_days FROM (SELECT T1.material,T1.received_to, T1.receipt_date, date_part('day', (now() - T1.receipt_date)) AS inactive_days, 'Not Issued' AS stock_type FROM validstage.fsg_receipt_valid_stage T1 WHERE NOT EXISTS(SELECT * FROM validstage.fsg_issued_valid_stage T2 WHERE T1.material=T2.material AND T1.received_to=T2.issued_from) UNION ALL  
SELECT T1.material,T1.received_to, T1.receipt_date, date_part('day', (now() - issued_date)) AS inactive_days, ' After Issued' AS stock_type FROM validstage.fsg_receipt_valid_stage T1 INNER JOIN (SELECT material, issued_from,Max(issued_date) AS issued_date FROM validstage.fsg_issued_valid_stage GROUP BY material,issued_from) T2 ON T1.material=T2.material AND T1.received_to=T2.issued_from AND T1.receipt_date>issued_date)T3 GROUP BY material,received_to)T4 INNER JOIN analytics.div_transaction T5 ON T4.material=T5.material AND T4.received_to=T5.location INNER JOIN master.material T6 ON T4.material=T6.material_name GROUP BY T4.material, T6.material_description, T6.uom, T6.cost, T4.received_to, T4.inactive_days;

CREATE OR REPLACE FUNCTION validstage.inactive_stock_ratio(
 OUT days_11_to_20 DECIMAL, 
 OUT days_21_to_30 DECIMAL, 
 OUT days_31_to_60 DECIMAL, 
 OUT days_60_plus DECIMAL 
) AS $$
BEGIN
	
   days_11_to_20 := COALESCE((SELECT SUM(material_cost) FROM validstage.inactive_stock_details_view inactive,master.material mm WHERE inactive_days>10 AND inactive_days<=20 AND inactive.material=mm.material_name),0); 	
   days_21_to_30 := COALESCE((SELECT SUM(material_cost) FROM validstage.inactive_stock_details_view inactive,master.material mm WHERE inactive_days>20 AND inactive_days<=30 and inactive.material=mm.material_name),0);
   days_31_to_60 := COALESCE((SELECT SUM(material_cost) FROM validstage.inactive_stock_details_view inactive,master.material mm WHERE inactive_days>30 AND inactive_days<=60 and inactive.material=mm.material_name),0);
   days_60_plus := COALESCE((SELECT SUM(material_cost) FROM validstage.inactive_stock_details_view inactive,master.material mm WHERE inactive_days>60 and inactive.material=mm.material_name),0);   

END;
$$ LANGUAGE plpgsql;

DROP MATERIALIZED VIEW IF EXISTS validstage.inactive_stock_ratio_view;
CREATE materialized VIEW validstage.inactive_stock_ratio_view AS 
SELECT * FROM validstage.inactive_stock_ratio();

---- ********************* Inactive Stocks db script end ***************************---------------