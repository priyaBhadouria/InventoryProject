------FSG Trend FSG Issued and FSG Received graphs View Starts-----------

DROP SEQUENCE IF EXISTS validstage.fsg_issued_trend_details_view_seq; 
CREATE SEQUENCE validstage.fsg_issued_trend_details_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_issued_trend_details_view;
CREATE materialized VIEW validstage.fsg_issued_trend_details_view AS
SELECT nextval('validstage.fsg_issued_trend_details_view_seq'::regclass) AS id,Sum(quantity_shipped) AS all_quantity, T2.issued_date, T2.quantity AS FSG_QUANTITY, T2.location AS FSG FROM validstage.fsg_issued_valid_stage T1 INNER JOIN (SELECT nextval('validstage.fsg_issued_trend_details_view_seq'::regclass) AS id,Sum(quantity_shipped) AS quantity, issued_date,issued_from AS location FROM validstage.fsg_issued_valid_stage
GROUP BY issued_date,issued_from) T2 ON T1.issued_date = T2.issued_date
GROUP BY T2.issued_date,T2.quantity,T2.location;

DROP SEQUENCE IF EXISTS validstage.fsg_receipt_trend_details_view_seq; 
CREATE SEQUENCE validstage.fsg_receipt_trend_details_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_receipt_trend_details_view;
CREATE materialized VIEW validstage.fsg_receipt_trend_details_view AS
SELECT nextval('validstage.fsg_receipt_trend_details_view_seq'::regclass) AS id,Sum(actual_quantity) AS all_received_quantity, T2.receipt_date, T2.quantity AS FSG_received_QUANTITY, T2.location AS FSG FROM validstage.fsg_receipt_valid_stage T1 INNER JOIN (SELECT nextval('validstage.fsg_issued_trend_details_view_seq'::regclass) AS id,Sum(actual_quantity) AS quantity, receipt_date,received_to AS location FROM validstage.fsg_receipt_valid_stage where receipt_date > (select min(receipt_date) from validstage.fsg_receipt_valid_stage)
GROUP BY receipt_date,received_to) T2 ON T1.receipt_date= T2.receipt_date
GROUP BY T2.receipt_date,T2.quantity,T2.location;

------FSG Trend FSG Issued and FSG Received graphs View ends-----------





------FSG Trend FSG Issued and FSG Received Drill down View Starts-----------

DROP SEQUENCE IF EXISTS validstage.fsg_issued_valid_stage_drilldown_view_seq;
CREATE SEQUENCE validstage.fsg_issued_valid_stage_drilldown_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_issued_valid_stage_drilldown_view; 
CREATE materialized VIEW validstage.fsg_issued_valid_stage_drilldown_view AS
SELECT nextval('validstage.fsg_issued_valid_stage_drilldown_view_seq'::regclass) AS id, T1.material, material_description, T1.issued_date, SUM(COALESCE(quantity_shipped,0)) AS FSGISSUED, T2.Quantity AS FSGRECEIVED FROM validstage.fsg_issued_valid_stage T1 FULL OUTER JOIN (SELECT Sum(COALESCE(actual_quantity,0))AS Quantity, receipt_date,material FROM validstage.fsg_receipt_valid_stage
GROUP BY receipt_date,material) T2 ON T1.material=T2.material  AND T1.issued_date=T2.receipt_date INNER JOIN master.material T3 ON T1.material=T3.material_name GROUP BY T1.material,T1.issued_date,material_description,T2.Quantity;

DROP SEQUENCE IF EXISTS validstage.fsg_issued_valid_stage_drilldown_loc_view_seq;
CREATE SEQUENCE validstage.fsg_issued_valid_stage_drilldown_loc_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_issued_valid_stage_drilldown_loc_view; 
CREATE materialized VIEW validstage.fsg_issued_valid_stage_drilldown_loc_view AS
SELECT nextval('validstage.fsg_issued_valid_stage_drilldown_loc_view_seq'::regclass) AS id, T1.material, material_description, T1.issued_date,T1.issued_from, SUM(COALESCE(quantity_shipped,0)) AS FSGISSUED, T2.Quantity AS FSGRECEIVED FROM validstage.fsg_issued_valid_stage T1 FULL OUTER JOIN (SELECT Sum(actual_quantity) AS Quantity, receipt_date,received_to,material FROM validstage.fsg_receipt_valid_stage
GROUP BY receipt_date,received_to,material) T2 ON T1.material=T2.material AND T1.issued_from=T2.received_to AND T1.issued_date=T2.receipt_date INNER JOIN master.material T3 ON T1.material=T3.material_name GROUP BY T1.material,T1.issued_date,material_description,T2.Quantity,T1.issued_from;

