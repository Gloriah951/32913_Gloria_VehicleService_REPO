# 32913_Gloria_VehicleService_REPO# Vehicle Services and Repair Management System

## Overview

The **Vehicle Services and Repair Management System** is a database-driven application designed to simplify the management of vehicle servicing, repair operations, customer records, and maintenance history. The system helps service centers efficiently manage daily operations while maintaining accurate records of vehicles, customers, technicians, and repair services.

This project demonstrates the application of software engineering principles, database design, SQL, and PL/SQL programming in building a real-world management system.

---

## Project Objectives

The main objectives of this project are to:

* Manage customer and vehicle information.
* Record vehicle service and repair requests.
* Track repair progress and service history.
* Manage technicians assigned to repair jobs.
* Generate maintenance records for each vehicle.
* Improve data accuracy and reduce manual record keeping.

---

## Features

* Customer Registration and Management
* Vehicle Registration
* Service Request Management
* Repair Record Management
* Technician Assignment
* Service History Tracking
* Maintenance Records
* SQL Reports and Queries
* PL/SQL Stored Procedures
* PL/SQL Functions
* Database Triggers
* Views for Reporting

---

# System Architecture

```
Customer
    │
    ▼
Vehicle
    │
    ▼
Service Request
    │
    ▼
Repair Record
    │
    ▼
Technician
    │
    ▼
Maintenance History
```

---

# Database Design

The system consists of several related tables, including:

| Table          | Description                       |
| -------------- | --------------------------------- |
| Customers      | Stores customer information       |
| Vehicles       | Stores registered vehicle details |
| Technicians    | Stores technician information     |
| Services       | Stores available service types    |
| Repair_Records | Stores repair details             |
| Appointments   | Stores service appointments       |
| Payments       | Stores payment information        |

---

# Technologies Used

## Database

* Oracle Database
* SQL
* PL/SQL

## Development Tools

* Oracle SQL Developer
* SQL*Plus

## Concepts Applied

* Relational Database Design
* Primary Keys
* Foreign Keys
* Constraints
* Joins
* Views
* Indexes
* Stored Procedures
* Functions
* Triggers
* Exception Handling

---

# Entity Relationship Diagram


![ER Diagram](images/ERD.png)

---

# Database Schema

Insert your relational schema image here.

![Database Schema](images/schema.png)

---

# Application Screenshots

## Login

![Login Screen](images/login.png)

---

## Dashboard

![Dashboard](images/dashboard.png)

---

## Customer Management

![Customer Module](images/customers.png)

---

## Vehicle Registration

![Vehicle Registration](images/vehicles.png)

---

## Repair Management

![Repair Management](images/repairs.png)

---

## Reports

![Reports](images/reports.png)

---

# Sample SQL Operations

### Create Table

```sql
CREATE TABLE Customers (
    Customer_ID NUMBER PRIMARY KEY,
    Full_Name VARCHAR2(100),
    Phone VARCHAR2(20),
    Email VARCHAR2(100)
);
```

### Retrieve All Vehicles

```sql
SELECT *
FROM Vehicles;
```

### Retrieve Customer Vehicles

```sql
SELECT c.Full_Name,
       v.Vehicle_Model
FROM Customers c
JOIN Vehicles v
ON c.Customer_ID = v.Customer_ID;
```

---

# PL/SQL Features

The project includes:

* Stored Procedures
* User-Defined Functions
* Database Triggers
* Exception Handling
* Cursors
* Packages (if implemented)

Example procedure:

```sql
EXEC UpdateVehicleService(101);
```

---

# Project Structure

```
Vehicle-Service-and-Repair-Management-System/
│
├── database/
│   ├── tables.sql
│   ├── constraints.sql
│   ├── inserts.sql
│   ├── views.sql
│   ├── procedures.sql
│   ├── functions.sql
│   ├── triggers.sql
│   └── packages.sql
│
├── images/
│   ├── ERD.png
│   ├── schema.png
│   ├── login.png
│   ├── dashboard.png
│   ├── customers.png
│   ├── vehicles.png
│   ├── repairs.png
│   └── reports.png
│
├── documentation/
│   └── Project_Report.pdf
│
└── README.md
```

---

# Installation

1. Clone the repository.

```bash
git clone https://github.com/your-username/Vehicle-Service-and-Repair-Management-System.git
```

2. Open Oracle SQL Developer.

3. Create a new Oracle connection.

4. Execute the SQL scripts in the following order:

* `tables.sql`
* `constraints.sql`
* `inserts.sql`
* `views.sql`
* `procedures.sql`
* `functions.sql`
* `triggers.sql`

---

# Future Improvements

* Online appointment booking
* SMS or email service reminders
* Inventory and spare parts management
* Billing and invoice generation
* Administrator dashboard
* Analytics and reporting
* Mobile application integration

---

# Learning Outcomes

Through this project, the following concepts were implemented:

* Database normalization
* SQL programming
* Advanced SQL queries
* PL/SQL programming
* Oracle database administration
* Database security
* Data integrity
* Business logic implementation

---

# Author

**INEZA MUGISHA Gloria**

Software Engineering Student

GitHub: https://github.com/your-username

---

# License

This project is developed for academic and educational purposes.
