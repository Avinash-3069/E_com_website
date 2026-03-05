# EComJew Vendor System - Quick Reference

## ?? Quick Start

### 1. Create Database
Run the database creation script:
```powershell
# Using PowerShell
.\CreateDatabase.ps1

# Or using SQL Server Management Studio
# Open and execute: App_Data\CreateEComJewDatabase.sql
```

### 2. Verify Installation
Check that vendors and products were created:
```sql
USE EComJew
GO

-- Check vendors
SELECT VendorId, VendorUserName, BusinessName, Rating 
FROM Vendors
ORDER BY VendorId;

-- Check products count
SELECT 
    v.VendorId,
    v.BusinessName,
    COUNT(vp.VendorProductId) AS ProductCount
FROM Vendors v
LEFT JOIN VendorProducts vp ON v.VendorId = vp.VendorId
GROUP BY v.VendorId, v.BusinessName
ORDER BY v.VendorId;
```

Expected Output:
```
VendorId | VendorUserName | BusinessName            | Rating
---------|----------------|-------------------------|-------
1        | vendor1        | Premium Jewelers Inc    | 4.50
2        | vendor2        | Golden Touch Jewelry    | 4.20
3        | vendor3        | Silver Dreams Ltd       | 4.70
4        | vendor4        | Diamond Palace          | 4.80
5        | vendor5        | Luxury Gems Co          | 4.30

VendorId | BusinessName            | ProductCount
---------|-------------------------|-------------
1        | Premium Jewelers Inc    | 20
2        | Golden Touch Jewelry    | 20
3        | Silver Dreams Ltd       | 20
4        | Diamond Palace          | 20
5        | Luxury Gems Co          | 20
```

---

## ?? Authentication

### Vendor Login
All test vendors use the same password:

| Username | Email | Password | Status |
|----------|-------|----------|--------|
| vendor1 | vendor1@ecomjew.com | Vendor@123 | Approved |
| vendor2 | vendor2@ecomjew.com | Vendor@123 | Approved |
| vendor3 | vendor3@ecomjew.com | Vendor@123 | Approved |
| vendor4 | vendor4@ecomjew.com | Vendor@123 | Approved |
| vendor5 | vendor5@ecomjew.com | Vendor@123 | Approved |

### Login Stored Procedure
```sql
EXEC sp_VendorLogin 
    @UserName = 'vendor1',
    @PasswordHash = 'your_hashed_password'
```

**Response Types:**
- `SUCCESS` - Login successful, returns vendor details
- `PENDING` - Account awaiting admin approval
- `LOCKED` - Account locked after failed attempts
- `ERROR` - Invalid credentials

---

## ?? Product Management

### View All Products for a Vendor
```sql
-- Vendor 1's products
SELECT 
    ItemCode,
    LotNo,
    ProductName,
    Price,
    Category,
    Material,
    Stones,
    Karatage,
    StockAvailable
FROM VendorProducts
WHERE VendorId = 1
ORDER BY ItemCode;
```

### Find Products by Category
```sql
-- All jewelry items
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Price,
    vp.StockAvailable
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.Category = 'Jewelry'
ORDER BY vp.Price DESC;
```

### Find Diamond Products
```sql
-- All products with diamonds
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Material,
    vp.Karatage,
    vp.Price
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.Stones = 'Diamond'
ORDER BY vp.Price DESC;
```

### Find Gold vs Silver Products
```sql
-- Count by material
SELECT 
    Material,
    COUNT(*) AS ProductCount,
    AVG(Price) AS AvgPrice,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice
FROM VendorProducts
GROUP BY Material;
```

### Low Stock Alert
```sql
-- Products with less than 30 units
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.StockAvailable
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.StockAvailable < 30
ORDER BY vp.StockAvailable;
```

---

## ?? Analytics Queries

