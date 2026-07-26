--Section A — Joins & Filtering (1–10):

--Q1. The US sales team needs a contact list. Pull every US-based customer’s full name, email, city, and country.
SELECT 
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Full_Name,
    Cust.EmailAddress AS Email_ID,
    Geo.City,
    Geo.EnglishCountryRegionName AS Country
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.DimGeography AS Geo
    ON Geo.GeographyKey = Cust.GeographyKey
WHERE Geo.EnglishCountryRegionName = 'United States'

--Q2. Merchandising wants the full assortment. List every product with its subcategory and category.
SELECT
    Prod.EnglishProductName AS Product_Name,
    PC.EnglishProductCategoryName AS Category,
    PSC.EnglishProductSubCategoryName AS Sub_Category
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.DimProductSubcategory AS PSC
    ON PSC.ProductSubCategoryKey = Prod.ProductSubCategoryKey
INNER JOIN dbo.DimProductCategory AS PC
    ON PC.ProductCategoryKey = PSC.ProductCategoryKey

--Q3. The e-commerce team needs an order-level view. Compile every internet sales order with its customer and product.
SELECT
    FIS.SalesOrderNumber,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    Prod.EnglishProductName AS Product_Name
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimCustomer AS Cust
    ON Cust.CustomerKey = FIS.CustomerKey
INNER JOIN dbo.DimProduct AS Prod
    ON Prod.ProductKey = FIS.ProductKey

--Q4. Marketing is curating a themed range. Find all products whose English name contains the word ‘Mountain’.
SELECT
    Prod.ProductKey,
    Prod.EnglishProductName
FROM dbo.DimProduct AS Prod
WHERE Prod.EnglishProductName LIKE '%Mountain%'

--Q5. Leadership is reviewing our three core markets. List all customers in the United States, Canada, or Australia.
SELECT 
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    Geo.EnglishCountryRegionName AS Country
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.DimGeography AS Geo
    ON Geo.GeographyKey = Cust.GeographyKey
WHERE Geo.EnglishCountryRegionName IN ('United States','Canada','Australia')

--Q6. Finance is closing the 2013 books. Show all products that recorded sales during 2013 (1 Jan – 31 Dec).
SELECT DISTINCT
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    FIS.OrderDate
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON FIS.ProductKey = Prod.ProductKey
WHERE FIS.OrderDate >= '2013-01-01'
  AND FIS.OrderDate < '2014-01-01'
ORDER BY FIS.OrderDate Asc

--Q7. The digital team is auditing online gaps. Find every product that has never generated an internet sale.
SELECT
    Prod.ProductKey AS Product_Key_From_Product_Table,
    FIS.ProductKey AS Product_Key_From_Sales_Table,
    Prod.EnglishProductName AS Product_Name
FROM dbo.DimProduct AS Prod
LEFT JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
WHERE FIS.ProductKey IS NULL

--Q8. Support is segmenting alphabetically. Provide all customers whose last name begins with ‘B’.
SELECT
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name
FROM dbo.DimCustomer AS Cust
WHERE Cust.LastName LIKE 'B%'

--Q9. The CRM team wants cleaner data. Flag every customer with no email address on file.
SELECT
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    Cust.EmailAddress AS Email_ID
FROM dbo.DimCustomer AS Cust
WHERE Cust.EmailAddress IS NULL

--Q10. Pricing is reviewing the mid-range. Display all products with a list price between $500 and $1,500.
SELECT
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    FIS.OrderQuantity,
    FIS.UnitPrice,
    FIS.SalesAmount
FROM dbo.DimProduct as Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
WHERE FIS.SalesAmount BETWEEN '$500' AND '$1500'
ORDER BY FIS.SalesAmount ASC

---------------------------------------------------------------------------------------------------------------------------------------------
--Section B — Aggregations & Grouping (11–20):

--Q11. The board wants the revenue trend. Calculate total sales for each year.
SELECT
    YEAR(FIS.OrderDate) AS Sales_Year,
    SUM(FIS.SalesAmount) AS Yearly_Total_Sales
FROM dbo.FactInternetSales AS FIS
GROUP BY YEAR(FIS.OrderDate)
ORDER BY Sales_Year

--Section B — Aggregations & Grouping (11–20):

--Q12. Account management is gauging engagement. Report the total number of orders placed by each customer.
SELECT
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    COUNT(DISTINCT FIS.SalesOrderNumber) AS Total_Orders_Placed
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.FactInternetSales AS FIS
    ON Cust.CustomerKey = FIS.CustomerKey
GROUP BY
    Cust.CustomerKey,
    Cust.FirstName,
    Cust.MiddleName,
    Cust.LastName
ORDER BY Total_Orders_Placed DESC     

--Q13. Leadership wants to recognise top accounts. Identify the ten customers with the highest total sales.
SELECT Top (10)
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    SUM(FIS.SalesAmount) AS Total_Sales_Per_Customer
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.FactInternetSales AS FIS
    ON Cust.CustomerKey = FIS.CustomerKey
GROUP BY
    Cust.CustomerKey,
    Cust.FirstName,
    Cust.MiddleName,
    Cust.LastName
ORDER BY Total_Sales_Per_Customer DESC 

--Q14. Pricing wants a benchmark. Calculate the average unit price for each product category.
SELECT
    PC.EnglishProductCategoryName AS Product_Category,
    AVG(FIS.UnitPrice) AS Average_Unit_Price
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimProduct AS Prod
    ON Prod.ProductKey = FIS.ProductKey
INNER JOIN dbo.DimProductSubcategory AS PSC
    ON PSC.ProductSubcategoryKey = Prod.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS PC
    ON PC.ProductCategoryKey = PSC.ProductCategoryKey
GROUP BY
    PC.EnglishProductCategoryName
ORDER BY
    Average_Unit_Price DESC

--Q15. Regional planning needs the footprint. Count the number of customers in each country.
SELECT 
    Geo.EnglishCountryRegionName AS Country,
    COUNT(Cust.CustomerKey) AS Total_Customers
