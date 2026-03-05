-- EComJew Database Creation Script
-- E-commerce Website Database for Jewelry/Products
-- Repository: https://github.com/Avinash-3069/E_com_website.git

USE master
GO

-- Create the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'EComJew')
BEGIN
    CREATE DATABASE EComJew
END
GO

USE EComJew
GO

-- Roles Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE Roles (
        RoleId INT PRIMARY KEY IDENTITY(1,1),
        RoleName NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(255),
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Users/Customers Table with Role-based Authentication
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId INT PRIMARY KEY IDENTITY(1,1),
        UserName NVARCHAR(100) NOT NULL UNIQUE,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        PasswordSalt NVARCHAR(255),
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        PhoneNumber NVARCHAR(20),
        DateRegistered DATETIME DEFAULT GETDATE(),
        LastLogin DATETIME,
        IsActive BIT DEFAULT 1,
        RoleId INT FOREIGN KEY REFERENCES Roles(RoleId),
        FailedLoginAttempts INT DEFAULT 0,
        IsLocked BIT DEFAULT 0,
        LockoutEnd DATETIME NULL
    )
END
GO

-- Admin Users Table (Separate login for admin dashboard)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AdminUsers')
BEGIN
    CREATE TABLE AdminUsers (
        AdminId INT PRIMARY KEY IDENTITY(1,1),
        AdminUserName NVARCHAR(100) NOT NULL UNIQUE,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        PasswordSalt NVARCHAR(255),
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        PhoneNumber NVARCHAR(20),
        DateCreated DATETIME DEFAULT GETDATE(),
        LastLogin DATETIME,
        IsActive BIT DEFAULT 1,
        IsSuperAdmin BIT DEFAULT 0,
        FailedLoginAttempts INT DEFAULT 0,
        IsLocked BIT DEFAULT 0,
        LockoutEnd DATETIME NULL
    )
END
GO

