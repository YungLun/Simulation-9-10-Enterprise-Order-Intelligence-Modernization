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