FROM dbo.DimGeography AS Geo
INNER JOIN dbo.DimCustomer AS Cust
    ON Geo.GeographyKey = Cust.GeographyKey
GROUP BY 
    Geo.EnglishCountryRegionName
ORDER BY
    Total_Customers DESC

--Q16. For the strategy review, identify the flagship categories — those generating more than $1,000,000 in sales.
SELECT
    PC.EnglishProductCategoryName AS Product_Category,
    SUM(FIS.SalesAmount) AS Total_Sales_Amount 
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimProduct AS Prod
    ON Prod.ProductKey = FIS.ProductKey
INNER JOIN dbo.DimProductSubcategory AS PSC
    ON PSC.ProductSubcategoryKey = Prod.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS PC
    ON PC.ProductCategoryKey = PSC.ProductCategoryKey
GROUP BY
    PC.EnglishProductCategoryName
HAVING 
    SUM(FIS.SalesAmount) > 1000000
ORDER BY
    Total_Sales_Amount DESC

--Q17. Territory managers need benchmarks. For each territory, report the highest, lowest, and average order amount.
SELECT
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion AS Territory,
    MAX(FIS.SalesAmount) AS Highest_Order_Amount,
    MIN(FIS.SalesAmount) AS Lowest_Order_Amount,
    AVG(FIS.SalesAmount) AS Average_Order_Amount
FROM dbo.DimSalesTerritory AS ST
INNER JOIN dbo.FactInternetSales AS FIS
    ON FIS.SalesTerritoryKey = ST.SalesTerritoryKey
GROUP BY
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion
ORDER BY
    ST.SalesTerritoryKey

--Q18. Identify high-density markets — countries where we serve more than 100 customers.
SELECT 
    Geo.EnglishCountryRegionName AS Country_Name,
    COUNT(Cust.CustomerKey) AS Total_Customers
FROM dbo.DimGeography AS Geo
INNER JOIN dbo.DimCustomer AS Cust
    ON Geo.GeographyKey = Cust.GeographyKey
GROUP BY 
    Geo.EnglishCountryRegionName
HAVING 
    COUNT(Cust.CustomerKey) > 100
ORDER BY 
    Total_Customers DESC

--Q19. Supply chain needs demand volumes. Calculate the total quantity sold for each product.
SELECT 
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    SUM(FIS.OrderQuantity) AS Total_Quantity_Sold
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
GROUP BY 
    Prod.ProductKey,
    Prod.EnglishProductName
ORDER BY
    SUM(FIS.OrderQuantity) DESC

--Q20. Merchandising is reviewing breadth. Identify categories that carry more than 50 products.
SELECT 
    PC.EnglishProductCategoryName AS Category_Name,
    COUNT(Prod.ProductKey) AS Total_Products
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.DimProductSubcategory AS PSC
    ON PSC.ProductSubcategoryKey = Prod.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS PC
    ON PC.ProductCategoryKey = PSC.ProductCategoryKey
GROUP BY 
    PC.EnglishProductCategoryName
HAVING 
    COUNT(Prod.ProductKey) > 50
ORDER BY 
    Total_Products DESC
    
---------------------------------------------------------------------------------------------------------------------------------------------
--Section C — Built-in Functions & CASE (21–25):

--Q21. Standardise records for a mail merge. Present each customer’s full name in uppercase and email in lowercase.
SELECT 
    UPPER(CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName)) AS Customer_Name,
    LOWER(Cust.EmailAddress) AS Email_ID
FROM dbo.DimCustomer AS Cust

--Q22. The insights team is building profiles. Calculate each customer’s current age from their date of birth.
SELECT 
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    Cust.BirthDate,
    DATEDIFF(YEAR, Cust.BirthDate, GETDATE()) AS Customer_Age
FROM dbo.DimCustomer AS Cust

--Q23. Finance wants monthly trends. Extract year and month from order date and total sales by year-month.
SELECT
    MONTH(FIS.OrderDate) AS Sales_Month,
    Year(FIS.OrderDate) AS Sales_Year,
    SUM(FIS.SalesAmount) AS Total_Sales_Amount
FROM dbo.FactInternetSales AS FIS
GROUP BY
    MONTH(FIS.OrderDate),
    Year(FIS.OrderDate)
ORDER BY 
    Sales_Month,
    Sales_Year

--Q24. Marketing wants price tiers. Classify each product as Premium, Standard, or Budget based on list price.
SELECT
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    Prod.ListPrice,
    CASE
        WHEN Prod.ListPrice < 1300 THEN 'Budget'
        WHEN Prod.ListPrice BETWEEN 1300 AND 2600 THEN 'Standard'
        WHEN Prod.ListPrice > 2600 THEN 'Premium'
    ELSE 'Unknown'
END AS Product_Classification
FROM dbo.DimProduct AS Prod

--Q25. Build a value segmentation. Label each customer High, Medium, or Low Value based on total spend.
SELECT 
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    SUM(FIS.SalesAmount) AS Total_Spend,
    CASE
        WHEN SUM(FIS.SalesAmount) < 4000 THEN 'Low Value'
        WHEN SUM(FIS.SalesAmount) BETWEEN 4000 AND 8000 THEN 'Medium Value'
        WHEN SUM(FIS.SalesAmount) > 8000 THEN 'High Value'
        ELSE 'Unknown'
    END AS Customer_Classification
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.FactInternetSales AS FIS
    ON Cust.CustomerKey = FIS.CustomerKey
GROUP BY 
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName)

---------------------------------------------------------------------------------------------------------------------------------------------
--Section D — Subqueries (26–35):

--Q26. Pricing is studying the premium end. Find products whose list price exceeds the catalogue-wide average.
SELECT
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    Prod.ListPrice
FROM dbo.DimProduct AS Prod
WHERE Prod.ListPrice > (
    SELECT AVG(ProdAvg.ListPrice)
    FROM dbo.DimProduct AS ProdAvg
)
ORDER BY
    Prod.ListPrice DESC

--Q27. Find above-average customers — those whose total spend beats the average customer spend.
SELECT 
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    ROUND(SUM(FIS.SalesAmount), 2) AS Total_Customer_Spend
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.FactInternetSales AS FIS
    ON Cust.CustomerKey = FIS.CustomerKey
