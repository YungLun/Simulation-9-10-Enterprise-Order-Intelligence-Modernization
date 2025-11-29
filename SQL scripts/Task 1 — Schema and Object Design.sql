-- Create custom schema for simulation work
CREATE SCHEMA SalesOpsSim;
GO


/*==========================================================
  Task 1 - Schema & Working Tables for Order Intelligence
==========================================================*/

------------------------------------------------------------
-- Table 1: OrderReviewQueue
------------------------------------------------------------
CREATE TABLE SalesOpsSim.OrderReviewQueue (
    OrderReviewID     INT IDENTITY(1,1) PRIMARY KEY, 
    SalesOrderID      INT           NOT NULL,         
    SalesPersonID     INT           NULL,            
    OrderDate         DATE          NOT NULL,        
    TotalDue          DECIMAL(19,4) NULL,            
    Freight           DECIMAL(19,4) NULL,            
    ReviewStatus      NVARCHAR(20)  NOT NULL 
                     CONSTRAINT DF_OrderReviewQueue_ReviewStatus 
                     DEFAULT (N'Pending'),           
    MissingDataFlag   BIT           NOT NULL 
                     CONSTRAINT DF_OrderReviewQueue_MissingDataFlag
                     DEFAULT (0),                    
    CreatedAt         DATETIME2(0)  NOT NULL 
                     CONSTRAINT DF_OrderReviewQueue_CreatedAt
                     DEFAULT (SYSUTCDATETIME()),     
    LastEvaluatedAt   DATETIME2(0)  NULL              
);
GO

------------------------------------------------------------
-- Table 2: EmployeeOrderLoad
------------------------------------------------------------
CREATE TABLE SalesOpsSim.EmployeeOrderLoad (
    EmployeeOrderLoadID INT IDENTITY(1,1) PRIMARY KEY,  
    SalesPersonID       INT           NOT NULL,          
    SnapshotDate        DATE          NOT NULL,          
    TotalOrders         INT           NOT NULL 
                        CONSTRAINT DF_EmployeeOrderLoad_TotalOrders
                        DEFAULT (0),                    
    HighRiskOrders      INT           NOT NULL 
                        CONSTRAINT DF_EmployeeOrderLoad_HighRiskOrders
                        DEFAULT (0),                    
    TotalLoadFactor     DECIMAL(19,4) NOT NULL 
                        CONSTRAINT DF_EmployeeOrderLoad_TotalLoadFactor
                        DEFAULT (0),                    
    WorkloadLevel       NVARCHAR(20)  NULL,            
    LastUpdated         DATETIME2(0)  NOT NULL 
                        CONSTRAINT DF_EmployeeOrderLoad_LastUpdated
                        DEFAULT (SYSUTCDATETIME())      
);
GO

------------------------------------------------------------
-- Table 3: OrderRiskLog
------------------------------------------------------------
CREATE TABLE SalesOpsSim.OrderRiskLog (
    OrderRiskLogID   INT IDENTITY(1,1) PRIMARY KEY,   
    SalesOrderID     INT           NOT NULL,          
    SalesPersonID    INT           NULL,              
    OrderDate        DATE          NOT NULL,          
    TotalDue         DECIMAL(19,4) NULL,             
    Freight          DECIMAL(19,4) NULL,             
    LoadFactor       DECIMAL(19,4) NULL,             
    DaysOutstanding  INT           NULL,             
    RiskScore        DECIMAL(19,4) NULL,             -- LoadFactor * DaysOutstanding
    RiskLevel        NVARCHAR(20)  NULL,             
    MissingDataFlag  BIT           NOT NULL 
                     CONSTRAINT DF_OrderRiskLog_MissingDataFlag
                     DEFAULT (0),                    
    EvaluatedAt      DATETIME2(0)  NOT NULL 
                     CONSTRAINT DF_OrderRiskLog_EvaluatedAt
                     DEFAULT (SYSUTCDATETIME())      
);
GO


