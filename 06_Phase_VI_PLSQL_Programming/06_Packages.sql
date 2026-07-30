-- ============================================================================
-- File: 06_Packages.sql
-- Description: Package specification and body for Core Vehicle Operations.
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_vehicle_service AS

    -- Registers a customer and their vehicle atomically in one transaction
    PROCEDURE register_new_customer (
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_phone      IN VARCHAR2,
        p_vin        IN VARCHAR2,
        p_make       IN VARCHAR2,
        p_model      IN VARCHAR2,
        p_year       IN NUMBER,
        p_plate      IN VARCHAR2
    );

    -- Schedules a service record for a vehicle based on the services catalog
    PROCEDURE create_service_record (
        p_vehicle_id   IN NUMBER,
        p_service_id   IN NUMBER,
        p_service_date IN DATE DEFAULT SYSDATE,
        p_actual_cost  IN NUMBER DEFAULT NULL,
        p_notes        IN VARCHAR2 DEFAULT NULL
    );

END pkg_vehicle_service;
/

CREATE OR REPLACE PACKAGE BODY pkg_vehicle_service AS

    PROCEDURE register_new_customer (
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_phone      IN VARCHAR2,
        p_vin        IN VARCHAR2,
        p_make       IN VARCHAR2,
        p_model      IN VARCHAR2,
        p_year       IN NUMBER,
        p_plate      IN VARCHAR2
    ) IS
        v_customer_id NUMBER;
    BEGIN
        -- Generate customer ID via sequence and insert record
        v_customer_id := seq_customers_id.NEXTVAL;

        INSERT INTO CUSTOMERS (customer_id, first_name, last_name, email, phone)
        VALUES (v_customer_id, p_first_name, p_last_name, p_email, p_phone);

        -- Insert vehicle referencing the generated customer_id
        INSERT INTO VEHICLES (vehicle_id, customer_id, vin, make, model, year, plate_number)
        VALUES (seq_vehicles_id.NEXTVAL, v_customer_id, p_vin, p_make, p_model, p_year, p_plate);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Successfully registered customer ID ' || v_customer_id || ' with vehicle ' || p_plate);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END register_new_customer;


    PROCEDURE create_service_record (
        p_vehicle_id   IN NUMBER,
        p_service_id   IN NUMBER,
        p_service_date IN DATE DEFAULT SYSDATE,
        p_actual_cost  IN NUMBER DEFAULT NULL,
        p_notes        IN VARCHAR2 DEFAULT NULL
    ) IS
        v_cost NUMBER;
    BEGIN
        -- If actual_cost is not explicitly passed, pull standard_cost from SERVICES catalog
        IF p_actual_cost IS NULL THEN
            SELECT standard_cost INTO v_cost
            FROM SERVICES
            WHERE service_id = p_service_id;
        ELSE
            v_cost := p_actual_cost;
        END IF;

        -- Create transaction record in SERVICE_RECORDS
        INSERT INTO SERVICE_RECORDS (
            record_id,
            vehicle_id,
            service_id,
            service_date,
            actual_cost,
            status,
            notes
        ) VALUES (
            seq_service_records_id.NEXTVAL,
            p_vehicle_id,
            p_service_id,
            p_service_date,
            v_cost,
            'PENDING',
            p_notes
        );

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Service record created successfully for vehicle ID ' || p_vehicle_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Service ID ' || p_service_id || ' does not exist in catalog.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_service_record;

END pkg_vehicle_service;
/