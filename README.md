Simulation 9 — Individual Work
This project is part of Simulation 9 and focuses on modernizing the legacy Order Intelligence process in the AdventureWorks database. The goal is to analyze the old cursor-based logic, rebuild the workflow using modern SQL techniques, and compare performance across different versions.
 Project Overview
The original Order Intelligence module used nested cursors to evaluate orders and calculate things like:
Load Factor
Days Outstanding
Risk Score
Risk Level
Missing Data Flags
While the old method worked for small datasets, it became too slow as data volume increased.
This project redesigns the process using set-based SQL and index optimization.
🔧 What I Completed
✔ Task 1 – Schema Setup
Created a new schema (SalesOpsSim) and built the following working tables:
OrderReviewQueue
EmployeeOrderLoad
OrderRiskLog
These tables support analysis, logging, and review workflows.
✔ Task 2 – Rebuild Legacy Cursor Logic
I rewrote the whole nested-cursor workflow based on the simulation spec and reproduced the old behavior step by step. This gives a baseline for performance comparison.
✔ Task 3 – System Analysis
Documented the problems in the legacy design, including:
high I/O cost
locking and concurrency issues
poor scalability
unnecessary row-by-row operations
Concluded that the workload can be fully replaced using set-based operations.
✔ Task 4 – Modernized Version
Rewrote the module using a single:
INSERT INTO ... SELECT
Features:
Fully set-based
No cursor needed
CASE expressions for RiskLevel & MissingDataFlag
Much easier to maintain
✔ Task 5 – Indexing
Designed and created indexes to support the modernized version:
Nonclustered index on SalesPersonID
Covering index for the evaluation query
Filtered index on non-null SalesPersonID
These help SQL Server switch from scans → seeks.
✔ Task 6 – Performance Testing
Ran three performance tests:
Version	Logical Reads	CPU (ms)	Elapsed (ms)
Legacy Cursor	Highest	~150–300	~150–300
Modernized (No Index)	Medium	~32	~42
Modernized + Index	Lowest	~0	~24
Used:
SET STATISTICS IO ON
SET STATISTICS TIME ON
Execution Plans
✔ Final Report
A full modern-style technical report was completed, including:
Executive summary
IoT business case
Workflow description
Concurrency and performance analysis
Security and role setup
Final conclusions