-- Admin Activity Log Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AdminActivityLog')
BEGIN
    CREATE TABLE AdminActivityLog (
        LogId INT PRIMARY KEY IDENTITY(1,1),
        AdminId INT FOREIGN KEY REFERENCES AdminUsers(AdminId),
        Activity NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        IPAddress NVARCHAR(50),
        ActivityDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- User Activity Log Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserActivityLog')
BEGIN
    CREATE TABLE UserActivityLog (
        LogId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        Activity NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        IPAddress NVARCHAR(50),
        ActivityDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Categories Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categories')
BEGIN
    CREATE TABLE Categories (
        CategoryId INT PRIMARY KEY IDENTITY(1,1),
        CategoryName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Products Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE Products (
        ProductId INT PRIMARY KEY IDENTITY(1,1),
        ProductName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX),
        Price DECIMAL(18, 2) NOT NULL,
        CategoryId INT FOREIGN KEY REFERENCES Categories(CategoryId),
        StockQuantity INT DEFAULT 0,
        ImageUrl NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME
    )
END
GO

-- Orders Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
BEGIN
    CREATE TABLE Orders (
        OrderId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(18, 2) NOT NULL,
        OrderStatus NVARCHAR(50) DEFAULT 'Pending',
        ShippingAddress NVARCHAR(500),
        PaymentMethod NVARCHAR(50),
        PaymentStatus NVARCHAR(50) DEFAULT 'Pending'
    )
END
GO

-- OrderDetails Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderDetails')
BEGIN
    CREATE TABLE OrderDetails (
        OrderDetailId INT PRIMARY KEY IDENTITY(1,1),
        OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
        ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(18, 2) NOT NULL,
        Subtotal DECIMAL(18, 2) NOT NULL
    )
END
GO

-- ShoppingCart Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ShoppingCart')
BEGIN
    CREATE TABLE ShoppingCart (
        CartId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
        Quantity INT NOT NULL,
        AddedDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Addresses Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Addresses')
BEGIN
    CREATE TABLE Addresses (
        AddressId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        AddressLine1 NVARCHAR(255) NOT NULL,
        AddressLine2 NVARCHAR(255),
        City NVARCHAR(100) NOT NULL,
        State NVARCHAR(100),
        PostalCode NVARCHAR(20),
        Country NVARCHAR(100) NOT NULL,
        IsDefault BIT DEFAULT 0
    )
END
GO

-- Reviews Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
BEGIN
    CREATE TABLE Reviews (
        ReviewId INT PRIMARY KEY IDENTITY(1,1),
        ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        Rating INT CHECK (Rating >= 1 AND Rating <= 5),
        ReviewText NVARCHAR(MAX),
        ReviewDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Insert sample categories
IF NOT EXISTS (SELECT * FROM Categories)
BEGIN
    INSERT INTO Categories (CategoryName, Description) VALUES
    ('Rings', 'Beautiful rings for all occasions'),
    ('Necklaces', 'Elegant necklaces and pendants'),
    ('Earrings', 'Stunning earrings collection'),
    ('Bracelets', 'Stylish bracelets and bangles'),
    ('Watches', 'Premium watches collection')
END
GO

-- Vendors Table (for multi-vendor marketplace)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Vendors')
BEGIN
    CREATE TABLE Vendors (
        VendorId INT PRIMARY KEY IDENTITY(1,1),
        VendorUserName NVARCHAR(100) NOT NULL UNIQUE,
        VendorEmail NVARCHAR(255) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        PasswordSalt NVARCHAR(255),
        VendorFirstName NVARCHAR(100),
        VendorLastName NVARCHAR(100),
        BusinessName NVARCHAR(200),
        PhoneNumber NVARCHAR(20),
        BusinessAddress NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        IsApproved BIT DEFAULT 0,
        Rating DECIMAL(3, 2) DEFAULT 0.00,
        DateRegistered DATETIME DEFAULT GETDATE(),
        LastLogin DATETIME,
        FailedLoginAttempts INT DEFAULT 0,
        IsLocked BIT DEFAULT 0,
        LockoutEnd DATETIME NULL
    )
END
GO

-- VendorProducts Table (Products managed by vendors)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VendorProducts')
BEGIN
    CREATE TABLE VendorProducts (
        VendorProductId INT PRIMARY KEY IDENTITY(1,1),
        VendorId INT NOT NULL FOREIGN KEY REFERENCES Vendors(VendorId),
        ItemCode NVARCHAR(50) NOT NULL,
        LotNo NVARCHAR(50) NOT NULL,
        ProductName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX),
        Price DECIMAL(18, 2) NOT NULL,
        UOM NVARCHAR(20),
        Category NVARCHAR(50),
        Material NVARCHAR(50),
        Stones NVARCHAR(100),
        Karatage NVARCHAR(20),
        StockAvailable INT DEFAULT 0,
        ProductImage NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME,
        CONSTRAINT UQ_VendorProduct UNIQUE (VendorId, ItemCode, LotNo)
    )
END
GO

-- Vendor Activity Log Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VendorActivityLog')
BEGIN
    CREATE TABLE VendorActivityLog (
        LogId INT PRIMARY KEY IDENTITY(1,1),
        VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId),
        Activity NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        IPAddress NVARCHAR(50),
        ActivityDate DATETIME DEFAULT GETDATE()
    )
END
GO

-- Insert default roles
IF NOT EXISTS (SELECT * FROM Roles)
BEGIN
    INSERT INTO Roles (RoleName, Description) VALUES
    ('Admin', 'Administrator with full access to dashboard and system'),
    ('Customer', 'Regular customer with website access'),
    ('Manager', 'Store manager with limited admin access'),
    ('Vendor', 'Vendor with access to manage their products')
END
GO

-- Insert default admin user
-- Password: Admin@123 (This is hashed - change after first login!)
IF NOT EXISTS (SELECT * FROM AdminUsers WHERE AdminUserName = 'admin')
BEGIN
    INSERT INTO AdminUsers (AdminUserName, Email, PasswordHash, PasswordSalt, FirstName, LastName, IsActive, IsSuperAdmin)
    VALUES 
    ('admin', 'admin@ecomjew.com', 
     'AQAAAAEAACcQAAAAEFVzZXJfSGFzaGVkX1Bhc3N3b3JkX0hlcmU=',
     'U2FsdF9WYWx1ZV9IZXJl',
     'System', 'Administrator', 1, 1)
END
GO

-- Insert sample customer user
-- Password: Customer@123 (This is hashed - for testing only!)
IF NOT EXISTS (SELECT * FROM Users WHERE UserName = 'customer')
BEGIN
    DECLARE @CustomerRoleId INT
    SELECT @CustomerRoleId = RoleId FROM Roles WHERE RoleName = 'Customer'
    
    INSERT INTO Users (UserName, Email, PasswordHash, PasswordSalt, FirstName, LastName, IsActive, RoleId)
    VALUES 
    ('customer', 'customer@example.com',
     'AQAAAAEAACcQAAAAEFVzZXJfSGFzaGVkX1Bhc3N3b3JkX0hlcmU=',
     'U2FsdF9WYWx1ZV9IZXJl',
     'Test', 'Customer', 1, @CustomerRoleId)
END
GO

-- Create views for Admin Dashboard

-- View: Dashboard Overview Statistics
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_DashboardStats')
    DROP VIEW vw_DashboardStats
GO

CREATE VIEW vw_DashboardStats AS
SELECT 
    (SELECT COUNT(*) FROM Users WHERE IsActive = 1) AS TotalCustomers,
    (SELECT COUNT(*) FROM Products WHERE IsActive = 1) AS TotalProducts,
    (SELECT COUNT(*) FROM Orders WHERE OrderDate >= DATEADD(MONTH, -1, GETDATE())) AS OrdersThisMonth,
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE OrderDate >= DATEADD(MONTH, -1, GETDATE())) AS RevenueThisMonth,
    (SELECT COUNT(*) FROM Orders WHERE OrderStatus = 'Pending') AS PendingOrders,
    (SELECT COUNT(*) FROM Products WHERE StockQuantity < 10) AS LowStockProducts
GO

-- View: Recent Orders for Dashboard
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_RecentOrders')
    DROP VIEW vw_RecentOrders
GO

CREATE VIEW vw_RecentOrders AS
SELECT TOP 50
    o.OrderId,
    o.OrderDate,
    u.UserName,
    u.Email,
    o.TotalAmount,
    o.OrderStatus,
    o.PaymentStatus,
    o.PaymentMethod
FROM Orders o
INNER JOIN Users u ON o.UserId = u.UserId
ORDER BY o.OrderDate DESC
GO

-- View: Top Selling Products
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_TopSellingProducts')
    DROP VIEW vw_TopSellingProducts
GO

CREATE VIEW vw_TopSellingProducts AS
SELECT TOP 10
    p.ProductId,
    p.ProductName,
    p.Price,
    c.CategoryName,
    SUM(od.Quantity) AS TotalSold,
    SUM(od.Subtotal) AS TotalRevenue
FROM Products p
INNER JOIN Categories c ON p.CategoryId = c.CategoryId
INNER JOIN OrderDetails od ON p.ProductId = od.ProductId
GROUP BY p.ProductId, p.ProductName, p.Price, c.CategoryName
ORDER BY TotalSold DESC
GO

-- View: Customer Orders (for customer portal)
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CustomerOrders')
    DROP VIEW vw_CustomerOrders
GO

CREATE VIEW vw_CustomerOrders AS
SELECT 
    o.OrderId,
    o.UserId,
    o.OrderDate,
    o.TotalAmount,
    o.OrderStatus,
    o.PaymentStatus,
    o.ShippingAddress,
    COUNT(od.OrderDetailId) AS ItemCount
FROM Orders o
LEFT JOIN OrderDetails od ON o.OrderId = od.OrderId
GROUP BY o.OrderId, o.UserId, o.OrderDate, o.TotalAmount, o.OrderStatus, o.PaymentStatus, o.ShippingAddress
GO

-- Stored Procedure: Admin Login
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_AdminLogin')
    DROP PROCEDURE sp_AdminLogin
GO

CREATE PROCEDURE sp_AdminLogin
    @UserName NVARCHAR(100),
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AdminId INT, @IsLocked BIT, @LockoutEnd DATETIME, @FailedAttempts INT
    
    -- Check if admin exists and get lock status
    SELECT 
        @AdminId = AdminId,
        @IsLocked = IsLocked,
        @LockoutEnd = LockoutEnd,
        @FailedAttempts = FailedLoginAttempts
    FROM AdminUsers 
    WHERE AdminUserName = @UserName AND IsActive = 1
    
    IF @AdminId IS NULL
    BEGIN
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
        RETURN
    END
    
    -- Check if account is locked
    IF @IsLocked = 1 AND (@LockoutEnd IS NULL OR @LockoutEnd > GETDATE())
    BEGIN
        SELECT 'LOCKED' AS Status, 'Account is locked. Contact system administrator.' AS Message
        RETURN
    END
    
    -- Verify password
    IF EXISTS (SELECT 1 FROM AdminUsers WHERE AdminId = @AdminId AND PasswordHash = @PasswordHash)
    BEGIN
        -- Successful login
        UPDATE AdminUsers 
        SET LastLogin = GETDATE(), FailedLoginAttempts = 0, IsLocked = 0, LockoutEnd = NULL
        WHERE AdminId = @AdminId
        
        -- Log the activity
        INSERT INTO AdminActivityLog (AdminId, Activity, Description)
        VALUES (@AdminId, 'Login', 'Admin user logged in successfully')
        
        -- Return admin details
        SELECT 
            'SUCCESS' AS Status,
            AdminId,
            AdminUserName,
            Email,
            FirstName,
            LastName,
            IsSuperAdmin
        FROM AdminUsers 
        WHERE AdminId = @AdminId
    END
    ELSE
    BEGIN
        -- Failed login
        UPDATE AdminUsers 
        SET FailedLoginAttempts = FailedLoginAttempts + 1,
            IsLocked = CASE WHEN FailedLoginAttempts >= 4 THEN 1 ELSE 0 END,
            LockoutEnd = CASE WHEN FailedLoginAttempts >= 4 THEN DATEADD(MINUTE, 30, GETDATE()) ELSE NULL END
        WHERE AdminId = @AdminId
        
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
    END
END
GO

-- Stored Procedure: Customer Login
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CustomerLogin')
    DROP PROCEDURE sp_CustomerLogin
GO

CREATE PROCEDURE sp_CustomerLogin
    @UserName NVARCHAR(100),
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT, @IsLocked BIT, @LockoutEnd DATETIME, @FailedAttempts INT
    
    -- Check if user exists and get lock status
    SELECT 
        @UserId = UserId,
        @IsLocked = IsLocked,
        @LockoutEnd = LockoutEnd,
        @FailedAttempts = FailedLoginAttempts
    FROM Users 
    WHERE UserName = @UserName AND IsActive = 1
    
    IF @UserId IS NULL
    BEGIN
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
        RETURN
    END
    
    -- Check if account is locked
    IF @IsLocked = 1 AND (@LockoutEnd IS NULL OR @LockoutEnd > GETDATE())
    BEGIN
        SELECT 'LOCKED' AS Status, 'Account is locked. Please try again later or contact support.' AS Message
        RETURN
    END
    
    -- Verify password
    IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId AND PasswordHash = @PasswordHash)
    BEGIN
        -- Successful login
        UPDATE Users 
        SET LastLogin = GETDATE(), FailedLoginAttempts = 0, IsLocked = 0, LockoutEnd = NULL
        WHERE UserId = @UserId
        
        -- Log the activity
        INSERT INTO UserActivityLog (UserId, Activity, Description)
        VALUES (@UserId, 'Login', 'Customer logged in successfully')
        
        -- Return user details with role
        SELECT 
            'SUCCESS' AS Status,
            u.UserId,
            u.UserName,
            u.Email,
            u.FirstName,
            u.LastName,
            u.PhoneNumber,
            r.RoleName,
            r.RoleId
        FROM Users u
        INNER JOIN Roles r ON u.RoleId = r.RoleId
        WHERE u.UserId = @UserId
    END
    ELSE
    BEGIN
        -- Failed login
        UPDATE Users 
        SET FailedLoginAttempts = FailedLoginAttempts + 1,
            IsLocked = CASE WHEN FailedLoginAttempts >= 4 THEN 1 ELSE 0 END,
            LockoutEnd = CASE WHEN FailedLoginAttempts >= 4 THEN DATEADD(MINUTE, 15, GETDATE()) ELSE NULL END
        WHERE UserId = @UserId
        
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
    END
