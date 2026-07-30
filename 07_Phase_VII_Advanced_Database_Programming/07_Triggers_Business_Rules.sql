-- ============================================================================
-- File: 07_Triggers_Business_Rules.sql
-- Description: Enforces business logic and populates audit logs automatically.
-- ============================================================================

-- Trigger 1: Restrict service bookings on weekends (Saturday / Sunday)
CREATE OR REPLACE TRIGGER trg_restrict_weekend_booking
BEFORE INSERT OR UPDATE OF service_date ON SERVICE_RECORDS
FOR EACH ROW
DECLARE
    v_day_of_week VARCHAR2(10);
BEGIN
    -- Evaluate day abbreviation natively without querying DUAL
    v_day_of_week := UPPER(TO_CHAR(:NEW.service_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH'));

    IF v_day_of_week IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20005, 'Services cannot be scheduled on weekends (Saturday/Sunday).');
    END IF;
END trg_restrict_weekend_booking;
/


-- Trigger 2: Restrict service bookings on registered public holidays
CREATE OR REPLACE TRIGGER trg_restrict_holiday_booking
BEFORE INSERT OR UPDATE OF service_date ON SERVICE_RECORDS
FOR EACH ROW
DECLARE
    v_holiday_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_holiday_count
    FROM HOLIDAYS
    WHERE TRUNC(holiday_date) = TRUNC(:NEW.service_date);

    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Services cannot be scheduled on a registered public holiday.');
    END IF;
END trg_restrict_holiday_booking;
/


-- Trigger 3: Automatic Audit Logging on SERVICE_RECORDS changes
CREATE OR REPLACE TRIGGER trg_audit_service_records
AFTER INSERT OR UPDATE OR DELETE ON SERVICE_RECORDS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_details   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_details   := 'New Service Record #' || :NEW.record_id || ' created for Vehicle ID ' || :NEW.vehicle_id || ' (Cost: $' || :NEW.actual_cost || ')';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_details   := 'Record #' || :NEW.record_id || ' updated. Status: ' || :OLD.status || ' -> ' || :NEW.status || '; Cost: $' || :OLD.actual_cost || ' -> $' || :NEW.actual_cost;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_details   := 'Deleted Service Record #' || :OLD.record_id || ' (Vehicle ID ' || :OLD.vehicle_id || ')';
    END IF;

    -- Record audit trace into AUDIT_LOGS using sequence
    INSERT INTO AUDIT_LOGS (
        audit_id,
        table_name,
        operation,
        db_user,
        action_timestamp,
        details
    ) VALUES (
        seq_audit_id.NEXTVAL,
        'SERVICE_RECORDS',
        v_operation,
        USER,
        SYSTIMESTAMP,
        v_details
    );
END trg_audit_service_records;
/