GROUP BY
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName)
HAVING SUM(FIS.SalesAmount) > (
    SELECT AVG(CustomerSpend.Total_Customer_Spend)
    FROM (
        SELECT
            CustomerKey,
            SUM(SalesAmount) AS Total_Customer_Spend
        FROM dbo.FactInternetSales
        GROUP BY CustomerKey
    ) AS CustomerSpend
)
ORDER BY
    SUM(FIS.SalesAmount) DESC

--Q28. Leadership wants the headline winner. Display the product(s) with the highest total sales amount.
SELECT 
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    SUM(FIS.SalesAmount) AS Total_Sales_Amount
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
GROUP BY
    Prod.ProductKey,
    Prod.EnglishProductName
HAVING SUM(FIS.SalesAmount) = (
    SELECT MAX(ProductSales.Total_Sales_Amount)
    FROM (
        SELECT
            ProductKey,
            SUM(SalesAmount) AS Total_Sales_Amount
        FROM dbo.FactInternetSales
        GROUP BY ProductKey
    ) AS ProductSales
)

--Q29. Find the most active buyers — customers who placed more orders than the average per customer.
SELECT 
    FIS.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    COUNT(DISTINCT FIS.SalesOrderNumber) AS Total_Customer_Orders
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimCustomer AS Cust
    ON FIS.CustomerKey = Cust.CustomerKey
GROUP BY
    FIS.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName)
HAVING COUNT(DISTINCT FIS.SalesOrderNumber) > (
    SELECT AVG(CustomerOrders.Total_Customer_Orders)
    FROM (
        SELECT
            CustomerKey,
            COUNT(DISTINCT SalesOrderNumber) AS Total_Customer_Orders
        FROM dbo.FactInternetSales
        GROUP BY CustomerKey
    ) AS CustomerOrders
)
ORDER BY
    COUNT(DISTINCT FIS.SalesOrderNumber) DESC

--Q30. Spotlight strong regions. Show territories whose total sales exceed the average across all territories.
SELECT 
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion,
    ST.SalesTerritoryCountry AS Country,
    ROUND(SUM(FIS.SalesAmount), 2) AS Total_TerritoryWise_Spend
FROM dbo.DimSalesTerritory AS ST
INNER JOIN dbo.FactInternetSales AS FIS
    ON ST.SalesTerritoryKey = FIS.SalesTerritoryKey
GROUP BY
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion,
    ST.SalesTerritoryCountry
HAVING SUM(FIS.SalesAmount) > (
    SELECT AVG(TerritoryWiseSpend.Total_TerritoryWise_Spend)
    FROM (
        SELECT
            SalesTerritoryKey,
            SUM(SalesAmount) AS Total_TerritoryWise_Spend
        FROM dbo.FactInternetSales
        GROUP BY SalesTerritoryKey
    ) AS TerritoryWiseSpend
)
ORDER BY
    SUM(FIS.SalesAmount) DESC

--Q31. Rank the portfolio. Find products whose total sales are higher than the average product sales.
SELECT 
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    SUM(FIS.SalesAmount) AS Total_Sales_Amount
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
GROUP BY
    Prod.ProductKey,
    Prod.EnglishProductName
HAVING SUM(FIS.SalesAmount) > (
    SELECT AVG(TotalSales.Total_Sales_Amount)
    FROM (
        SELECT
            ProductKey,
            SUM(SalesAmount) AS Total_Sales_Amount
        FROM dbo.FactInternetSales
        GROUP BY ProductKey
    ) AS TotalSales
)
ORDER BY
    SUM(FIS.SalesAmount) DESC

--Q32. For a turnaround review, find territories whose total sales fall below the overall average.
SELECT 
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion,
    ST.SalesTerritoryCountry AS Country,
    ROUND(SUM(FIS.SalesAmount), 2) AS Total_TerritoryWise_Spend
FROM dbo.DimSalesTerritory AS ST
INNER JOIN dbo.FactInternetSales AS FIS
    ON ST.SalesTerritoryKey = FIS.SalesTerritoryKey
GROUP BY
    ST.SalesTerritoryKey,
    ST.SalesTerritoryRegion,
    ST.SalesTerritoryCountry
HAVING SUM(FIS.SalesAmount) < (
    SELECT AVG(TerritoryWiseSpend.Total_TerritoryWise_Spend)
    FROM (
        SELECT
            SalesTerritoryKey,
            SUM(SalesAmount) AS Total_TerritoryWise_Spend
        FROM dbo.FactInternetSales
        GROUP BY SalesTerritoryKey
    ) AS TerritoryWiseSpend
)
ORDER BY
    SUM(FIS.SalesAmount) DESC

--Q33. Find big-ticket buyers — customers whose largest single order exceeds the company’s average order amount.
SELECT 
    FIS.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name,
    MAX(FIS.SalesAmount) AS Largest_Single_Order_Amount
FROM dbo.DimCustomer AS Cust
INNER JOIN dbo.FactInternetSales AS FIS
    ON Cust.CustomerKey = FIS.CustomerKey
GROUP BY
    FIS.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName)
HAVING MAX(FIS.SalesAmount) > (
    SELECT AVG(SalesAmount)
    FROM dbo.FactInternetSales
)
ORDER BY
    MAX(FIS.SalesAmount) DESC

--Q34. Find the widest-reach products — those sold to more distinct customers than the average product.
SELECT
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    COUNT(DISTINCT FIS.CustomerKey) AS Distinct_Customers
FROM dbo.DimProduct AS Prod
INNER JOIN dbo.FactInternetSales AS FIS
    ON Prod.ProductKey = FIS.ProductKey
GROUP BY
    Prod.ProductKey,
    Prod.EnglishProductName
HAVING COUNT(DISTINCT FIS.CustomerKey) > (
    SELECT AVG(ProductCustomers.Total_Customers * 1.0)
    FROM (
        SELECT
            ProductKey,
            COUNT(DISTINCT CustomerKey) AS Total_Customers
        FROM dbo.FactInternetSales
        GROUP BY ProductKey
    ) AS ProductCustomers
)
ORDER BY
    Distinct_Customers DESC

