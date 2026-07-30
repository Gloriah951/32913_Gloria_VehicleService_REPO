-- ============================================================================
-- File: 04_Functions.sql
-- Description: Standalone PL/SQL business calculation functions.
-- ============================================================================

-- Function 1: Get Total Actual Cost for a Service Record
CREATE OR REPLACE FUNCTION fn_get_record_cost (
    p_record_id IN NUMBER
) RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(actual_cost, 0)
    INTO v_total
    FROM SERVICE_RECORDS
    WHERE record_id = p_record_id;
    
    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_record_cost;
/

-- Function 2: Check if a Vehicle is already scheduled on a given date
CREATE OR REPLACE FUNCTION fn_is_vehicle_scheduled (
    p_vehicle_id IN NUMBER,
    p_date       IN DATE
) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM SERVICE_RECORDS
    WHERE vehicle_id = p_vehicle_id
      AND TRUNC(service_date) = TRUNC(p_date)
      AND status IN ('PENDING', 'IN_PROGRESS');
      
    RETURN (v_count = 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END fn_is_vehicle_scheduled;
/

-- Function 3: Check if a given date is a Public Holiday
CREATE OR REPLACE FUNCTION fn_is_public_holiday (
    p_date IN DATE
) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM HOLIDAYS
    WHERE TRUNC(holiday_date) = TRUNC(p_date);
    
    RETURN (v_count > 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END fn_is_public_holiday;
/