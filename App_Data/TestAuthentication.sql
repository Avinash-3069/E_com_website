-- Test Script for EComJew Database
-- Repository: https://github.com/Avinash-3069/E_com_website.git
-- This script tests the role-based authentication system

USE EComJew
GO

PRINT '========================================='
PRINT 'Testing EComJew Database Authentication'
PRINT '========================================='
PRINT ''

-- Test 1: Check if Roles are created
PRINT '1. Checking Roles Table...'
SELECT * FROM Roles
PRINT ''

-- Test 2: Check if AdminUsers table has default admin
PRINT '2. Checking AdminUsers Table...'
SELECT AdminId, AdminUserName, Email, FirstName, LastName, IsSuperAdmin, IsActive, DateCreated 
FROM AdminUsers
PRINT ''

-- Test 3: Check if Users table has sample customer
PRINT '3. Checking Users (Customers) Table...'
SELECT u.UserId, u.UserName, u.Email, u.FirstName, u.LastName, r.RoleName, u.IsActive, u.DateRegistered 
FROM Users u
LEFT JOIN Roles r ON u.RoleId = r.RoleId
PRINT ''

-- Test 4: Check Categories
PRINT '4. Checking Categories...'
SELECT * FROM Categories
PRINT ''

-- Test 5: Test Admin Login (Successful - with dummy hash)
PRINT '5. Testing Admin Login (Success)...'
EXEC sp_AdminLogin 
    @UserName = 'admin', 
    @PasswordHash = 'AQAAAAEAACcQAAAAEFVzZXJfSGFzaGVkX1Bhc3N3b3JkX0hlcmU='
PRINT ''

-- Test 6: Test Customer Login (Successful - with dummy hash)
PRINT '6. Testing Customer Login (Success)...'
EXEC sp_CustomerLogin 
    @UserName = 'customer', 
    @PasswordHash = 'AQAAAAEAACcQAAAAEFVzZXJfSGFzaGVkX1Bhc3N3b3JkX0hlcmU='
PRINT ''

-- Test 7: Test Admin Login (Failed - wrong password)
PRINT '7. Testing Admin Login (Failed - Wrong Password)...'
EXEC sp_AdminLogin 
    @UserName = 'admin', 
    @PasswordHash = 'WrongPasswordHash'
PRINT ''

-- Test 8: Test Customer Login (Failed - wrong password)
PRINT '8. Testing Customer Login (Failed - Wrong Password)...'
EXEC sp_CustomerLogin 
    @UserName = 'customer', 
    @PasswordHash = 'WrongPasswordHash'
PRINT ''

-- Test 9: Check Dashboard Statistics View
PRINT '9. Testing Dashboard Statistics View...'
SELECT * FROM vw_DashboardStats
PRINT ''

-- Test 10: Check Activity Logs
PRINT '10. Checking Admin Activity Logs...'
SELECT TOP 5 
    l.LogId, 
    a.AdminUserName, 
    l.Activity, 
    l.Description, 
    l.ActivityDate 
FROM AdminActivityLog l
INNER JOIN AdminUsers a ON l.AdminId = a.AdminId
ORDER BY l.ActivityDate DESC
PRINT ''

PRINT '11. Checking User Activity Logs...'
SELECT TOP 5 
    l.LogId, 
    u.UserName, 
    l.Activity, 
    l.Description, 
    l.ActivityDate 
FROM UserActivityLog l
INNER JOIN Users u ON l.UserId = u.UserId
ORDER BY l.ActivityDate DESC
PRINT ''

PRINT '========================================='
PRINT 'All Tests Completed!'
PRINT '========================================='
GO