### Vendor Performance Overview
```sql
SELECT 
    v.VendorId,
    v.BusinessName,
    v.Rating,
    COUNT(vp.VendorProductId) AS TotalProducts,
    SUM(vp.StockAvailable) AS TotalStock,
    AVG(vp.Price) AS AvgPrice,
    MIN(vp.Price) AS MinPrice,
    MAX(vp.Price) AS MaxPrice,
    SUM(vp.Price * vp.StockAvailable) AS TotalInventoryValue
FROM Vendors v
LEFT JOIN VendorProducts vp ON v.VendorId = vp.VendorId
WHERE v.IsActive = 1
GROUP BY v.VendorId, v.BusinessName, v.Rating
ORDER BY TotalInventoryValue DESC;
```

### Product Distribution by Karatage
```sql
SELECT 
    Karatage,
    Material,
    COUNT(*) AS ProductCount,
    AVG(Price) AS AvgPrice
FROM VendorProducts
GROUP BY Karatage, Material
ORDER BY Material, Karatage;
```

### Price Range Distribution
```sql
SELECT 
    CASE 
        WHEN Price < 1200 THEN 'Under $1,200'
        WHEN Price < 1400 THEN '$1,200 - $1,400'
        WHEN Price < 1600 THEN '$1,400 - $1,600'
        WHEN Price < 1800 THEN '$1,600 - $1,800'
        ELSE 'Over $1,800'
    END AS PriceRange,
    COUNT(*) AS ProductCount
FROM VendorProducts
GROUP BY 
    CASE 
        WHEN Price < 1200 THEN 'Under $1,200'
        WHEN Price < 1400 THEN '$1,200 - $1,400'
        WHEN Price < 1600 THEN '$1,400 - $1,600'
        WHEN Price < 1800 THEN '$1,600 - $1,800'
        ELSE 'Over $1,800'
    END
ORDER BY MIN(Price);
```

---

## ??? Product CRUD Operations

### Add New Product
```sql
INSERT INTO VendorProducts (
    VendorId, ItemCode, LotNo, ProductName, Description,
    Price, UOM, Category, Material, Stones, Karatage,
    StockAvailable, ProductImage, IsActive
)
VALUES (
    1, 'ITM101', 'LOT0101', 'Custom Gold Ring', 'Beautiful custom design',
    2500.00, 'PCS', 'Jewelry', 'Gold', 'Diamond', '18K',
    50, 'img101.jpg', 1
);
```

### Update Product Price
```sql
UPDATE VendorProducts
SET Price = 1150.00, UpdatedDate = GETDATE()
WHERE ItemCode = 'ITM001' AND VendorId = 1;
```

### Update Stock
```sql
UPDATE VendorProducts
SET StockAvailable = StockAvailable - 5, UpdatedDate = GETDATE()
WHERE ItemCode = 'ITM001' AND VendorId = 1;
```

### Deactivate Product
```sql
UPDATE VendorProducts
SET IsActive = 0, UpdatedDate = GETDATE()
WHERE ItemCode = 'ITM001' AND VendorId = 1;
```

### Delete Product
```sql
DELETE FROM VendorProducts
WHERE ItemCode = 'ITM001' AND VendorId = 1;
```

---

## ?? Search Queries

### Search by Product Name
```sql
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Price,
    vp.Material,
    vp.StockAvailable
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.ProductName LIKE '%Ring%'
ORDER BY vp.Price;
```

### Search by Price Range
```sql
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Price,
    vp.Material
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.Price BETWEEN 1500 AND 1700
ORDER BY vp.Price;
```

### Filter by Multiple Criteria
```sql
-- Gold products with diamonds, priced over $1500
SELECT 
    v.BusinessName,
    vp.ItemCode,
    vp.ProductName,
    vp.Price,
    vp.Karatage,
    vp.StockAvailable
FROM VendorProducts vp
INNER JOIN Vendors v ON vp.VendorId = v.VendorId
WHERE vp.Material = 'Gold'
  AND vp.Stones = 'Diamond'
  AND vp.Price > 1500
ORDER BY vp.Price DESC;
```

