-- ============================================================================
-- File: 01_PDB_And_User_Setup.sql
-- Description: Creates Pluggable Database (PDB) and Schema User
-- Note: Must be executed as SYS or a user with SYSDBA privileges.
-- ============================================================================

-- 1. Create Pluggable Database (PDB)
CREATE PLUGGABLE DATABASE vehicle_service_pdb
    ADMIN USER pdb_admin IDENTIFIED BY "AdminPass123!"
    ROLES = (DBA)
    DEFAULT TABLESPACE USERS
    DATAFILE SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- 2. Open the newly created PDB
ALTER PLUGGABLE DATABASE vehicle_service_pdb OPEN READ WRITE;

-- 3. Save the PDB state so it automatically opens on database restart
ALTER PLUGGABLE DATABASE vehicle_service_pdb SAVE STATE;

-- 4. Switch session context to the new PDB
ALTER SESSION SET CONTAINER = vehicle_service_pdb;


-- 5. Drop user if already exists (for clean re-runs)
BEGIN
   EXECUTE IMMEDIATE 'DROP USER "32913_GLORIA_VEHICLESERVICE_DB" CASCADE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1918 THEN
         RAISE;
      END IF;
END;
/

-- 6. Create schema user (Uppercase identifier)
CREATE USER "32913_GLORIA_VEHICLESERVICE_DB" IDENTIFIED BY "SecurePass123!"
   DEFAULT TABLESPACE USERS
   TEMPORARY TABLESPACE TEMP
   QUOTA UNLIMITED ON USERS;

-- 7. Assign privileges required for PL/SQL, tables, views, sequences, and triggers
GRANT CONNECT, RESOURCE TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE SESSION TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE TABLE TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE VIEW TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE SEQUENCE TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE PROCEDURE TO "32913_GLORIA_VEHICLESERVICE_DB";
GRANT CREATE TRIGGER TO "32913_GLORIA_VEHICLESERVICE_DB";

COMMIT;