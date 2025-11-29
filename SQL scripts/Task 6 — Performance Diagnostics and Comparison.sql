SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

--Test A ¡X Legacy Cursor Version
/*=============================================================
  Task 2 - Legacy Nested Cursor Logic
===============================================================*/

TRUNCATE TABLE SalesOpsSim.OrderRiskLog;
GO


DECLARE @SalesPersonID INT;

DECLARE Cursor_Employees CURSOR FOR
SELECT BusinessEntityID
FROM Sales.SalesPerson;

OPEN Cursor_Employees;
FETCH NEXT FROM Cursor_Employees INTO @SalesPersonID;


WHILE @@FETCH_STATUS = 0
BEGIN

    DECLARE @SalesOrderID INT,
            @OrderDate DATE,
            @TotalDue DECIMAL(19,4),
            @Freight  DECIMAL(19,4);

    DECLARE Cursor_Orders CURSOR FOR
    SELECT SalesOrderID, OrderDate, TotalDue, Freight
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID = @SalesPersonID;

    OPEN Cursor_Orders;
    FETCH NEXT FROM Cursor_Orders 
    INTO @SalesOrderID, @OrderDate, @TotalDue, @Freight;



    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Missing BIT = 0;
        DECLARE @LoadFactor DECIMAL(19,4);
        DECLARE @DaysOutstanding INT;
        DECLARE @RiskScore DECIMAL(19,4);
        DECLARE @RiskLevel NVARCHAR(20);

        IF @TotalDue IS NULL OR @Freight IS NULL OR @Freight = 0
        BEGIN
            SET @Missing = 1;
            SET @LoadFactor = NULL;
            SET @RiskScore = NULL;
        END
        ELSE
        BEGIN
            SET @LoadFactor = @TotalDue / @Freight;
            SET @DaysOutstanding = DATEDIFF(DAY, @OrderDate, GETDATE());
            SET @RiskScore = @LoadFactor * @DaysOutstanding;
        END

        IF @RiskScore IS NULL
            SET @RiskLevel = N'Unknown';
        ELSE IF @RiskScore < 500
            SET @RiskLevel = N'Low';
        ELSE IF @RiskScore < 2000
            SET @RiskLevel = N'Medium';
        ELSE
            SET @RiskLevel = N'High';

        INSERT INTO SalesOpsSim.OrderRiskLog
        (
            SalesOrderID, SalesPersonID, OrderDate,
            TotalDue, Freight, LoadFactor, DaysOutstanding,
            RiskScore, RiskLevel, MissingDataFlag, EvaluatedAt
        )
        VALUES
        (
            @SalesOrderID, @SalesPersonID, @OrderDate,
            @TotalDue, @Freight, @LoadFactor, @DaysOutstanding,
            @RiskScore, @RiskLevel, @Missing, SYSUTCDATETIME()
        );

        FETCH NEXT FROM Cursor_Orders 
        INTO @SalesOrderID, @OrderDate, @TotalDue, @Freight;
    END

    CLOSE Cursor_Orders;
    DEALLOCATE Cursor_Orders;

    FETCH NEXT FROM Cursor_Employees INTO @SalesPersonID;
END

CLOSE Cursor_Employees;
DEALLOCATE Cursor_Employees;
GO

SELECT TOP 50 *
FROM SalesOpsSim.OrderRiskLog
ORDER BY OrderRiskLogID;




--Test B ¡X Modernized
DROP INDEX IF EXISTS IX_SOH_SalesPersonID ON Sales.SalesOrderHeader;
DROP INDEX IF EXISTS IX_SOH_PersonID_Covering ON Sales.SalesOrderHeader;
DROP INDEX IF EXISTS IX_SOH_SalesPersonID_Filtered ON Sales.SalesOrderHeader;
GO


/*==============================================================
  Task 4 - Modernized Set-Based Order Intelligence Module
==============================================================*/

---------------------------------------------------------------
-- 1. Clear existing results for re-run
---------------------------------------------------------------
TRUNCATE TABLE SalesOpsSim.OrderRiskLog;
GO