------FSG Trend FSG Issued and FSG Received Drill down View ends-----------


------FSG Trend FSG Issued and FSG Received pop up drill down views starts----

DROP SEQUENCE IF EXISTS validstage.fsg_trend_valid_stage_fsg_view_seq;
CREATE SEQUENCE validstage.fsg_trend_valid_stage_fsg_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.fsg_trend_valid_stage_fsg_view; 
CREATE materialized VIEW validstage.fsg_trend_valid_stage_fsg_view AS
SELECT nextval('validstage.fsg_trend_valid_stage_fsg_view_seq'::regclass) AS id, T1.material, T1.issued_date,T2.received_to AS fsg_received_loc,T1.issued_from AS fsg_issued_loc, SUM(COALESCE(quantity_shipped,0)) AS fsg_issued, T2.Quantity AS fsg_received FROM validstage.fsg_issued_valid_stage T1 FULL OUTER JOIN (SELECT Sum(actual_quantity)AS Quantity, receipt_date,received_to,material FROM validstage.fsg_receipt_valid_stage
GROUP BY receipt_date,received_to,material) T2 ON T1.material=T2.material AND T1.issued_date=T2.receipt_date INNER JOIN master.material T3 ON T1.material=T3.material_name GROUP BY T1.material,T1.issued_date,T2.Quantity,T2.received_to,T1.issued_from;

--------FSG Trend FSG Issued and FSG Received pop up drill down views ends-------------


------Customer Trend Customer Consumption and Customer Returns Graphs views starts-----------

DROP SEQUENCE IF EXISTS analytics.customer_consumption_trend_view_seq; 
CREATE SEQUENCE analytics.customer_consumption_trend_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumption_trend_view;
CREATE materialized VIEW analytics.customer_consumption_trend_view AS
SELECT nextval('analytics.customer_consumption_trend_view_seq '::regclass) AS Id, SUM(COALESCE(assetinstalled,0)) AS all_consumed_qty, A2.consumed_qty AS customer_consumed_qty, A1.installation_date, A2.customer_site_id FROM analytics.analytics_installation A1 LEFT OUTER JOIN (SELECT nextval('analytics.customer_consumption_trend_view_seq '::regclass) AS Id, SUM(COALESCE(assetinstalled,0)) AS consumed_qty, installation_date,customer AS customer_site_id FROM analytics.analytics_installation GROUP BY installation_date,customer_site_id) A2 ON A1.installation_date = A2.installation_date GROUP BY A1.installation_date, A2.customer_site_id,A2.consumed_qty;

DROP SEQUENCE IF EXISTS validstage.customer_return_trend_view_seq; 
CREATE SEQUENCE validstage.customer_return_trend_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS validstage.customer_return_trend_view;
CREATE materialized VIEW validstage.customer_return_trend_view AS
SELECT nextval('validstage.customer_return_trend_view_seq'::regclass) AS Id,
SUM(COALESCE(actual_quantity,0)) AS all_returned_qty, receipt_date AS return_date, T2.returned_qty AS site_returned_qty, T2.customer_site_id FROM validstage.FSG_RECEIPT_VALID_STAGE T1  LEFT OUTER JOIN (SELECT nextval('validstage.customer_return_trend_view_seq'::regclass) AS Id,
SUM(COALESCE(actual_quantity,0)) AS returned_qty, receipt_date AS return_date,received_to AS customer_site_id FROM validstage.FSG_RECEIPT_VALID_STAGE WHERE receive_from_type='CUSTOMER' GROUP BY return_date,customer_site_id) T2  ON return_date=T2.return_date WHERE receive_from_type='CUSTOMER' GROUP BY T1.receipt_date,T2.returned_qty, T2.customer_site_id;

