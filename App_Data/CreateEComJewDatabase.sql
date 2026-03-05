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

-- Users/Customers Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId INT PRIMARY KEY IDENTITY(1,1),
        UserName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        PhoneNumber NVARCHAR(20),
        DateRegistered DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        UserRole NVARCHAR(50) DEFAULT 'Customer'
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

PRINT 'EComJew Database created successfully!'
GO