END
GO

-- Stored Procedure: Get Dashboard Statistics (Admin Only)
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetDashboardStats')
    DROP PROCEDURE sp_GetDashboardStats
GO

CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM vw_DashboardStats
    
    -- Additional stats
    SELECT 
        'Today' AS Period,
        COUNT(*) AS OrderCount,
        ISNULL(SUM(TotalAmount), 0) AS Revenue
    FROM Orders 
    WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
    
    UNION ALL
    
    SELECT 
        'This Week' AS Period,
        COUNT(*) AS OrderCount,
        ISNULL(SUM(TotalAmount), 0) AS Revenue
    FROM Orders 
    WHERE OrderDate >= DATEADD(WEEK, -1, GETDATE())
    
    UNION ALL
    
    SELECT 
        'This Month' AS Period,
        COUNT(*) AS OrderCount,
        ISNULL(SUM(TotalAmount), 0) AS Revenue
    FROM Orders 
    WHERE OrderDate >= DATEADD(MONTH, -1, GETDATE())
END
GO

-- Stored Procedure: Vendor Login
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_VendorLogin')
    DROP PROCEDURE sp_VendorLogin
GO

CREATE PROCEDURE sp_VendorLogin
    @UserName NVARCHAR(100),
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @VendorId INT, @IsLocked BIT, @LockoutEnd DATETIME, @FailedAttempts INT, @IsApproved BIT
    
    -- Check if vendor exists and get lock status
    SELECT 
        @VendorId = VendorId,
        @IsLocked = IsLocked,
        @LockoutEnd = LockoutEnd,
        @FailedAttempts = FailedLoginAttempts,
        @IsApproved = IsApproved
    FROM Vendors 
    WHERE VendorUserName = @UserName AND IsActive = 1
    
    IF @VendorId IS NULL
    BEGIN
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
        RETURN
    END
    
    -- Check if vendor is approved
    IF @IsApproved = 0
    BEGIN
        SELECT 'PENDING' AS Status, 'Your vendor account is pending approval. Please contact support.' AS Message
        RETURN
    END
    
    -- Check if account is locked
    IF @IsLocked = 1 AND (@LockoutEnd IS NULL OR @LockoutEnd > GETDATE())
    BEGIN
        SELECT 'LOCKED' AS Status, 'Account is locked. Please try again later or contact support.' AS Message
        RETURN
    END
    
    -- Verify password
    IF EXISTS (SELECT 1 FROM Vendors WHERE VendorId = @VendorId AND PasswordHash = @PasswordHash)
    BEGIN
        -- Successful login
        UPDATE Vendors 
        SET LastLogin = GETDATE(), FailedLoginAttempts = 0, IsLocked = 0, LockoutEnd = NULL
        WHERE VendorId = @VendorId
        
        -- Log the activity
        INSERT INTO VendorActivityLog (VendorId, Activity, Description)
        VALUES (@VendorId, 'Login', 'Vendor logged in successfully')
        
        -- Return vendor details
        SELECT 
            'SUCCESS' AS Status,
            VendorId,
            VendorUserName,
            VendorEmail,
            VendorFirstName,
            VendorLastName,
            BusinessName,
            Rating
        FROM Vendors 
        WHERE VendorId = @VendorId
    END
    ELSE
    BEGIN
        -- Failed login
        UPDATE Vendors 
        SET FailedLoginAttempts = FailedLoginAttempts + 1,
            IsLocked = CASE WHEN FailedLoginAttempts >= 4 THEN 1 ELSE 0 END,
            LockoutEnd = CASE WHEN FailedLoginAttempts >= 4 THEN DATEADD(MINUTE, 20, GETDATE()) ELSE NULL END
        WHERE VendorId = @VendorId
        
        SELECT 'ERROR' AS Status, 'Invalid username or password' AS Message
    END
