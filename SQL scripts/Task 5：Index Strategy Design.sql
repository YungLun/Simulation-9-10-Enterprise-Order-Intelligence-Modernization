
/*-------------------------------------------------------------
 Index 1: Nonclustered Index on SalesPersonID
--------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID
ON Sales.SalesOrderHeader (SalesPersonID);
GO


/*-------------------------------------------------------------
 Index 2: Covering Index for Modernized Query
--------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_SOH_PersonID_Covering
ON Sales.SalesOrderHeader (SalesPersonID)
INCLUDE (SalesOrderID, OrderDate, TotalDue, Freight);
GO



/*-------------------------------------------------------------
 Index 3: Filtered Index for selective predicate
--------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_SOH_SalesPersonID_Filtered
ON Sales.SalesOrderHeader (SalesPersonID)
WHERE SalesPersonID IS NOT NULL;
GO
