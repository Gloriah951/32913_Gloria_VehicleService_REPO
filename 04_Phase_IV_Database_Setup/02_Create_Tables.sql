-- Connect as user: "32913_Gloria_VehicleService_DB"

-- Drop existing tables to ensure a clean execution
DROP TABLE AUDIT_LOGS CASCADE CONSTRAINTS;
DROP TABLE SERVICE_RECORDS CASCADE CONSTRAINTS;
DROP TABLE HOLIDAYS CASCADE CONSTRAINTS;
DROP TABLE SERVICES CASCADE CONSTRAINTS;
DROP TABLE VEHICLES CASCADE CONSTRAINTS;
DROP TABLE CUSTOMERS CASCADE CONSTRAINTS;

-- 1. Customers Table
CREATE TABLE CUSTOMERS (
    customer_id     NUMBER(10)          NOT NULL,
    first_name      VARCHAR2(50)        NOT NULL,
    last_name       VARCHAR2(50)        NOT NULL,
    email           VARCHAR2(100)       NOT NULL,
    phone           VARCHAR2(20)        NOT NULL,
    created_at      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

-- 2. Vehicles Table
CREATE TABLE VEHICLES (
    vehicle_id      NUMBER(10)          NOT NULL,
    customer_id     NUMBER(10)          NOT NULL,
    vin             VARCHAR2(17)        NOT NULL,
    make            VARCHAR2(50)        NOT NULL,
    model           VARCHAR2(50)        NOT NULL,
    year            NUMBER(4)           NOT NULL,
    plate_number    VARCHAR2(15)        NOT NULL,
    CONSTRAINT pk_vehicles PRIMARY KEY (vehicle_id),
    CONSTRAINT uq_vehicle_vin UNIQUE (vin),
    CONSTRAINT uq_vehicle_plate UNIQUE (plate_number),
    CONSTRAINT fk_vehicles_customers FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE,
    CONSTRAINT chk_vehicle_year CHECK (year >= 1990 AND year <= 2030)
);

-- 3. Services Catalog Table
CREATE TABLE SERVICES (
    service_id      NUMBER(10)          NOT NULL,
    service_name    VARCHAR2(100)       NOT NULL,
    description     VARCHAR2(255),
    standard_cost   NUMBER(10, 2)       NOT NULL,
    CONSTRAINT pk_services PRIMARY KEY (service_id),
    CONSTRAINT chk_service_cost CHECK (standard_cost >= 0)
);

-- 4. Service Records Transaction Table
CREATE TABLE SERVICE_RECORDS (
    record_id       NUMBER(10)          NOT NULL,
    vehicle_id      NUMBER(10)          NOT NULL,
    service_id      NUMBER(10)          NOT NULL,
    service_date    DATE DEFAULT SYSDATE NOT NULL,
    actual_cost     NUMBER(10, 2)       NOT NULL,
    status          VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    notes           VARCHAR2(500),
    CONSTRAINT pk_service_records PRIMARY KEY (record_id),
    CONSTRAINT fk_sr_vehicles FOREIGN KEY (vehicle_id) 
        REFERENCES VEHICLES(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT fk_sr_services FOREIGN KEY (service_id) 
        REFERENCES SERVICES(service_id),
    CONSTRAINT chk_sr_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_sr_cost CHECK (actual_cost >= 0)
);

-- 5. Public Holidays Reference Table
CREATE TABLE HOLIDAYS (
    holiday_id      NUMBER(10)          NOT NULL,
    holiday_date    DATE                NOT NULL,
    holiday_name    VARCHAR2(100)       NOT NULL,
    CONSTRAINT pk_holidays PRIMARY KEY (holiday_id),
    CONSTRAINT uq_holiday_date UNIQUE (holiday_date)
);

-- 6. Audit System Table
CREATE TABLE AUDIT_LOGS (
    audit_id        NUMBER(10)          NOT NULL,
    table_name      VARCHAR2(50)        NOT NULL,
    operation       VARCHAR2(20)        NOT NULL,
    db_user         VARCHAR2(50)        NOT NULL,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    details         VARCHAR2(4000),
    CONSTRAINT pk_audit_logs PRIMARY KEY (audit_id)
);

-- Sequences for Primary Keys
CREATE SEQUENCE seq_customers_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_vehicles_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_services_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_service_records_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_holidays_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1;