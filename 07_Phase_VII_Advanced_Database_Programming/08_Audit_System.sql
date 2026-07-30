-- ============================================================================
-- File: 08_Audit_System.sql
-- Description: System-wide auditing infrastructure for DML tracking.
-- ============================================================================

-- 1. Create Audit Table Structure Safely (Skip if already exists)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'AUDIT_LOGS';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE AUDIT_LOGS (
                audit_id         NUMBER PRIMARY KEY,
                table_name       VARCHAR2(50)   NOT NULL,
                operation        VARCHAR2(20)   NOT NULL,
                db_user          VARCHAR2(100)  DEFAULT USER,
                action_timestamp TIMESTAMP      DEFAULT SYSTIMESTAMP,
                details          VARCHAR2(4000)
            )';
        DBMS_OUTPUT.PUT_LINE('Table AUDIT_LOGS created successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table AUDIT_LOGS already exists. Skipping creation.');
    END IF;
END;
/

-- 2. Create Sequence Safely (Skip if already exists)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_sequences WHERE sequence_name = 'SEQ_AUDIT_ID';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1 NOCACHE';
        DBMS_OUTPUT.PUT_LINE('Sequence SEQ_AUDIT_ID created successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sequence SEQ_AUDIT_ID already exists. Skipping creation.');
    END IF;
END;
/


-- 3. Audit Trigger for CUSTOMERS Table Modifications
CREATE OR REPLACE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE ON CUSTOMERS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_details   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_details   := 'New Customer Registered | ID: ' || :NEW.customer_id || ', Name: ' || :NEW.first_name || ' ' || :NEW.last_name || ', Email: ' || :NEW.email;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_details   := 'Updated Customer ID #' || :NEW.customer_id || ' | Email: (' || :OLD.email || ' -> ' || :NEW.email || '), Phone: (' || :OLD.phone || ' -> ' || :NEW.phone || ')';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_details   := 'Deleted Customer ID #' || :OLD.customer_id || ' | Name: ' || :OLD.first_name || ' ' || :OLD.last_name;
    END IF;

    INSERT INTO AUDIT_LOGS (
        audit_id,
        table_name,
        operation,
        db_user,
        action_timestamp,
        details
    ) VALUES (
        seq_audit_id.NEXTVAL,
        'CUSTOMERS',
        v_operation,
        USER,
        SYSTIMESTAMP,
        v_details
    );
END trg_audit_customers;
/


-- 4. Audit Trigger for VEHICLES Table Modifications
CREATE OR REPLACE TRIGGER trg_audit_vehicles
AFTER INSERT OR UPDATE OR DELETE ON VEHICLES
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_details   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_details   := 'New Vehicle Registered | ID: ' || :NEW.vehicle_id || ', VIN: ' || :NEW.vin || ', Plate: ' || :NEW.plate_number || ' (Owner ID: ' || :NEW.customer_id || ')';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_details   := 'Updated Vehicle ID #' || :NEW.vehicle_id || ' | VIN: ' || :NEW.vin || ', Plate: (' || :OLD.plate_number || ' -> ' || :NEW.plate_number || '), Owner ID: (' || :OLD.customer_id || ' -> ' || :NEW.customer_id || ')';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_details   := 'Deleted Vehicle ID #' || :OLD.vehicle_id || ' | VIN: ' || :OLD.vin || ', Plate: ' || :OLD.plate_number;
    END IF;

    INSERT INTO AUDIT_LOGS (
        audit_id,
        table_name,
        operation,
        db_user,
        action_timestamp,
        details
    ) VALUES (
        seq_audit_id.NEXTVAL,
        'VEHICLES',
        v_operation,
        USER,
        SYSTIMESTAMP,
        v_details
    );
END trg_audit_vehicles;
/