--Q35. Find premium markets — countries where average customer spend is above the company-wide average.
SELECT
    CountrySpend.Country,
    AVG(CountrySpend.Customer_Total_Spend) AS Average_Customer_Spend
FROM (
    SELECT
        Geo.EnglishCountryRegionName AS Country,
        Cust.CustomerKey,
        SUM(FIS.SalesAmount) AS Customer_Total_Spend
    FROM dbo.DimCustomer AS Cust
    INNER JOIN dbo.DimGeography AS Geo
        ON Geo.GeographyKey = Cust.GeographyKey
    INNER JOIN dbo.FactInternetSales AS FIS
        ON FIS.CustomerKey = Cust.CustomerKey
    GROUP BY
        Geo.EnglishCountryRegionName,
        Cust.CustomerKey
) AS CountrySpend
GROUP BY
    CountrySpend.Country
HAVING AVG(CountrySpend.Customer_Total_Spend) > (
    SELECT AVG(CompanySpend.Customer_Total_Spend)
    FROM (
        SELECT
            CustomerKey,
            SUM(SalesAmount) AS Customer_Total_Spend
        FROM dbo.FactInternetSales
        GROUP BY CustomerKey
    ) AS CompanySpend
)
ORDER BY
    Average_Customer_Spend DESC

---------------------------------------------------------------------------------------------------------------------------------------------
--Section E — Correlated Subqueries & EXISTS (36–45):

--Q36. Within each category, find the standouts — products whose total sales beat their own category’s average.
SELECT
    PC.ProductCategoryKey,
    PC.EnglishProductCategoryName AS Category_Name,
    Prod.ProductKey,
    Prod.EnglishProductName AS Product_Name,
    SUM(FIS.SalesAmount) AS Product_Total_Sales
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimProduct AS Prod
    ON Prod.ProductKey = FIS.ProductKey
INNER JOIN dbo.DimProductSubcategory AS PSC
    ON PSC.ProductSubcategoryKey = Prod.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS PC
    ON PC.ProductCategoryKey = PSC.ProductCategoryKey
GROUP BY
    PC.ProductCategoryKey,
    PC.EnglishProductCategoryName,
    Prod.ProductKey,
    Prod.EnglishProductName
HAVING SUM(FIS.SalesAmount) > (
    SELECT AVG(CategoryProductSales.Product_Total_Sales)
    FROM (
        SELECT
            InnerPSC.ProductCategoryKey,
            InnerProd.ProductKey,
            SUM(InnerFIS.SalesAmount) AS Product_Total_Sales
        FROM dbo.FactInternetSales AS InnerFIS
        INNER JOIN dbo.DimProduct AS InnerProd
            ON InnerProd.ProductKey = InnerFIS.ProductKey
        INNER JOIN dbo.DimProductSubcategory AS InnerPSC
            ON InnerPSC.ProductSubcategoryKey =
               InnerProd.ProductSubcategoryKey
        GROUP BY
            InnerPSC.ProductCategoryKey,
            InnerProd.ProductKey
    ) AS CategoryProductSales
    WHERE CategoryProductSales.ProductCategoryKey =
          PC.ProductCategoryKey
)
ORDER BY
    Category_Name,
    Product_Total_Sales DESC

--Section E — Correlated Subqueries & EXISTS (36–45):

--Q37. We’re planning a bike push. Find customers who have never purchased a bike.
SELECT
    Cust.CustomerKey,
    CONCAT(Cust.FirstName,' ',Cust.MiddleName,' ',Cust.LastName) AS Customer_Name
FROM dbo.DimCustomer AS Cust
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimProduct AS Prod
        ON Prod.ProductKey = FIS.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS PSC
        ON PSC.ProductSubcategoryKey = Prod.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS PC
        ON PC.ProductCategoryKey = PSC.ProductCategoryKey
    WHERE FIS.CustomerKey = Cust.CustomerKey
      AND PC.EnglishProductCategoryName = 'Bikes'
)
ORDER BY
    Cust.CustomerKey

--Q38. Find each market’s leaders — customers whose total purchases exceed the average spend of their country.
WITH CustomerSpend AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        DG.EnglishCountryRegionName AS Country,
        SUM(FIS.SalesAmount) AS TotalPurchases
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    GROUP BY
        DC.CustomerKey,
        DC.FirstName,
        DC.LastName,
        DG.EnglishCountryRegionName
)
SELECT
    CS.CustomerKey,
    CS.CustomerName,
    CS.Country,
    ROUND(CS.TotalPurchases, 2) AS TotalPurchases
FROM CustomerSpend AS CS
WHERE CS.TotalPurchases >
(
    SELECT AVG(CS2.TotalPurchases)
    FROM CustomerSpend AS CS2
    WHERE CS2.Country = CS.Country
)
ORDER BY
    CS.Country,
    CS.TotalPurchases DESC

--Q39. Find globally popular products — those sold to customers from at least 5 different countries.
SELECT
    DP.ProductKey,
    DP.EnglishProductName AS ProductName
FROM dbo.DimProduct AS DP
WHERE EXISTS
(
    SELECT 1
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    WHERE FIS.ProductKey = DP.ProductKey
    GROUP BY FIS.ProductKey
    HAVING COUNT(DISTINCT DG.EnglishCountryRegionName) >= 5
)
ORDER BY DP.EnglishProductName

--Q40. The Australia team wants gaps. Find products that have never been sold in Australia.
SELECT
    DP.ProductKey,
    DP.EnglishProductName AS ProductName
FROM dbo.DimProduct AS DP
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    WHERE FIS.ProductKey = DP.ProductKey
      AND DG.EnglishCountryRegionName = 'Australia'
)
ORDER BY
    DP.EnglishProductName

--Q41. Spot regions with no marquee account. Find countries where no customer has generated more than $10,000 in sales.
SELECT DISTINCT
    DG.EnglishCountryRegionName AS Country
