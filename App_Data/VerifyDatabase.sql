-- EComJew Database Verification Script
-- Run this after creating the database to verify everything is set up correctly

USE EComJew
GO

PRINT '=============================================='
PRINT 'EComJew Database Verification'
PRINT '=============================================='
PRINT ''

-- 1. Check Vendors
PRINT '1. Checking Vendors...'
DECLARE @VendorCount INT
SELECT @VendorCount = COUNT(*) FROM Vendors
PRINT '   Total Vendors: ' + CAST(@VendorCount AS NVARCHAR(10))

IF @VendorCount = 5
    PRINT '   ? PASS: 5 vendors found'
ELSE
    PRINT '   ? FAIL: Expected 5 vendors, found ' + CAST(@VendorCount AS NVARCHAR(10))

PRINT ''

-- 2. Check Vendor Approval Status
PRINT '2. Checking Vendor Approval Status...'
DECLARE @ApprovedVendors INT
SELECT @ApprovedVendors = COUNT(*) FROM Vendors WHERE IsApproved = 1
PRINT '   Approved Vendors: ' + CAST(@ApprovedVendors AS NVARCHAR(10))

IF @ApprovedVendors = 5
    PRINT '   ? PASS: All vendors are approved'
ELSE
    PRINT '   ? FAIL: Not all vendors are approved'

PRINT ''

-- 3. Check Vendor Products
PRINT '3. Checking Vendor Products...'
DECLARE @ProductCount INT
SELECT @ProductCount = COUNT(*) FROM VendorProducts
PRINT '   Total Products: ' + CAST(@ProductCount AS NVARCHAR(10))

IF @ProductCount = 100
    PRINT '   ? PASS: 100 products found'
ELSE
    PRINT '   ? FAIL: Expected 100 products, found ' + CAST(@ProductCount AS NVARCHAR(10))

PRINT ''

-- 4. Check Product Distribution
PRINT '4. Checking Product Distribution by Vendor...'
SELECT 
    v.VendorId,
    v.BusinessName,
    COUNT(vp.VendorProductId) AS ProductCount,
    CASE 
        WHEN COUNT(vp.VendorProductId) = 20 THEN '? PASS'
        ELSE '? FAIL'
    END AS Status
FROM Vendors v
LEFT JOIN VendorProducts vp ON v.VendorId = vp.VendorId
GROUP BY v.VendorId, v.BusinessName
ORDER BY v.VendorId

PRINT ''

-- 5. Check ItemCode Range
PRINT '5. Checking ItemCode Range...'
DECLARE @MinItemCode NVARCHAR(50), @MaxItemCode NVARCHAR(50)
SELECT @MinItemCode = MIN(ItemCode), @MaxItemCode = MAX(ItemCode) FROM VendorProducts
PRINT '   Range: ' + @MinItemCode + ' to ' + @MaxItemCode

IF @MinItemCode = 'ITM001' AND @MaxItemCode = 'ITM100'
    PRINT '   ? PASS: ItemCode range is correct (ITM001 to ITM100)'
ELSE
    PRINT '   ? FAIL: ItemCode range is incorrect'

PRINT ''

-- 6. Check LotNo Range
PRINT '6. Checking LotNo Range...'
DECLARE @MinLotNo NVARCHAR(50), @MaxLotNo NVARCHAR(50)
SELECT @MinLotNo = MIN(LotNo), @MaxLotNo = MAX(LotNo) FROM VendorProducts
PRINT '   Range: ' + @MinLotNo + ' to ' + @MaxLotNo

IF @MinLotNo = 'LOT0001' AND @MaxLotNo = 'LOT0100'
    PRINT '   ? PASS: LotNo range is correct (LOT0001 to LOT0100)'
ELSE
    PRINT '   ? FAIL: LotNo range is incorrect'

PRINT ''

-- 7. Check Price Range
PRINT '7. Checking Price Range...'
DECLARE @MinPrice DECIMAL(18,2), @MaxPrice DECIMAL(18,2), @AvgPrice DECIMAL(18,2)
SELECT 
    @MinPrice = MIN(Price), 
    @MaxPrice = MAX(Price), 
    @AvgPrice = AVG(Price) 
FROM VendorProducts
PRINT '   Min Price: $' + CAST(@MinPrice AS NVARCHAR(20))
PRINT '   Max Price: $' + CAST(@MaxPrice AS NVARCHAR(20))
PRINT '   Avg Price: $' + CAST(@AvgPrice AS NVARCHAR(20))