END
GO

-- Insert sample vendor (for testing)
-- Password: Vendor@123 (This is hashed - for testing only!)
IF NOT EXISTS (SELECT * FROM Vendors WHERE VendorUserName = 'vendor1')
BEGIN
    INSERT INTO Vendors (VendorUserName, VendorEmail, PasswordHash, PasswordSalt, VendorFirstName, VendorLastName, BusinessName, IsActive, IsApproved, Rating)
    VALUES 
    ('vendor1', 'vendor1@ecomjew.com', 'AQAAAAEAACcQAAAAEFZlbmRvcl9IYXNoZWRfUGFzc3dvcmRfSGVyZQ==', 'VmVuZG9yX1NhbHRfVmFsdWVfSGVyZQ==', 'John', 'Smith', 'Premium Jewelers Inc', 1, 1, 4.5),
    ('vendor2', 'vendor2@ecomjew.com', 'AQAAAAEAACcQAAAAEFZlbmRvcl9IYXNoZWRfUGFzc3dvcmRfSGVyZQ==', 'VmVuZG9yX1NhbHRfVmFsdWVfSGVyZQ==', 'Sarah', 'Johnson', 'Golden Touch Jewelry', 1, 1, 4.2),
    ('vendor3', 'vendor3@ecomjew.com', 'AQAAAAEAACcQAAAAEFZlbmRvcl9IYXNoZWRfUGFzc3dvcmRfSGVyZQ==', 'VmVuZG9yX1NhbHRfVmFsdWVfSGVyZQ==', 'Michael', 'Brown', 'Silver Dreams Ltd', 1, 1, 4.7),
    ('vendor4', 'vendor4@ecomjew.com', 'AQAAAAEAACcQAAAAEFZlbmRvcl9IYXNoZWRfUGFzc3dvcmRfSGVyZQ==', 'VmVuZG9yX1NhbHRfVmFsdWVfSGVyZQ==', 'Emily', 'Davis', 'Diamond Palace', 1, 1, 4.8),
    ('vendor5', 'vendor5@ecomjew.com', 'AQAAAAEAACcQAAAAEFZlbmRvcl9IYXNoZWRfUGFzc3dvcmRfSGVyZQ==', 'VmVuZG9yX1NhbHRfVmFsdWVfSGVyZQ==', 'David', 'Wilson', 'Luxury Gems Co', 1, 1, 4.3)