/*==============================================================
  2. Modernized Set-Based Insert
==============================================================*/
INSERT INTO SalesOpsSim.OrderRiskLog
(
    SalesOrderID, SalesPersonID, OrderDate,
    TotalDue, Freight, LoadFactor, DaysOutstanding,
    RiskScore, RiskLevel, MissingDataFlag, EvaluatedAt
)
SELECT
    SOH.SalesOrderID,
    SOH.SalesPersonID,
    SOH.OrderDate,
    SOH.TotalDue,
    SOH.Freight,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN NULL
        ELSE SOH.TotalDue / SOH.Freight
    END AS LoadFactor,


    DATEDIFF(DAY, SOH.OrderDate, GETDATE()) AS DaysOutstanding,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN NULL
        ELSE (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE())
    END AS RiskScore,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN N'Unknown'
        WHEN (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE()) < 500
            THEN N'Low'
        WHEN (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE()) < 2000
            THEN N'Medium'
        ELSE N'High'
    END AS RiskLevel,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN 1
        ELSE 0
    END AS MissingDataFlag,


    SYSUTCDATETIME() AS EvaluatedAt

FROM Sales.SalesOrderHeader SOH
WHERE SOH.SalesPersonID IS NOT NULL;  
GO



SELECT TOP 50 *
FROM SalesOpsSim.OrderRiskLog
ORDER BY OrderRiskLogID;
GO


--Test C ¡X Modernized + Index
DROP INDEX IF EXISTS IX_SOH_SalesPersonID ON Sales.SalesOrderHeader;
DROP INDEX IF EXISTS IX_SOH_PersonID_Covering ON Sales.SalesOrderHeader;
DROP INDEX IF EXISTS IX_SOH_SalesPersonID_Filtered ON Sales.SalesOrderHeader;
GO

-- rebuild
CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID
ON Sales.SalesOrderHeader (SalesPersonID);

CREATE NONCLUSTERED INDEX IX_SOH_PersonID_Covering
ON Sales.SalesOrderHeader (SalesPersonID)
INCLUDE (SalesOrderID, OrderDate, TotalDue, Freight);

CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID_Filtered
ON Sales.SalesOrderHeader (SalesPersonID)
WHERE SalesPersonID IS NOT NULL;
GO


/*==============================================================
  Task 4 - Modernized Set-Based Order Intelligence Module
==============================================================*/

---------------------------------------------------------------
-- 1. Clear existing results for re-run
---------------------------------------------------------------
TRUNCATE TABLE SalesOpsSim.OrderRiskLog;
GO


/*==============================================================
  2. Modernized Set-Based Insert
==============================================================*/
INSERT INTO SalesOpsSim.OrderRiskLog
(
    SalesOrderID, SalesPersonID, OrderDate,
    TotalDue, Freight, LoadFactor, DaysOutstanding,
    RiskScore, RiskLevel, MissingDataFlag, EvaluatedAt
)
SELECT
    SOH.SalesOrderID,
    SOH.SalesPersonID,
    SOH.OrderDate,
    SOH.TotalDue,
    SOH.Freight,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN NULL
        ELSE SOH.TotalDue / SOH.Freight
    END AS LoadFactor,


    DATEDIFF(DAY, SOH.OrderDate, GETDATE()) AS DaysOutstanding,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN NULL
        ELSE (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE())
    END AS RiskScore,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN N'Unknown'
        WHEN (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE()) < 500
            THEN N'Low'
        WHEN (SOH.TotalDue / SOH.Freight) * DATEDIFF(DAY, SOH.OrderDate, GETDATE()) < 2000
            THEN N'Medium'
        ELSE N'High'
    END AS RiskLevel,


    CASE 
        WHEN SOH.TotalDue IS NULL OR SOH.Freight IS NULL OR SOH.Freight = 0
            THEN 1
        ELSE 0
    END AS MissingDataFlag,


    SYSUTCDATETIME() AS EvaluatedAt

FROM Sales.SalesOrderHeader SOH
WHERE SOH.SalesPersonID IS NOT NULL;  
GO



SELECT TOP 50 *
FROM SalesOpsSim.OrderRiskLog
ORDER BY OrderRiskLogID;
GO
