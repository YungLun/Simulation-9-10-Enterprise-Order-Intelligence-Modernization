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