END
GO

-- Insert comprehensive vendor product catalog (100 products)
IF NOT EXISTS (SELECT * FROM VendorProducts WHERE ItemCode = 'ITM001')
BEGIN
    INSERT INTO VendorProducts (VendorId, ItemCode, LotNo, ProductName, Description, Price, UOM, Category, Material, Stones, Karatage, StockAvailable, ProductImage, IsActive, CreatedDate)
    VALUES 
    -- Vendor 1 Products (ITM001-ITM020)
    (1, 'ITM001', 'LOT0001', 'Classic Silver Ring', 'Sample description 1', 1010.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 11, 'img1.jpg', 1, GETDATE()),
    (1, 'ITM002', 'LOT0002', 'Silver Band Ring', 'Sample description 2', 1020.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 12, 'img2.jpg', 1, GETDATE()),
    (1, 'ITM003', 'LOT0003', 'Gold Accent Ring', 'Sample description 3', 1030.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 13, 'img3.jpg', 1, GETDATE()),
    (1, 'ITM004', 'LOT0004', 'Sterling Silver Chain', 'Sample description 4', 1040.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 14, 'img4.jpg', 1, GETDATE()),
    (1, 'ITM005', 'LOT0005', 'Diamond Silver Ring', 'Sample description 5', 1050.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 15, 'img5.jpg', 1, GETDATE()),
    (1, 'ITM006', 'LOT0006', 'Gold Wedding Band', 'Sample description 6', 1060.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 16, 'img6.jpg', 1, GETDATE()),
    (1, 'ITM007', 'LOT0007', 'Silver Bracelet', 'Sample description 7', 1070.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 17, 'img7.jpg', 1, GETDATE()),
    (1, 'ITM008', 'LOT0008', 'Silver Pendant', 'Sample description 8', 1080.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 18, 'img8.jpg', 1, GETDATE()),
    (1, 'ITM009', 'LOT0009', 'Gold Necklace', 'Sample description 9', 1090.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 19, 'img9.jpg', 1, GETDATE()),
    (1, 'ITM010', 'LOT0010', 'Diamond Gold Ring', 'Sample description 10', 1100.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '22K', 20, 'img10.jpg', 1, GETDATE()),
    (1, 'ITM011', 'LOT0011', 'Silver Anklet', 'Sample description 11', 1110.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 21, 'img11.jpg', 1, GETDATE()),
    (1, 'ITM012', 'LOT0012', 'Gold Earrings', 'Sample description 12', 1120.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 22, 'img12.jpg', 1, GETDATE()),
    (1, 'ITM013', 'LOT0013', 'Silver Charm', 'Sample description 13', 1130.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 23, 'img13.jpg', 1, GETDATE()),
    (1, 'ITM014', 'LOT0014', 'Silver Bangle', 'Sample description 14', 1140.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 24, 'img14.jpg', 1, GETDATE()),
    (1, 'ITM015', 'LOT0015', 'Diamond Gold Necklace', 'Sample description 15', 1150.00, 'PCS', 'Accessory', 'Gold', 'Diamond', '22K', 25, 'img15.jpg', 1, GETDATE()),
    (1, 'ITM016', 'LOT0016', 'Silver Nose Pin', 'Sample description 16', 1160.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 26, 'img16.jpg', 1, GETDATE()),
    (1, 'ITM017', 'LOT0017', 'Silver Toe Ring', 'Sample description 17', 1170.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 27, 'img17.jpg', 1, GETDATE()),
    (1, 'ITM018', 'LOT0018', 'Gold Chain', 'Sample description 18', 1180.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 28, 'img18.jpg', 1, GETDATE()),
    (1, 'ITM019', 'LOT0019', 'Silver Waist Chain', 'Sample description 19', 1190.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 29, 'img19.jpg', 1, GETDATE()),
    (1, 'ITM020', 'LOT0020', 'Diamond Silver Pendant', 'Sample description 20', 1200.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '18K', 30, 'img20.jpg', 1, GETDATE()),
    
    -- Vendor 2 Products (ITM021-ITM040)
    (2, 'ITM021', 'LOT0021', 'Gold Kada', 'Sample description 21', 1210.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 31, 'img21.jpg', 1, GETDATE()),
    (2, 'ITM022', 'LOT0022', 'Silver Ring Set', 'Sample description 22', 1220.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 32, 'img22.jpg', 1, GETDATE()),
    (2, 'ITM023', 'LOT0023', 'Silver Payal', 'Sample description 23', 1230.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 33, 'img23.jpg', 1, GETDATE()),
    (2, 'ITM024', 'LOT0024', 'Gold Mangalsutra', 'Sample description 24', 1240.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 34, 'img24.jpg', 1, GETDATE()),
    (2, 'ITM025', 'LOT0025', 'Diamond Silver Bracelet', 'Sample description 25', 1250.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 35, 'img25.jpg', 1, GETDATE()),
    (2, 'ITM026', 'LOT0026', 'Silver Choker', 'Sample description 26', 1260.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 36, 'img26.jpg', 1, GETDATE()),
    (2, 'ITM027', 'LOT0027', 'Gold Studs', 'Sample description 27', 1270.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 37, 'img27.jpg', 1, GETDATE()),
    (2, 'ITM028', 'LOT0028', 'Silver Hoops', 'Sample description 28', 1280.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 38, 'img28.jpg', 1, GETDATE()),
    (2, 'ITM029', 'LOT0029', 'Silver Locket', 'Sample description 29', 1290.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 39, 'img29.jpg', 1, GETDATE()),
    (2, 'ITM030', 'LOT0030', 'Diamond Gold Bracelet', 'Sample description 30', 1300.00, 'PCS', 'Jewelry', 'Gold', 'Diamond', '22K', 40, 'img30.jpg', 1, GETDATE()),
    (2, 'ITM031', 'LOT0031', 'Silver Armlet', 'Sample description 31', 1310.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 41, 'img31.jpg', 1, GETDATE()),
    (2, 'ITM032', 'LOT0032', 'Silver Cuff', 'Sample description 32', 1320.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 42, 'img32.jpg', 1, GETDATE()),
    (2, 'ITM033', 'LOT0033', 'Gold Bangle Set', 'Sample description 33', 1330.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 43, 'img33.jpg', 1, GETDATE()),
    (2, 'ITM034', 'LOT0034', 'Silver Belly Ring', 'Sample description 34', 1340.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 44, 'img34.jpg', 1, GETDATE()),
    (2, 'ITM035', 'LOT0035', 'Diamond Silver Earrings', 'Sample description 35', 1350.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 45, 'img35.jpg', 1, GETDATE()),
    (2, 'ITM036', 'LOT0036', 'Gold Jhumka', 'Sample description 36', 1360.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 46, 'img36.jpg', 1, GETDATE()),
    (2, 'ITM037', 'LOT0037', 'Silver Mang Tika', 'Sample description 37', 1370.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 47, 'img37.jpg', 1, GETDATE()),
    (2, 'ITM038', 'LOT0038', 'Silver Nath', 'Sample description 38', 1380.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 48, 'img38.jpg', 1, GETDATE()),
    (2, 'ITM039', 'LOT0039', 'Gold Finger Ring', 'Sample description 39', 1390.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 49, 'img39.jpg', 1, GETDATE()),
    (2, 'ITM040', 'LOT0040', 'Diamond Silver Necklace', 'Sample description 40', 1400.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '18K', 50, 'img40.jpg', 1, GETDATE()),
    
    -- Vendor 3 Products (ITM041-ITM060)
    (3, 'ITM041', 'LOT0041', 'Silver Kara', 'Sample description 41', 1410.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 51, 'img41.jpg', 1, GETDATE()),
    (3, 'ITM042', 'LOT0042', 'Gold Link Chain', 'Sample description 42', 1420.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 52, 'img42.jpg', 1, GETDATE()),
    (3, 'ITM043', 'LOT0043', 'Silver Hair Pin', 'Sample description 43', 1430.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 53, 'img43.jpg', 1, GETDATE()),
    (3, 'ITM044', 'LOT0044', 'Silver Brooch', 'Sample description 44', 1440.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 54, 'img44.jpg', 1, GETDATE()),
    (3, 'ITM045', 'LOT0045', 'Diamond Gold Ring', 'Sample description 45', 1450.00, 'PCS', 'Accessory', 'Gold', 'Diamond', '22K', 55, 'img45.jpg', 1, GETDATE()),
    (3, 'ITM046', 'LOT0046', 'Silver Bypass Ring', 'Sample description 46', 1460.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 56, 'img46.jpg', 1, GETDATE()),
    (3, 'ITM047', 'LOT0047', 'Silver Statement Ring', 'Sample description 47', 1470.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 57, 'img47.jpg', 1, GETDATE()),
    (3, 'ITM048', 'LOT0048', 'Gold Rope Chain', 'Sample description 48', 1480.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 58, 'img48.jpg', 1, GETDATE()),
    (3, 'ITM049', 'LOT0049', 'Silver Midi Ring', 'Sample description 49', 1490.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 59, 'img49.jpg', 1, GETDATE()),
    (3, 'ITM050', 'LOT0050', 'Diamond Silver Stud', 'Sample description 50', 1500.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '22K', 60, 'img50.jpg', 1, GETDATE()),
    (3, 'ITM051', 'LOT0051', 'Gold Beaded Necklace', 'Sample description 51', 1510.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 61, 'img51.jpg', 1, GETDATE()),
    (3, 'ITM052', 'LOT0052', 'Silver Drop Earrings', 'Sample description 52', 1520.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 62, 'img52.jpg', 1, GETDATE()),
    (3, 'ITM053', 'LOT0053', 'Silver Dangle Earrings', 'Sample description 53', 1530.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 63, 'img53.jpg', 1, GETDATE()),
    (3, 'ITM054', 'LOT0054', 'Gold Chandelier Earrings', 'Sample description 54', 1540.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 64, 'img54.jpg', 1, GETDATE()),
    (3, 'ITM055', 'LOT0055', 'Diamond Silver Chain', 'Sample description 55', 1550.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 65, 'img55.jpg', 1, GETDATE()),
    (3, 'ITM056', 'LOT0056', 'Silver Tennis Bracelet', 'Sample description 56', 1560.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 66, 'img56.jpg', 1, GETDATE()),
    (3, 'ITM057', 'LOT0057', 'Gold Herringbone Chain', 'Sample description 57', 1570.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 67, 'img57.jpg', 1, GETDATE()),
    (3, 'ITM058', 'LOT0058', 'Silver Box Chain', 'Sample description 58', 1580.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 68, 'img58.jpg', 1, GETDATE()),
    (3, 'ITM059', 'LOT0059', 'Silver Snake Chain', 'Sample description 59', 1590.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 69, 'img59.jpg', 1, GETDATE()),
    (3, 'ITM060', 'LOT0060', 'Diamond Gold Pendant', 'Sample description 60', 1600.00, 'PCS', 'Jewelry', 'Gold', 'Diamond', '18K', 70, 'img60.jpg', 1, GETDATE()),
    
    -- Vendor 4 Products (ITM061-ITM080)
    (4, 'ITM061', 'LOT0061', 'Silver Figaro Chain', 'Sample description 61', 1610.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 71, 'img61.jpg', 1, GETDATE()),
    (4, 'ITM062', 'LOT0062', 'Silver Cuban Link', 'Sample description 62', 1620.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 72, 'img62.jpg', 1, GETDATE()),
    (4, 'ITM063', 'LOT0063', 'Gold Wheat Chain', 'Sample description 63', 1630.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 73, 'img63.jpg', 1, GETDATE()),
    (4, 'ITM064', 'LOT0064', 'Silver Curb Chain', 'Sample description 64', 1640.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 74, 'img64.jpg', 1, GETDATE()),
    (4, 'ITM065', 'LOT0065', 'Diamond Silver Ring', 'Sample description 65', 1650.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 75, 'img65.jpg', 1, GETDATE()),
    (4, 'ITM066', 'LOT0066', 'Gold Paperclip Chain', 'Sample description 66', 1660.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 76, 'img66.jpg', 1, GETDATE()),
    (4, 'ITM067', 'LOT0067', 'Silver Ball Chain', 'Sample description 67', 1670.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 77, 'img67.jpg', 1, GETDATE()),
    (4, 'ITM068', 'LOT0068', 'Silver Rolo Chain', 'Sample description 68', 1680.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 78, 'img68.jpg', 1, GETDATE()),
    (4, 'ITM069', 'LOT0069', 'Gold Anchor Chain', 'Sample description 69', 1690.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 79, 'img69.jpg', 1, GETDATE()),
    (4, 'ITM070', 'LOT0070', 'Diamond Silver Bangle', 'Sample description 70', 1700.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '22K', 80, 'img70.jpg', 1, GETDATE()),
    (4, 'ITM071', 'LOT0071', 'Silver Singapore Chain', 'Sample description 71', 1710.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 81, 'img71.jpg', 1, GETDATE()),
    (4, 'ITM072', 'LOT0072', 'Gold Spiga Chain', 'Sample description 72', 1720.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 82, 'img72.jpg', 1, GETDATE()),
    (4, 'ITM073', 'LOT0073', 'Silver Byzantine Chain', 'Sample description 73', 1730.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 83, 'img73.jpg', 1, GETDATE()),
    (4, 'ITM074', 'LOT0074', 'Silver Franco Chain', 'Sample description 74', 1740.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 84, 'img74.jpg', 1, GETDATE()),
    (4, 'ITM075', 'LOT0075', 'Diamond Gold Earrings', 'Sample description 75', 1750.00, 'PCS', 'Accessory', 'Gold', 'Diamond', '22K', 85, 'img75.jpg', 1, GETDATE()),
    (4, 'ITM076', 'LOT0076', 'Silver Mariner Chain', 'Sample description 76', 1760.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 86, 'img76.jpg', 1, GETDATE()),
    (4, 'ITM077', 'LOT0077', 'Silver Popcorn Chain', 'Sample description 77', 1770.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 87, 'img77.jpg', 1, GETDATE()),
    (4, 'ITM078', 'LOT0078', 'Gold Omega Chain', 'Sample description 78', 1780.00, 'PCS', 'Jewelry', 'Gold', NULL, '22K', 88, 'img78.jpg', 1, GETDATE()),
    (4, 'ITM079', 'LOT0079', 'Silver Bead Chain', 'Sample description 79', 1790.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 89, 'img79.jpg', 1, GETDATE()),
    (4, 'ITM080', 'LOT0080', 'Diamond Silver Choker', 'Sample description 80', 1800.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '18K', 90, 'img80.jpg', 1, GETDATE()),
    
    -- Vendor 5 Products (ITM081-ITM100)
    (5, 'ITM081', 'LOT0081', 'Gold Trace Chain', 'Sample description 81', 1810.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 91, 'img81.jpg', 1, GETDATE()),
    (5, 'ITM082', 'LOT0082', 'Silver Flat Cable Chain', 'Sample description 82', 1820.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 92, 'img82.jpg', 1, GETDATE()),
    (5, 'ITM083', 'LOT0083', 'Silver Satellite Chain', 'Sample description 83', 1830.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 93, 'img83.jpg', 1, GETDATE()),
    (5, 'ITM084', 'LOT0084', 'Gold Belcher Chain', 'Sample description 84', 1840.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 94, 'img84.jpg', 1, GETDATE()),
    (5, 'ITM085', 'LOT0085', 'Diamond Silver Anklet', 'Sample description 85', 1850.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 95, 'img85.jpg', 1, GETDATE()),
    (5, 'ITM086', 'LOT0086', 'Silver Foxtail Chain', 'Sample description 86', 1860.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 96, 'img86.jpg', 1, GETDATE()),
    (5, 'ITM087', 'LOT0087', 'Gold Bar Chain', 'Sample description 87', 1870.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 97, 'img87.jpg', 1, GETDATE()),
    (5, 'ITM088', 'LOT0088', 'Silver Barrel Chain', 'Sample description 88', 1880.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 98, 'img88.jpg', 1, GETDATE()),
    (5, 'ITM089', 'LOT0089', 'Silver Venetian Chain', 'Sample description 89', 1890.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 99, 'img89.jpg', 1, GETDATE()),
    (5, 'ITM090', 'LOT0090', 'Diamond Gold Set', 'Sample description 90', 1900.00, 'PCS', 'Jewelry', 'Gold', 'Diamond', '22K', 100, 'img90.jpg', 1, GETDATE()),
    (5, 'ITM091', 'LOT0091', 'Silver Snake Ring', 'Sample description 91', 1910.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 101, 'img91.jpg', 1, GETDATE()),
    (5, 'ITM092', 'LOT0092', 'Silver Infinity Ring', 'Sample description 92', 1920.00, 'PCS', 'Jewelry', 'Silver', NULL, '18K', 102, 'img92.jpg', 1, GETDATE()),
    (5, 'ITM093', 'LOT0093', 'Gold Eternity Band', 'Sample description 93', 1930.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 103, 'img93.jpg', 1, GETDATE()),
    (5, 'ITM094', 'LOT0094', 'Silver Promise Ring', 'Sample description 94', 1940.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 104, 'img94.jpg', 1, GETDATE()),
    (5, 'ITM095', 'LOT0095', 'Diamond Silver Set', 'Sample description 95', 1950.00, 'PCS', 'Accessory', 'Silver', 'Diamond', '22K', 105, 'img95.jpg', 1, GETDATE()),
    (5, 'ITM096', 'LOT0096', 'Gold Signet Ring', 'Sample description 96', 1960.00, 'PCS', 'Jewelry', 'Gold', NULL, '18K', 106, 'img96.jpg', 1, GETDATE()),
    (5, 'ITM097', 'LOT0097', 'Silver Claddagh Ring', 'Sample description 97', 1970.00, 'PCS', 'Accessory', 'Silver', NULL, '22K', 107, 'img97.jpg', 1, GETDATE()),
    (5, 'ITM098', 'LOT0098', 'Silver Solitaire Ring', 'Sample description 98', 1980.00, 'PCS', 'Jewelry', 'Silver', NULL, '22K', 108, 'img98.jpg', 1, GETDATE()),
    (5, 'ITM099', 'LOT0099', 'Gold Trinity Ring', 'Sample description 99', 1990.00, 'PCS', 'Accessory', 'Gold', NULL, '22K', 109, 'img99.jpg', 1, GETDATE()),
    (5, 'ITM100', 'LOT0100', 'Diamond Silver Collection', 'Sample description 100', 2000.00, 'PCS', 'Jewelry', 'Silver', 'Diamond', '18K', 110, 'img100.jpg', 1, GETDATE())
END
GO

PRINT 'EComJew Database created successfully!'
PRINT 'Vendor management system integrated!'
GO