FROM dbo.DimGeography AS DG
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.FactInternetSales AS FIS
        ON DC.CustomerKey = FIS.CustomerKey
    INNER JOIN dbo.DimGeography AS DG2
        ON DC.GeographyKey = DG2.GeographyKey
    WHERE DG2.EnglishCountryRegionName =
          DG.EnglishCountryRegionName
    GROUP BY
        DC.CustomerKey
    HAVING SUM(FIS.SalesAmount) > 10000
)
ORDER BY
    Country

--Q42. Find cross-sell targets. Find customers who have purchased from only one product category.
SELECT
    DC.CustomerKey,
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
    COUNT(DISTINCT DPC.ProductCategoryKey) AS CategoriesPurchased
FROM dbo.DimCustomer AS DC
INNER JOIN dbo.FactInternetSales AS FIS
    ON DC.CustomerKey = FIS.CustomerKey
INNER JOIN dbo.DimProduct AS DP
    ON FIS.ProductKey = DP.ProductKey
INNER JOIN dbo.DimProductSubcategory AS DPSC
    ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS DPC
    ON DPSC.ProductCategoryKey = DPC.ProductCategoryKey
GROUP BY
    DC.CustomerKey,
    DC.FirstName,
    DC.LastName
HAVING COUNT(DISTINCT DPC.ProductCategoryKey) = 1
ORDER BY
    CustomerName

--Q43. Find perennial sellers — products that have sold in every year present in the dataset.
SELECT
    DP.ProductKey,
    DP.EnglishProductName AS ProductName
FROM dbo.DimProduct AS DP
WHERE NOT EXISTS
(
    -- Find a year in the dataset...
    SELECT DISTINCT
        YEAR(FIS_All.OrderDate) AS SalesYear
    FROM dbo.FactInternetSales AS FIS_All
    WHERE NOT EXISTS
    (
        -- ...in which the current product was not sold.
        SELECT 1
        FROM dbo.FactInternetSales AS FIS_Product
        WHERE FIS_Product.ProductKey = DP.ProductKey
          AND YEAR(FIS_Product.OrderDate) =
              YEAR(FIS_All.OrderDate)
    )
)
ORDER BY
    DP.EnglishProductName

--Q44. Find the most engaged customers — those who have purchased from every product category.
SELECT
    DC.CustomerKey,
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName
FROM dbo.DimCustomer AS DC
WHERE NOT EXISTS
(
    -- Find a product category...
    SELECT 1
    FROM dbo.DimProductCategory AS DPC
    WHERE NOT EXISTS
    (
        -- ...from which the current customer has made a purchase.
        SELECT 1
        FROM dbo.FactInternetSales AS FIS
        INNER JOIN dbo.DimProduct AS DP
            ON FIS.ProductKey = DP.ProductKey
        INNER JOIN dbo.DimProductSubcategory AS DPSC
            ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
        WHERE FIS.CustomerKey = DC.CustomerKey
          AND DPSC.ProductCategoryKey = DPC.ProductCategoryKey
    )
)
ORDER BY
    CustomerName

--Q45. Find fully-activated categories — those in which every product has at least one sale.
SELECT
    DPC.ProductCategoryKey,
    DPC.EnglishProductCategoryName AS CategoryName
FROM dbo.DimProductCategory AS DPC
WHERE NOT EXISTS
(
    -- Find a product belonging to the current category...
    SELECT 1
    FROM dbo.DimProductSubcategory AS DPSC
    INNER JOIN dbo.DimProduct AS DP
        ON DPSC.ProductSubcategoryKey = DP.ProductSubcategoryKey
    WHERE DPSC.ProductCategoryKey = DPC.ProductCategoryKey
      AND NOT EXISTS
      (
          -- ...that has no sale record.
          SELECT 1
          FROM dbo.FactInternetSales AS FIS
          WHERE FIS.ProductKey = DP.ProductKey
      )
)
ORDER BY
    CategoryName

---------------------------------------------------------------------------------------------------------------------------------------------
--Section F — CTE-Based Reporting (46–50):

--Q46. Using a CTE, build a high-value list — customers with total sales above $10,000.
WITH CustomerSales AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        SUM(FIS.SalesAmount) AS TotalSales
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.FactInternetSales AS FIS
        ON DC.CustomerKey = FIS.CustomerKey
    GROUP BY
        DC.CustomerKey,
        DC.FirstName,
        DC.LastName
)
SELECT
    CustomerKey,
    CustomerName,
    ROUND(TotalSales, 2) AS TotalSales
FROM CustomerSales
WHERE TotalSales > 10000
ORDER BY
    TotalSales DESC

--Q47. Using a CTE, find cornerstone markets — countries each contributing more than 10% of company revenue.
WITH CountryRevenue AS
(
    SELECT
        DG.EnglishCountryRegionName AS Country,
        SUM(FIS.SalesAmount) AS TotalCountryRevenue
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    GROUP BY
        DG.EnglishCountryRegionName
),
CompanyRevenue AS
(
    SELECT
        SUM(SalesAmount) AS TotalCompanyRevenue
    FROM dbo.FactInternetSales
)

SELECT
    CR.Country,
    ROUND(CR.TotalCountryRevenue, 2) AS TotalCountryRevenue,
    ROUND(
        (CR.TotalCountryRevenue * 100.0) / CMR.TotalCompanyRevenue,
        2
    ) AS RevenueContributionPercentage
FROM CountryRevenue AS CR
CROSS JOIN CompanyRevenue AS CMR
WHERE CR.TotalCountryRevenue > CMR.TotalCompanyRevenue * 0.10
ORDER BY
    RevenueContributionPercentage DESC