IF @MinPrice = 1010.00 AND @MaxPrice = 2000.00
    PRINT '   ? PASS: Price range is correct ($1,010 to $2,000)'
ELSE
    PRINT '   ? FAIL: Price range is incorrect'

PRINT ''

-- 8. Check Stock Levels
PRINT '8. Checking Stock Levels...'
DECLARE @TotalStock INT, @MinStock INT, @MaxStock INT
SELECT 
    @TotalStock = SUM(StockAvailable), 
    @MinStock = MIN(StockAvailable), 
    @MaxStock = MAX(StockAvailable) 
FROM VendorProducts
PRINT '   Total Stock: ' + CAST(@TotalStock AS NVARCHAR(20)) + ' units'
PRINT '   Min Stock: ' + CAST(@MinStock AS NVARCHAR(20)) + ' units'
PRINT '   Max Stock: ' + CAST(@MaxStock AS NVARCHAR(20)) + ' units'

IF @TotalStock = 6055
    PRINT '   ? PASS: Total stock is correct (6,055 units)'
ELSE
    PRINT '   ? FAIL: Total stock is incorrect (expected 6,055, found ' + CAST(@TotalStock AS NVARCHAR(20)) + ')'

PRINT ''

-- 9. Check Diamond Products
PRINT '9. Checking Diamond Products...'
DECLARE @DiamondCount INT
SELECT @DiamondCount = COUNT(*) FROM VendorProducts WHERE Stones = 'Diamond'
PRINT '   Diamond Products: ' + CAST(@DiamondCount AS NVARCHAR(10))

IF @DiamondCount = 20
    PRINT '   ? PASS: 20 diamond products found'
ELSE
    PRINT '   ? FAIL: Expected 20 diamond products, found ' + CAST(@DiamondCount AS NVARCHAR(10))

PRINT ''

-- 10. Check Categories
PRINT '10. Checking Product Categories...'
SELECT 
    Category,
    COUNT(*) AS ProductCount,
    CASE 
        WHEN COUNT(*) = 50 THEN '? PASS'
        ELSE '? FAIL'
    END AS Status
FROM VendorProducts
GROUP BY Category
ORDER BY Category

PRINT ''

-- 11. Check Materials
PRINT '11. Checking Product Materials...'
SELECT 
    Material,
    COUNT(*) AS ProductCount,
    AVG(Price) AS AvgPrice
FROM VendorProducts
GROUP BY Material
ORDER BY Material

PRINT ''

-- 12. Check Active Products
PRINT '12. Checking Active Products...'
DECLARE @ActiveCount INT
SELECT @ActiveCount = COUNT(*) FROM VendorProducts WHERE IsActive = 1
PRINT '   Active Products: ' + CAST(@ActiveCount AS NVARCHAR(10))

IF @ActiveCount = 100
    PRINT '   ? PASS: All products are active'
ELSE
    PRINT '   ? FAIL: Not all products are active'

PRINT ''

-- 13. Check Stored Procedures
PRINT '13. Checking Stored Procedures...'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_VendorLogin')
    PRINT '   ? sp_VendorLogin exists'
ELSE
    PRINT '   ? sp_VendorLogin NOT FOUND'

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_AdminLogin')
    PRINT '   ? sp_AdminLogin exists'
ELSE
    PRINT '   ? sp_AdminLogin NOT FOUND'

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CustomerLogin')
    PRINT '   ? sp_CustomerLogin exists'
ELSE
    PRINT '   ? sp_CustomerLogin NOT FOUND'

PRINT ''

-- 14. Check Roles
PRINT '14. Checking Roles...'
SELECT 
    RoleId,
    RoleName,
    Description
FROM Roles
ORDER BY RoleId

DECLARE @RoleCount INT
SELECT @RoleCount = COUNT(*) FROM Roles
IF @RoleCount >= 4
    PRINT '   ? PASS: All required roles exist (including Vendor)'
ELSE
    PRINT '   ? FAIL: Missing roles (expected 4+)'

PRINT ''

-- 15. Check Foreign Keys
PRINT '15. Checking Foreign Keys...'
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_VendorProducts_Vendors')
    PRINT '   ? FK_VendorProducts_Vendors exists'
ELSE
    PRINT '   ? FK_VendorProducts_Vendors NOT FOUND'

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_VendorActivityLog_Vendors')
    PRINT '   ? FK_VendorActivityLog_Vendors exists'