------Customer Trend Customer Consumption and Customer Returns Graphs views ends-----------

------Customer Trend Customer Consumption and Customer Returns drill down views starts-----------

DROP SEQUENCE IF EXISTS analytics.customer_consumption_trend_drilldown_view_seq;
CREATE SEQUENCE analytics.customer_consumption_trend_drilldown_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumption_trend_drilldown_view; 
CREATE materialized VIEW analytics.customer_consumption_trend_drilldown_view AS
SELECT nextval('analytics.customer_consumption_trend_drilldown_view_seq'::regclass) AS id, T1.material, material_description, T1.installation_date, SUM(COALESCE(assetinstalled,0)) AS customer_Consumption, T2.returned_qty AS Customer_Returns FROM analytics.analytics_installation T1 FULL OUTER JOIN (SELECT Sum(actual_quantity)AS returned_qty, receipt_date AS return_date,material FROM validstage.fsg_receipt_valid_stage
WHERE receive_from_type='CUSTOMER' GROUP BY receipt_date,material) T2 ON T1.material=T2.material AND T1.installation_date=T2.return_date INNER JOIN master.material T3 ON T1.material=T3.material_name GROUP BY T1.material,T1.installation_date,material_description,T2.returned_qty;

DROP SEQUENCE IF EXISTS analytics.customer_consumption_trend_drilldown_loc_view_seq;
CREATE SEQUENCE analytics.customer_consumption_trend_drilldown_loc_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumption_trend_loc_drilldown_view; 
CREATE materialized VIEW analytics.customer_consumption_trend_loc_drilldown_view AS
SELECT nextval('analytics.customer_consumption_trend_drilldown_loc_view_seq'::regclass) AS id, T1.material, material_description, T1.installation_date,T1.customer, SUM(COALESCE(assetinstalled,0)) AS customer_Consumption, T2.returned_qty AS Customer_Returns FROM analytics.analytics_installation T1 FULL OUTER JOIN (SELECT Sum(actual_quantity)AS returned_qty, receipt_date AS return_date,material FROM validstage.fsg_receipt_valid_stage
WHERE receive_from_type='CUSTOMER' GROUP BY receipt_date,material) T2 ON T1.material=T2.material AND T1.installation_date=T2.return_date INNER JOIN master.material T3 ON T1.material=T3.material_name GROUP BY T1.material,T1.installation_date,material_description,T2.returned_qty,T1.customer;

------Customer Trend Customer Consumption and Customer Returns drill down views ends-----------

-------- Customer Trend Customer Consumption and Customer Returns pop up drill down views starts -------

DROP SEQUENCE IF EXISTS analytics.customer_consumption_trend_popup_view_seq;
CREATE SEQUENCE analytics.customer_consumption_trend_popup_view_seq INCREMENT 1   MINVALUE 1   MAXVALUE 9223372036854775807   START 1   CACHE 1   NO CYCLE;

DROP MATERIALIZED VIEW IF EXISTS analytics.customer_consumption_trend_popup_view; 
CREATE materialized VIEW analytics.customer_consumption_trend_popup_view AS
SELECT nextval('analytics.customer_consumption_trend_popup_view_seq'::regclass) AS id, T1.customer, T1.material, customer_desc,T1.installation_date, SUM(COALESCE(assetinstalled,0)) AS customer_Consumption,T1.storage_location, T2.returned_qty AS Customer_Return,T2.received_to FROM analytics.analytics_installation T1 FULL OUTER JOIN (SELECT Sum(actual_quantity)AS returned_qty, receipt_date AS return_date,received_to,material FROM validstage.fsg_receipt_valid_stage T2
WHERE receive_from_type='CUSTOMER' GROUP BY receipt_date,material,received_to) T2 ON T1.material=T2.material AND T1.installation_date=T2.return_date INNER JOIN master.customer T3 ON T1.customer=T3.customer_name GROUP BY T1.customer,T1.installation_date,customer_desc,T2.returned_qty,T2.received_to,T1.storage_location,T1.material;

--------Customer Trend Customer Consumption and Customer Returns pop up drill down views ends -------

