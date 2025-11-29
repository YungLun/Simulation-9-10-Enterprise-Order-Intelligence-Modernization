# AdventureWorks Order Intelligence Modernization  
### Simulation 9 

This repository contains my work for **Simulation 9**, which focuses on modernizing the legacy Order Intelligence module in AdventureWorks.  
The goal is to rebuild the old cursor-based logic, redesign it using set-based SQL, implement indexing improvements, and compare performance.

---

## Project Summary

The original system used **nested cursors** to evaluate orders and calculate:

- Load Factor  
- Days Outstanding  
- Risk Score  
- Risk Level  
- Missing Data Flags  

As data volume increased, this cursor design became slow and inefficient.  
In this simulation, I rebuilt the legacy design and modernized it using a fully set-based solution with optimized indexing.

---

## Tasks Completed

### ✔ Task 1 — Schema & Tables
Created schema **SalesOpsSim** and built:

- `OrderReviewQueue`
- `EmployeeOrderLoad`
- `OrderRiskLog`

---

### ✔ Task 2 — Legacy Cursor Version
Reconstructed the original nested cursor logic to understand its behavior and performance limitations.

---

### ✔ Task 3 — System Analysis
Identified major issues in the legacy design:

- Extremely high I/O  
- Poor scalability  
- More locking and blocking  
- Hard to maintain  
- Cursor usage not necessary  

Concluded that the module should be modernized using set-based SQL.

---

### ✔ Task 4 — Modernized Version
Rewrote the entire process using one set-based `INSERT INTO ... SELECT` query.  
Results:

- No more row-by-row processing  
- Cleaner and shorter code  
- Much faster than the cursor version  

---

### ✔ Task 5 — Index Strategy

Implemented three indexes:

```sql
-- 1. Nonclustered Index
CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID
ON Sales.SalesOrderHeader (SalesPersonID);

-- 2. Covering Index
CREATE NONCLUSTERED INDEX IX_SOH_PersonID_Covering
ON Sales.SalesOrderHeader (SalesPersonID)
INCLUDE (SalesOrderID, OrderDate, TotalDue, Freight);

-- 3. Filtered Index
CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID_Filtered
ON Sales.SalesOrderHeader (SalesPersonID)
WHERE SalesPersonID IS NOT NULL;
```sql

### ✔ Performance Comparison (Task 6)
Performance was measured using:
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

 Results
Version	Logical Reads	CPU Time	Elapsed Time
Legacy Cursor	Very high (thousands)	~150–300 ms	~150–300 ms
Modernized (No Index)	686	32 ms	42 ms
Modernized + Index	21	0 ms	24 ms

 Summary of Improvements
Modernization reduces I/O by 99%+
Indexing improves performance by another 97%
Final version is 8–10× faster than the cursor version
Execution plans confirm SQL Server performs index seeks instead of table scans