--Q48. Using multiple CTEs, compare yearly revenue and flag any year that declined versus the prior year.
WITH YearlyRevenue AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(SalesAmount) AS TotalRevenue
    FROM dbo.FactInternetSales
    GROUP BY
        YEAR(OrderDate)
),
RevenueComparison AS
(
    SELECT
        CurrentYear.SalesYear,
        CurrentYear.TotalRevenue,
        PreviousYear.TotalRevenue AS PreviousYearRevenue
    FROM YearlyRevenue AS CurrentYear
    LEFT JOIN YearlyRevenue AS PreviousYear
        ON PreviousYear.SalesYear = CurrentYear.SalesYear - 1
)
SELECT
    SalesYear,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    ROUND(PreviousYearRevenue, 2) AS PreviousYearRevenue,
    ROUND(
        TotalRevenue - PreviousYearRevenue,
        2
    ) AS RevenueChange,
    CASE
        WHEN PreviousYearRevenue IS NULL
            THEN 'No Prior Year'
        WHEN TotalRevenue < PreviousYearRevenue
            THEN 'Declined'
        ELSE 'Not Declined'
    END AS RevenueStatus
FROM RevenueComparison
ORDER BY
    SalesYear

--Q49. Using a CTE, compute lifetime revenue and assign a tier: Platinum >20,000, Gold 10,000–20,000, Silver 5,000–10,000, Bronze <5,000.
WITH CustomerLifetimeRevenue AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        SUM(FIS.SalesAmount) AS LifetimeRevenue
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.FactInternetSales AS FIS
        ON DC.CustomerKey = FIS.CustomerKey
    GROUP BY
        DC.CustomerKey,
        DC.FirstName,
        DC.LastName
)

SELECT
    CustomerKey,
    CustomerName,
    ROUND(LifetimeRevenue, 2) AS LifetimeRevenue,
    CASE
        WHEN LifetimeRevenue > 20000 THEN 'Platinum'
        WHEN LifetimeRevenue >= 10000 THEN 'Gold'
        WHEN LifetimeRevenue >= 5000 THEN 'Silver'
        ELSE 'Bronze'
    END AS CustomerTier
FROM CustomerLifetimeRevenue
ORDER BY
    LifetimeRevenue DESC

/*Q50. Using CTEs and joins only, produce a customer summary: name, country, # orders, total sales, average order value, distinct products, 
distinct categories.
*/
WITH CustomerDetails AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        DG.EnglishCountryRegionName AS Country
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
),
OrderSummary AS
(
    SELECT
        FIS.CustomerKey,
        COUNT(DISTINCT FIS.SalesOrderNumber) AS NumberOfOrders,
        SUM(FIS.SalesAmount) AS TotalSales,
        SUM(FIS.SalesAmount)
            / NULLIF(COUNT(DISTINCT FIS.SalesOrderNumber), 0)
            AS AverageOrderValue
    FROM dbo.FactInternetSales AS FIS
    GROUP BY
        FIS.CustomerKey
),
ProductSummary AS
(
    SELECT
        FIS.CustomerKey,
        COUNT(DISTINCT FIS.ProductKey) AS DistinctProducts
    FROM dbo.FactInternetSales AS FIS
    GROUP BY
        FIS.CustomerKey
),
CategorySummary AS
(
    SELECT
        FIS.CustomerKey,
        COUNT(DISTINCT DPSC.ProductCategoryKey) AS DistinctCategories
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimProduct AS DP
        ON FIS.ProductKey = DP.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS DPSC
        ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
    GROUP BY
        FIS.CustomerKey
)
SELECT
    CD.CustomerKey,
    CD.CustomerName,
    CD.Country,
    OS.NumberOfOrders,
    ROUND(OS.TotalSales, 2) AS TotalSales,
    ROUND(OS.AverageOrderValue, 2) AS AverageOrderValue,
    PS.DistinctProducts,
    CS.DistinctCategories
FROM CustomerDetails AS CD
INNER JOIN OrderSummary AS OS
    ON CD.CustomerKey = OS.CustomerKey
INNER JOIN ProductSummary AS PS
    ON CD.CustomerKey = PS.CustomerKey
INNER JOIN CategorySummary AS CS
    ON CD.CustomerKey = CS.CustomerKey
ORDER BY
    OS.TotalSales DESC

---------------------------------------------------------------------------------------------------------------------------------------------
--Challenge Round — Interview Level (51–60):

--Q51. Find cross-category champions — customers who purchased from more than 3 different categories.
SELECT
    DC.CustomerKey,
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
    COUNT(DISTINCT DPSC.ProductCategoryKey) AS CategoriesPurchased
FROM dbo.DimCustomer AS DC
INNER JOIN dbo.FactInternetSales AS FIS
    ON DC.CustomerKey = FIS.CustomerKey
INNER JOIN dbo.DimProduct AS DP
    ON FIS.ProductKey = DP.ProductKey
INNER JOIN dbo.DimProductSubcategory AS DPSC
    ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
GROUP BY
    DC.CustomerKey,
    DC.FirstName,
    DC.LastName
HAVING
    COUNT(DISTINCT DPSC.ProductCategoryKey) > 3
ORDER BY
    CategoriesPurchased DESC,
    CustomerName

--Q52. Find any customer whose total spend exceeds the combined total sales of all Canadian customers.
WITH CustomerSpend AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        SUM(FIS.SalesAmount) AS TotalSpend
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.FactInternetSales AS FIS
        ON DC.CustomerKey = FIS.CustomerKey
    GROUP BY
        DC.CustomerKey,
        DC.FirstName,
        DC.LastName
),
CanadianSales AS
(
    SELECT
        SUM(FIS.SalesAmount) AS TotalCanadianSales
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    WHERE DG.EnglishCountryRegionName = 'Canada'
)
SELECT
    CS.CustomerKey,
    CS.CustomerName,
    ROUND(CS.TotalSpend, 2) AS TotalSpend,
    ROUND(CA.TotalCanadianSales, 2) AS TotalCanadianSales
FROM CustomerSpend AS CS
CROSS JOIN CanadianSales AS CA
WHERE CS.TotalSpend > CA.TotalCanadianSales
ORDER BY
    CS.TotalSpend DESC

--Q53. Find truly universal products — those sold in every country where AdventureWorks has customers.
SELECT
    DP.ProductKey,
    DP.EnglishProductName AS ProductName,
    COUNT(DISTINCT DG.EnglishCountryRegionName) AS CountriesSoldIn
