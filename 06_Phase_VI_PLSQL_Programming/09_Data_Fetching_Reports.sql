-- ============================================================================
-- File: 09_Data_Fetching_Reports.sql
-- Project: Gloria Vehicle Service DB
-- Description: Advanced Data Fetching, Reporting & RefCursor Queries
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_vehicle_reports AS

    -- Types definition for ref cursors
    TYPE ref_cursor IS REF CURSOR;

    -- 1. Fetch Complete Vehicle Service History
    FUNCTION fn_get_vehicle_history (
        p_vin IN VARCHAR2
    ) RETURN ref_cursor;

    -- 2. Fetch Customer Billing & Summary Report
    PROCEDURE sp_get_customer_statement (
        p_customer_id IN NUMBER,
        p_statement_cv OUT ref_cursor
    );

    -- 3. Fetch Service Type Performance & Revenue Analytics
    FUNCTION fn_get_service_performance (
        p_start_date IN DATE DEFAULT TRUNC(SYSDATE, 'MM'),
        p_end_date   IN DATE DEFAULT SYSDATE
    ) RETURN ref_cursor;

    -- 4. Fetch Active Dashboard KPIs (Used for PowerBI / APEX Integration)
    PROCEDURE sp_get_dashboard_kpis (
        p_total_revenue  OUT NUMBER,
        p_completed_jobs OUT NUMBER,
        p_pending_jobs   OUT NUMBER,
        p_active_clients OUT NUMBER
    );

END pkg_vehicle_reports;
/

CREATE OR REPLACE PACKAGE BODY pkg_vehicle_reports AS

    -- ------------------------------------------------------------------------
    -- 1. Fetch Complete Service History for a Specific Vehicle
    -- ------------------------------------------------------------------------
    FUNCTION fn_get_vehicle_history (
        p_vin IN VARCHAR2
    ) RETURN ref_cursor IS
        v_cursor ref_cursor;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                v.vin,
                v.make || ' ' || v.model AS vehicle_name,
                v.plate_number,
                sr.record_id,
                sr.service_date,
                sr.status AS record_status,
                s.service_name,
                sr.actual_cost,
                sr.notes
            FROM VEHICLES v
            JOIN SERVICE_RECORDS sr ON v.vehicle_id = sr.vehicle_id
            JOIN SERVICES s ON sr.service_id = s.service_id
            WHERE v.vin = UPPER(TRIM(p_vin))
            ORDER BY sr.service_date DESC;

        RETURN v_cursor;
    END fn_get_vehicle_history;

    -- ------------------------------------------------------------------------
    -- 2. Fetch Detailed Customer Billing & Statement
    -- ------------------------------------------------------------------------
    PROCEDURE sp_get_customer_statement (
        p_customer_id IN NUMBER,
        p_statement_cv OUT ref_cursor
    ) IS
    BEGIN
        OPEN p_statement_cv FOR
            SELECT 
                c.customer_id,
                c.first_name || ' ' || c.last_name AS customer_name,
                c.email,
                v.plate_number,
                sr.record_id,
                sr.service_date,
                s.service_name,
                sr.status,
                sr.actual_cost AS amount_billed
            FROM CUSTOMERS c
            JOIN VEHICLES v ON c.customer_id = v.customer_id
            JOIN SERVICE_RECORDS sr ON v.vehicle_id = sr.vehicle_id
            JOIN SERVICES s ON sr.service_id = s.service_id
            WHERE c.customer_id = p_customer_id
            ORDER BY sr.service_date DESC;
    END sp_get_customer_statement;

    -- ------------------------------------------------------------------------
    -- 3. Analytics: Service Type Demand & Revenue Generation
    -- ------------------------------------------------------------------------
    FUNCTION fn_get_service_performance (
        p_start_date IN DATE DEFAULT TRUNC(SYSDATE, 'MM'),
        p_end_date   IN DATE DEFAULT SYSDATE
    ) RETURN ref_cursor IS
        v_cursor ref_cursor;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                s.service_id,
                s.service_name,
                s.standard_cost,
                COUNT(sr.record_id) AS total_jobs_completed,
                NVL(SUM(sr.actual_cost), 0) AS total_revenue_generated,
                NVL(ROUND(AVG(sr.actual_cost), 2), 0) AS avg_revenue_per_job
            FROM SERVICES s
            LEFT JOIN SERVICE_RECORDS sr 
                   ON s.service_id = sr.service_id 
                  AND sr.status = 'COMPLETED'
                  AND sr.service_date BETWEEN p_start_date AND p_end_date
            GROUP BY s.service_id, s.service_name, s.standard_cost
            ORDER BY total_revenue_generated DESC;

        RETURN v_cursor;
    END fn_get_service_performance;

    -- ------------------------------------------------------------------------
    -- 4. Executive Dashboard Analytics (KPIs)
    -- ------------------------------------------------------------------------
    PROCEDURE sp_get_dashboard_kpis (
        p_total_revenue  OUT NUMBER,
        p_completed_jobs OUT NUMBER,
        p_pending_jobs   OUT NUMBER,
        p_active_clients OUT NUMBER
    ) IS
    BEGIN
        -- Calculate total revenue from completed service records
        SELECT NVL(SUM(actual_cost), 0)
        INTO p_total_revenue
        FROM SERVICE_RECORDS
        WHERE status = 'COMPLETED';

        -- Calculate total completed jobs
        SELECT COUNT(*)
        INTO p_completed_jobs
        FROM SERVICE_RECORDS
        WHERE status = 'COMPLETED';

        -- Calculate pending / in-progress jobs
        SELECT COUNT(*)
        INTO p_pending_jobs
        FROM SERVICE_RECORDS
        WHERE status IN ('PENDING', 'IN_PROGRESS');

        -- Calculate active distinct customers served
        SELECT COUNT(DISTINCT v.customer_id)
        INTO p_active_clients
        FROM VEHICLES v
        JOIN SERVICE_RECORDS sr ON v.vehicle_id = sr.vehicle_id;

    END sp_get_dashboard_kpis;

END pkg_vehicle_reports;
/