---

## ?? Vendor Dashboard Queries

### Vendor Summary Dashboard
```sql
-- For Vendor ID = 1
DECLARE @VendorId INT = 1;

SELECT 
    'Total Products' AS Metric,
    COUNT(*) AS Value
FROM VendorProducts
WHERE VendorId = @VendorId AND IsActive = 1

UNION ALL

SELECT 
    'Total Stock',
    SUM(StockAvailable)
FROM VendorProducts
WHERE VendorId = @VendorId AND IsActive = 1

UNION ALL

SELECT 
    'Average Price',
    AVG(Price)
FROM VendorProducts
WHERE VendorId = @VendorId AND IsActive = 1

UNION ALL

SELECT 
    'Inventory Value',
    SUM(Price * StockAvailable)
FROM VendorProducts
WHERE VendorId = @VendorId AND IsActive = 1;
```

### Top 10 Most Expensive Products by Vendor
```sql
SELECT TOP 10
    ItemCode,
    ProductName,
    Price,
    Material,
    Stones,
    StockAvailable
FROM VendorProducts
WHERE VendorId = 1 AND IsActive = 1
ORDER BY Price DESC;
```

### Products Needing Restock
```sql
-- Products with stock below 20 units
SELECT 
    ItemCode,
    ProductName,
    Category,
    StockAvailable,
    Price
FROM VendorProducts
WHERE VendorId = 1 
  AND IsActive = 1
  AND StockAvailable < 20
ORDER BY StockAvailable;
```

---

## ?? Sample API Responses

### Successful Login Response
```json
{
  "Status": "SUCCESS",
  "VendorId": 1,
  "VendorUserName": "vendor1",
  "VendorEmail": "vendor1@ecomjew.com",
  "VendorFirstName": "John",
  "VendorLastName": "Smith",
  "BusinessName": "Premium Jewelers Inc",
  "Rating": 4.5
}
```

### Pending Approval Response
```json
{
  "Status": "PENDING",
  "Message": "Your vendor account is pending approval. Please contact support."
}
```

### Locked Account Response
```json
{
  "Status": "LOCKED",
  "Message": "Account is locked. Please try again later or contact support."
}
```

---

## ?? Related Documentation

- **Main Guide**: `App_Data/AuthenticationGuide.md`
- **Vendor Guide**: `App_Data/VendorGuide.md`
- **Product Summary**: `App_Data/VENDOR_PRODUCT_SUMMARY.md`
- **Database README**: `App_Data/README.md`

---

## ?? Important Notes

1. **Password Hashing**: The sample passwords are placeholders. Implement BCrypt or PBKDF2 in your application.
2. **Image Paths**: Update `ProductImage` paths to actual image URLs.
3. **Stock Management**: Implement proper inventory management to prevent overselling.
4. **Approval Workflow**: Implement admin approval UI for new vendors.
5. **Testing**: All vendors are pre-approved for testing purposes.

---

## ?? Troubleshooting

### Vendor Can't Login
1. Check if vendor is approved: `SELECT IsApproved FROM Vendors WHERE VendorUserName = 'vendor1'`
2. Check if account is locked: `SELECT IsLocked, LockoutEnd FROM Vendors WHERE VendorUserName = 'vendor1'`
3. Verify password hash matches

### Products Not Showing
1. Check if products are active: `SELECT COUNT(*) FROM VendorProducts WHERE IsActive = 1`
2. Verify vendor ID is correct
3. Check foreign key relationships

### Stock Issues
1. Verify stock is not negative: `SELECT * FROM VendorProducts WHERE StockAvailable < 0`
2. Check for orphaned products: Products without valid VendorId

---

**Version**: 1.0
**Last Updated**: 2024
**Support**: https://github.com/Avinash-3069/E_com_website
