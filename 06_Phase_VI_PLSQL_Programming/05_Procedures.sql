-- ============================================================================
-- File: 05_Procedures.sql
-- Description: Standalone PL/SQL procedures with transaction management.
-- ============================================================================

-- Procedure 1: Complete a service record and recalculate final bill
CREATE OR REPLACE PROCEDURE sp_complete_service_record (
    p_record_id IN NUMBER
) IS
    v_total NUMBER;
    v_status VARCHAR2(20);
BEGIN
    -- Verify service record existence and status
    SELECT status INTO v_status 
    FROM SERVICE_RECORDS 
    WHERE record_id = p_record_id;
    
    IF v_status = 'COMPLETED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Service record is already marked as completed.');
    ELSIF v_status = 'CANCELLED' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot complete a cancelled service record.');
    END IF;

    -- Calculate total bill using standalone function
    v_total := fn_get_record_cost(p_record_id);

    -- Update Service Record status and final cost
    UPDATE SERVICE_RECORDS
    SET status = 'COMPLETED',
        actual_cost = v_total
    WHERE record_id = p_record_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Service Record #' || p_record_id || ' completed successfully. Total: $' || v_total);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Service Record ID not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_complete_service_record;
/

-- Procedure 2: Schedule a new service record with holiday check validation
CREATE OR REPLACE PROCEDURE sp_create_service_record (
    p_vehicle_id   IN NUMBER,
    p_service_id   IN NUMBER,
    p_service_date IN DATE,
    p_actual_cost  IN NUMBER,
    p_notes        IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
    -- Business Validation: Block scheduling on public holidays
    IF fn_is_public_holiday(p_service_date) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cannot schedule service on a public holiday.');
    END IF;

    -- Insert new service record using sequence
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
        p_actual_cost,
        'PENDING',
        p_notes
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Service Record successfully scheduled for date: ' || TO_CHAR(p_service_date, 'YYYY-MM-DD'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_create_service_record;
/