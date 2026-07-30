-- ============================================================================
-- File: 03_Insert_Sample_Data.sql
-- Description: DML script populating all tables with coherent sample data.
-- ============================================================================

-- 1. Populate Customers
INSERT INTO CUSTOMERS (customer_id, first_name, last_name, email, phone) 
VALUES (seq_customers_id.NEXTVAL, 'Gloria', 'Mugisha', 'gloria.m@example.com', '+250788112233');

INSERT INTO CUSTOMERS (customer_id, first_name, last_name, email, phone) 
VALUES (seq_customers_id.NEXTVAL, 'Jean', 'Paul', 'jp.biz@corp.rw', '+250788223344');

INSERT INTO CUSTOMERS (customer_id, first_name, last_name, email, phone) 
VALUES (seq_customers_id.NEXTVAL, 'Alice', 'Umutoni', 'alice.u@example.com', '+250788334455');


-- 2. Populate Vehicles
INSERT INTO VEHICLES (vehicle_id, customer_id, vin, make, model, year, plate_number) 
VALUES (seq_vehicles_id.NEXTVAL, 1, '1HGCR2F83HA123456', 'Toyota', 'RAV4', 2021, 'RAB123A');

INSERT INTO VEHICLES (vehicle_id, customer_id, vin, make, model, year, plate_number) 
VALUES (seq_vehicles_id.NEXTVAL, 2, '3FA6P0H78HR654321', 'Ford', 'Ranger', 2022, 'RAC456B');

INSERT INTO VEHICLES (vehicle_id, customer_id, vin, make, model, year, plate_number) 
VALUES (seq_vehicles_id.NEXTVAL, 3, 'JM1BL1H82C1789012', 'Mazda', 'CX-5', 2019, 'RAD789C');


-- 3. Populate Services Catalog
INSERT INTO SERVICES (service_id, service_name, description, standard_cost) 
VALUES (seq_services_id.NEXTVAL, 'Full Engine Oil & Filter Change', 'Includes engine oil replacement and filter check', 50.00);

INSERT INTO SERVICES (service_id, service_name, description, standard_cost) 
VALUES (seq_services_id.NEXTVAL, 'Brake Pad & Rotor Replacement', 'Front and rear brake system overhaul', 120.00);

INSERT INTO SERVICES (service_id, service_name, description, standard_cost) 
VALUES (seq_services_id.NEXTVAL, 'Full System Electrical Diagnostics', 'Complete OBD2 diagnostic scan and wiring check', 80.00);


-- 4. Populate Service Records
INSERT INTO SERVICE_RECORDS (record_id, vehicle_id, service_id, service_date, actual_cost, status, notes) 
VALUES (seq_service_records_id.NEXTVAL, 1, 1, SYSDATE - 2, 80.00, 'COMPLETED', 'Routine oil maintenance completed');

INSERT INTO SERVICE_RECORDS (record_id, vehicle_id, service_id, service_date, actual_cost, status, notes) 
VALUES (seq_service_records_id.NEXTVAL, 2, 2, SYSDATE - 1, 237.50, 'IN_PROGRESS', 'Front brakes squeaking; parts replaced');

INSERT INTO SERVICE_RECORDS (record_id, vehicle_id, service_id, service_date, actual_cost, status, notes) 
VALUES (seq_service_records_id.NEXTVAL, 3, 3, SYSDATE + 1, 80.00, 'PENDING', 'Check engine light diagnostic scheduled');


-- 5. Populate Public Holidays
INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name) 
VALUES (seq_holidays_id.NEXTVAL, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 'New Year''s Day');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name) 
VALUES (seq_holidays_id.NEXTVAL, TO_DATE('2026-02-01', 'YYYY-MM-DD'), 'National Heroes Day');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name) 
VALUES (seq_holidays_id.NEXTVAL, TO_DATE('2026-07-04', 'YYYY-MM-DD'), 'Liberation Day');

COMMIT;