ELSE
    PRINT '   ? FK_VendorActivityLog_Vendors NOT FOUND'

PRINT ''

-- 16. Check Unique Constraints
PRINT '16. Checking Unique Constraints...'
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_VendorProduct')
    PRINT '   ? UQ_VendorProduct (VendorId, ItemCode, LotNo) exists'
ELSE
    PRINT '   ? UQ_VendorProduct NOT FOUND'

PRINT ''

-- 17. Calculate Inventory Value
PRINT '17. Calculating Inventory Value...'
DECLARE @TotalValue MONEY
SELECT @TotalValue = SUM(Price * StockAvailable) FROM VendorProducts
PRINT '   Total Inventory Value: $' + CAST(@TotalValue AS NVARCHAR(20))
PRINT '   (This is the total value of all products in stock)'

PRINT ''

-- 18. Top 5 Most Expensive Products
PRINT '18. Top 5 Most Expensive Products:'
SELECT TOP 5
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Material,
    vp.Stones,
    vp.Price
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
ORDER BY vp.Price DESC

PRINT ''

-- 19. Products with Lowest Stock
PRINT '19. Products with Lowest Stock (Bottom 5):'
SELECT TOP 5
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.StockAvailable
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
ORDER BY vp.StockAvailable ASC

PRINT ''

-- 20. Summary Report
PRINT '=============================================='
PRINT 'SUMMARY REPORT'
PRINT '=============================================='
PRINT ''
PRINT 'Database: EComJew'
PRINT 'Vendors: ' + CAST(@VendorCount AS NVARCHAR(10)) + ' (All approved)'
PRINT 'Products: ' + CAST(@ProductCount AS NVARCHAR(10)) + ' (All active)'
PRINT 'Total Stock: ' + CAST(@TotalStock AS NVARCHAR(20)) + ' units'
PRINT 'Inventory Value: $' + CAST(@TotalValue AS NVARCHAR(20))
PRINT 'Price Range: $' + CAST(@MinPrice AS NVARCHAR(20)) + ' - $' + CAST(@MaxPrice AS NVARCHAR(20))
PRINT 'Diamond Products: ' + CAST(@DiamondCount AS NVARCHAR(10))
PRINT ''
PRINT '=============================================='
PRINT 'VERIFICATION COMPLETE!'
PRINT '=============================================='
PRINT ''

-- Final Status
DECLARE @TotalTests INT = 16
DECLARE @PassedTests INT = 0

-- Count passed tests
IF @VendorCount = 5 SET @PassedTests = @PassedTests + 1
IF @ApprovedVendors = 5 SET @PassedTests = @PassedTests + 1
IF @ProductCount = 100 SET @PassedTests = @PassedTests + 1
IF @MinItemCode = 'ITM001' AND @MaxItemCode = 'ITM100' SET @PassedTests = @PassedTests + 1
IF @MinLotNo = 'LOT0001' AND @MaxLotNo = 'LOT0100' SET @PassedTests = @PassedTests + 1
IF @MinPrice = 1010.00 AND @MaxPrice = 2000.00 SET @PassedTests = @PassedTests + 1
IF @TotalStock = 6055 SET @PassedTests = @PassedTests + 1
IF @DiamondCount = 20 SET @PassedTests = @PassedTests + 1
IF @ActiveCount = 100 SET @PassedTests = @PassedTests + 1
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_VendorLogin') SET @PassedTests = @PassedTests + 1
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_AdminLogin') SET @PassedTests = @PassedTests + 1
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CustomerLogin') SET @PassedTests = @PassedTests + 1
IF @RoleCount >= 4 SET @PassedTests = @PassedTests + 1
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_VendorProducts_Vendors') SET @PassedTests = @PassedTests + 1
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_VendorProduct') SET @PassedTests = @PassedTests + 1

PRINT 'Tests Passed: ' + CAST(@PassedTests AS NVARCHAR(10)) + '/' + CAST(@TotalTests AS NVARCHAR(10))

IF @PassedTests = @TotalTests
BEGIN
    PRINT ''
    PRINT '??? ALL TESTS PASSED! ???'
    PRINT 'Database is ready for development!'
END
ELSE
BEGIN
    PRINT ''
    PRINT '? SOME TESTS FAILED ?'
    PRINT 'Please review the output above for details.'
END

PRINT ''
PRINT '=============================================='
GO