FROM dbo.DimProduct AS DP
INNER JOIN dbo.FactInternetSales AS FIS
    ON DP.ProductKey = FIS.ProductKey
INNER JOIN dbo.DimCustomer AS DC
    ON FIS.CustomerKey = DC.CustomerKey
INNER JOIN dbo.DimGeography AS DG
    ON DC.GeographyKey = DG.GeographyKey
GROUP BY
    DP.ProductKey,
    DP.EnglishProductName
HAVING COUNT(DISTINCT DG.EnglishCountryRegionName) =
(
    SELECT COUNT(DISTINCT DG2.EnglishCountryRegionName)
    FROM dbo.DimCustomer AS DC2
    INNER JOIN dbo.DimGeography AS DG2
        ON DC2.GeographyKey = DG2.GeographyKey
)
ORDER BY
    DP.EnglishProductName

--Q54. Find year-after-year loyalists — customers who purchased in every year present in the dataset.
SELECT
    DC.CustomerKey,
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName
FROM dbo.DimCustomer AS DC
WHERE NOT EXISTS
(
    -- Find a sales year in the dataset...
    SELECT DISTINCT
        YEAR(FIS_All.OrderDate) AS SalesYear
    FROM dbo.FactInternetSales AS FIS_All
    WHERE NOT EXISTS
    (
        -- ...in which the current customer made a purchase.
        SELECT 1
        FROM dbo.FactInternetSales AS FIS_Customer
        WHERE FIS_Customer.CustomerKey = DC.CustomerKey
          AND YEAR(FIS_Customer.OrderDate) =
              YEAR(FIS_All.OrderDate)
    )
)
ORDER BY
    CustomerName

--Q55. Find category completists — customers who purchased every product within a category (e.g., Mountain Bikes).
SELECT
    DC.CustomerKey,
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName
FROM dbo.DimCustomer AS DC
WHERE NOT EXISTS
(
    -- Find a Mountain Bikes product...
    SELECT 1
    FROM dbo.DimProduct AS DP
    INNER JOIN dbo.DimProductSubcategory AS DPSC
        ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
    WHERE DPSC.EnglishProductSubcategoryName = 'Mountain Bikes'
      AND NOT EXISTS
      (
          -- ...that the current customer has not purchased.
          SELECT 1
          FROM dbo.FactInternetSales AS FIS
          WHERE FIS.CustomerKey = DC.CustomerKey
            AND FIS.ProductKey = DP.ProductKey
      )
)
ORDER BY
    CustomerName

--Q56. Find underperforming categories — those where more than 50% of products have never been sold.
SELECT
    DPC.ProductCategoryKey,
    DPC.EnglishProductCategoryName AS CategoryName,
    COUNT(DP.ProductKey) AS TotalProducts,
    SUM
    (
        CASE
            WHEN FIS.ProductKey IS NULL THEN 1
            ELSE 0
        END
    ) AS UnsoldProducts,
    ROUND
    (
        SUM
        (
            CASE
                WHEN FIS.ProductKey IS NULL THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(DP.ProductKey),
        2
    ) AS UnsoldPercentage
FROM dbo.DimProductCategory AS DPC
INNER JOIN dbo.DimProductSubcategory AS DPSC
    ON DPC.ProductCategoryKey = DPSC.ProductCategoryKey
INNER JOIN dbo.DimProduct AS DP
    ON DPSC.ProductSubcategoryKey = DP.ProductSubcategoryKey
LEFT JOIN
(
    SELECT DISTINCT
        ProductKey
    FROM dbo.FactInternetSales
) AS FIS
    ON DP.ProductKey = FIS.ProductKey
GROUP BY
    DPC.ProductCategoryKey,
    DPC.EnglishProductCategoryName
HAVING
    SUM
    (
        CASE
            WHEN FIS.ProductKey IS NULL THEN 1.0
            ELSE 0
        END
    ) / COUNT(DP.ProductKey) > 0.50
ORDER BY
    UnsoldPercentage DESC

--Q57. Find category revenue drivers — products contributing more than 5% of their category’s revenue.
WITH ProductRevenue AS
(
    SELECT
        DPC.ProductCategoryKey,
        DPC.EnglishProductCategoryName AS CategoryName,
        DP.ProductKey,
        DP.EnglishProductName AS ProductName,
        SUM(FIS.SalesAmount) AS ProductRevenue
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimProduct AS DP
        ON FIS.ProductKey = DP.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS DPSC
        ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS DPC
        ON DPSC.ProductCategoryKey = DPC.ProductCategoryKey
    GROUP BY
        DPC.ProductCategoryKey,
        DPC.EnglishProductCategoryName,
        DP.ProductKey,
        DP.EnglishProductName
),
CategoryRevenue AS
(
    SELECT
        ProductCategoryKey,
        SUM(ProductRevenue) AS TotalCategoryRevenue
    FROM ProductRevenue
    GROUP BY
        ProductCategoryKey
)
SELECT
    PR.ProductCategoryKey,
    PR.CategoryName,
    PR.ProductKey,
    PR.ProductName,
    ROUND(PR.ProductRevenue, 2) AS ProductRevenue,
    ROUND(CR.TotalCategoryRevenue, 2) AS TotalCategoryRevenue,
    ROUND(
        PR.ProductRevenue * 100.0
        / NULLIF(CR.TotalCategoryRevenue, 0),
        2
    ) AS CategoryRevenuePercentage
FROM ProductRevenue AS PR
INNER JOIN CategoryRevenue AS CR
    ON PR.ProductCategoryKey = CR.ProductCategoryKey
WHERE PR.ProductRevenue > CR.TotalCategoryRevenue * 0.05
ORDER BY
    PR.CategoryName,
    CategoryRevenuePercentage DESC

--Q58. Find the highest-revenue category — without using TOP.
WITH CategoryRevenue AS
(
    SELECT
        DPC.ProductCategoryKey,
        DPC.EnglishProductCategoryName AS CategoryName,
        SUM(FIS.SalesAmount) AS TotalRevenue
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimProduct AS DP
        ON FIS.ProductKey = DP.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS DPSC
        ON DP.ProductSubcategoryKey = DPSC.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS DPC
        ON DPSC.ProductCategoryKey = DPC.ProductCategoryKey
    GROUP BY
        DPC.ProductCategoryKey,
        DPC.EnglishProductCategoryName
)
SELECT
    ProductCategoryKey,
    CategoryName,
    ROUND(TotalRevenue, 2) AS TotalRevenue
FROM CategoryRevenue
WHERE TotalRevenue =
(
    SELECT MAX(TotalRevenue)
    FROM CategoryRevenue
)

--Q59. Find strategically critical accounts — customers whose spend is more than 1% of total company sales.
WITH CustomerSpend AS
(
    SELECT
        DC.CustomerKey,
        CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
        SUM(FIS.SalesAmount) AS TotalSpend
    FROM dbo.DimCustomer AS DC
    INNER JOIN dbo.FactInternetSales AS FIS
        ON DC.CustomerKey = FIS.CustomerKey
    GROUP BY
        DC.CustomerKey,
        DC.FirstName,
        DC.LastName
),
CompanySales AS
(
    SELECT
        SUM(SalesAmount) AS TotalCompanySales
    FROM dbo.FactInternetSales
)

SELECT
    CS.CustomerKey,
    CS.CustomerName,
    ROUND(CS.TotalSpend, 2) AS TotalSpend,
    ROUND(CS.TotalSpend * 100.0 / CTS.TotalCompanySales, 2)
        AS CompanySalesPercentage
FROM CustomerSpend AS CS
CROSS JOIN CompanySales AS CTS
WHERE CS.TotalSpend > CTS.TotalCompanySales * 0.01
ORDER BY
    CS.TotalSpend DESC

/*Q60. Produce a complete executive sales report: Year, Country, Total Customers, Total Orders, Total Sales, Average Order Value, Most Sold 
  Category, Highest Revenue Category — using only joins, aggregations, subqueries, CTEs, and built-in functions.
*/
WITH SalesDetails AS
(
    SELECT
        YEAR(FIS.OrderDate) AS SalesYear,
        DG.EnglishCountryRegionName AS Country,
        FIS.CustomerKey,
        FIS.SalesOrderNumber,
        FIS.OrderQuantity,
        FIS.SalesAmount,
        DPC.ProductCategoryKey,
        DPC.EnglishProductCategoryName AS CategoryName
    FROM dbo.FactInternetSales AS FIS
    INNER JOIN dbo.DimCustomer AS DC
        ON FIS.CustomerKey = DC.CustomerKey
    INNER JOIN dbo.DimGeography AS DG
        ON DC.GeographyKey = DG.GeographyKey
    INNER JOIN dbo.DimProduct AS DP
        ON FIS.ProductKey = DP.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS DPSC
        ON DP.ProductSubcategoryKey =
           DPSC.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS DPC
        ON DPSC.ProductCategoryKey =
           DPC.ProductCategoryKey
),
SalesSummary AS
(
    SELECT
        SalesYear,
        Country,
        COUNT(DISTINCT CustomerKey) AS TotalCustomers,
        COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
        SUM(SalesAmount) AS TotalSales,
        SUM(SalesAmount) /
            NULLIF(
                COUNT(DISTINCT SalesOrderNumber),
                0
            ) AS AverageOrderValue
    FROM SalesDetails
    GROUP BY
        SalesYear,
        Country
),
CategorySummary AS
(
    SELECT
        SalesYear,
        Country,
        ProductCategoryKey,
        CategoryName,
        SUM(OrderQuantity) AS TotalQuantitySold,
        SUM(SalesAmount) AS CategoryRevenue
    FROM SalesDetails
    GROUP BY
        SalesYear,
        Country,
        ProductCategoryKey,
        CategoryName
),
MostSoldCategory AS
(
    SELECT
        CS1.SalesYear,
        CS1.Country,
        CS1.ProductCategoryKey,
        CS1.CategoryName,
        CS1.TotalQuantitySold
    FROM CategorySummary AS CS1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM CategorySummary AS CS2
        WHERE CS2.SalesYear = CS1.SalesYear
          AND CS2.Country = CS1.Country
          AND
          (
              CS2.TotalQuantitySold >
                  CS1.TotalQuantitySold
              OR
              (
                  CS2.TotalQuantitySold =
                      CS1.TotalQuantitySold
                  AND CS2.CategoryName <
                      CS1.CategoryName
              )
          )
    )
),
HighestRevenueCategory AS
(
    SELECT
        CS1.SalesYear,
        CS1.Country,
        CS1.ProductCategoryKey,
        CS1.CategoryName,
        CS1.CategoryRevenue
    FROM CategorySummary AS CS1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM CategorySummary AS CS2
        WHERE CS2.SalesYear = CS1.SalesYear
          AND CS2.Country = CS1.Country
          AND
          (
              CS2.CategoryRevenue >
                  CS1.CategoryRevenue
              OR
              (
                  CS2.CategoryRevenue =
                      CS1.CategoryRevenue
                  AND CS2.CategoryName <
                      CS1.CategoryName
              )
          )
    )
)
SELECT
    SS.SalesYear AS [Year],
    SS.Country,
    SS.TotalCustomers,
    SS.TotalOrders,
    ROUND(SS.TotalSales, 2) AS TotalSales,
    ROUND(SS.AverageOrderValue, 2)
        AS AverageOrderValue,
    MSC.CategoryName AS MostSoldCategory,
    MSC.TotalQuantitySold
        AS MostSoldCategoryQuantity,
    HRC.CategoryName AS HighestRevenueCategory,
    ROUND(HRC.CategoryRevenue, 2)
        AS HighestRevenueCategoryRevenue
FROM SalesSummary AS SS
INNER JOIN MostSoldCategory AS MSC
    ON SS.SalesYear = MSC.SalesYear
    AND SS.Country = MSC.Country
INNER JOIN HighestRevenueCategory AS HRC
    ON SS.SalesYear = HRC.SalesYear
    AND SS.Country = HRC.Country
ORDER BY
    SS.SalesYear,
    SS.Country