# EComJew E-Commerce Database

## Overview
Complete SQL Server database for E-Commerce Jewelry website with role-based authentication and admin dashboard.

**Repository**: https://github.com/Avinash-3069/E_com_website.git

---

## ?? Key Features

### ? Separate Login Systems
1. **Admin Login** ? Admin Dashboard (Full system access)
2. **Customer Login** ? E-Commerce Website (Shopping experience)

### ? Role-Based Access Control
- Admin Role (Dashboard access)
- Customer Role (Website access)
- Manager Role (Limited admin access)

### ? Security Features
- Separate authentication tables
- Password hashing with salt
- Account lockout protection
- Activity logging for both admin and customers
- Failed login attempt tracking

---

## ?? Database Schema

### Authentication & Security Tables

#### 1. **Roles**
```sql
RoleId, RoleName, Description, IsActive, CreatedDate
```

#### 2. **AdminUsers** (Admin Dashboard Login)
```sql
AdminId, AdminUserName, Email, PasswordHash, PasswordSalt, 
FirstName, LastName, PhoneNumber, DateCreated, LastLogin, 
IsActive, IsSuperAdmin, FailedLoginAttempts, IsLocked, LockoutEnd
```

#### 3. **Users** (Customer Website Login)
```sql
UserId, UserName, Email, PasswordHash, PasswordSalt, 
FirstName, LastName, PhoneNumber, DateRegistered, LastLogin, 
IsActive, RoleId, FailedLoginAttempts, IsLocked, LockoutEnd
```

#### 4. **AdminActivityLog**
```sql
LogId, AdminId, Activity, Description, IPAddress, ActivityDate
```

#### 5. **UserActivityLog**
```sql
LogId, UserId, Activity, Description, IPAddress, ActivityDate
```

### E-Commerce Tables

#### 6. **Categories**
Product categorization (Rings, Necklaces, Earrings, etc.)

#### 7. **Products**
Product catalog with pricing, stock, and images

#### 8. **Orders**
Customer order management

#### 9. **OrderDetails**
Order line items with quantity and pricing

#### 10. **ShoppingCart**
Customer shopping cart items

#### 11. **Addresses**
Customer shipping addresses

#### 12. **Reviews**
Product reviews and ratings (1-5 stars)

---

## ?? Default Credentials

### Admin Dashboard Login
```
URL: /admin/login
Username: admin
Password: Admin@123
Role: Admin (Super Admin)
```

### Customer Website Login
```
URL: /login
Username: customer
Password: Customer@123
Role: Customer
```

?? **Security Note**: Change these passwords immediately in production!

---

## ??? Database Setup

### Prerequisites
- SQL Server LocalDB or SQL Server Express
- SqlCmd utility
- PowerShell (for automated setup)

### Installation Steps

#### Option 1: PowerShell Script (Recommended)
```powershell
cd "D:\AI Respo\ECOMAPI"
.\CreateDatabase.ps1
```

#### Option 2: Manual SQL Script
```powershell
sqlcmd -S "(LocalDB)\MSSQLLocalDB" -i "App_Data\CreateEComJewDatabase.sql"
```

#### Option 3: Visual Studio
1. Open Server Explorer
2. Connect to (LocalDB)\MSSQLLocalDB
3. Execute `App_Data\CreateEComJewDatabase.sql`

---

## ?? Connection Strings

### For LocalDB (.mdf file)
```xml
<add name="EComJewConnection" 
     connectionString="Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\EComJew.mdf;Integrated Security=True;Connect Timeout=30" 
     providerName="System.Data.SqlClient" />
```

### For SQL Server
```xml
<add name="EComJewServerConnection" 
     connectionString="Data Source=localhost;Initial Catalog=EComJew;Integrated Security=True" 
     providerName="System.Data.SqlClient" />
```

---

## ?? Stored Procedures

### Authentication Procedures

#### `sp_AdminLogin`
```sql
EXEC sp_AdminLogin 
    @UserName = 'admin', 
    @PasswordHash = 'hashed_password'
```
**Returns**: Admin details with status (SUCCESS/ERROR/LOCKED)

#### `sp_CustomerLogin`
```sql
EXEC sp_CustomerLogin 
    @UserName = 'customer', 
    @PasswordHash = 'hashed_password'
```
**Returns**: Customer details with role and status

#### `sp_GetDashboardStats`
```sql
EXEC sp_GetDashboardStats
```
**Returns**: Dashboard statistics (Today, This Week, This Month)

---

## ?? Project Structure

```
ECOMAPI/
??? App_Data/
?   ??? EComJew.mdf                    ? Database file (10 MB)
?   ??? EComJew_log.ldf                ? Transaction log
?   ??? CreateEComJewDatabase.sql      ? Database creation script
?   ??? AuthenticationGuide.md         ? Authentication documentation
?   ??? TestAuthentication.sql         ? Test script
?   ??? README.md                      ? Database info
??? CreateDatabase.ps1                 ? PowerShell setup script
??? appsettings.json                   ? Configuration (for .NET Core)
??? Web.config                         ? Configuration (for .NET Framework)
??? .gitignore                         ? Git ignore rules
```

---

## ?? Testing

Run the test script to verify everything works:
```powershell
sqlcmd -S "(LocalDB)\MSSQLLocalDB" -d EComJew -i "App_Data\TestAuthentication.sql"
```

---

## ?? Admin Dashboard Features

The admin dashboard should include:

### ?? Dashboard Overview
- Total Customers Count
- Total Products Count
- Orders This Month
- Revenue This Month
- Pending Orders
- Low Stock Alerts

### ?? Product Management
- Add/Edit/Delete Products
- Manage Categories
- Track Stock Levels
- Upload Product Images

### ?? Customer Management
- View All Customers
- Customer Activity Logs
- Manage User Accounts

### ?? Order Management
- View All Orders
- Update Order Status
- Process Payments
- Generate Reports

### ?? Reports & Analytics
- Sales Reports
- Top Selling Products
- Revenue Analytics
- Customer Insights

---

## ?? Customer Website Features

### Shopping Experience
- Browse products by category
- Search functionality
- Product details and reviews
- Add to cart
- Checkout process

### Account Management
- Registration
- Profile management
- Order history
- Saved addresses
- Password change

---

## ?? Security Best Practices

1. **Use Strong Password Hashing**
   - BCrypt (recommended)
   - PBKDF2
   - Argon2

2. **Implement JWT Authentication**
   - Separate tokens for admin and customers
   - Include role claims in JWT
   - Set appropriate token expiration

3. **HTTPS Only**
   - Always use SSL/TLS in production
   - Secure admin endpoints

4. **Input Validation**
   - Sanitize all user inputs
   - Use parameterized queries (already implemented)
   - Validate on both client and server side

5. **Change Default Passwords**
   - Update admin password immediately
   - Remove or disable test customer account in production

---

## ?? Database Maintenance

### Backup
```sql
BACKUP DATABASE EComJew 
TO DISK = 'C:\Backups\EComJew.bak' 
WITH FORMAT;
```

### Restore
```sql
RESTORE DATABASE EComJew 
FROM DISK = 'C:\Backups\EComJew.bak' 
WITH REPLACE;
```

---

## ?? Contributing
This database is part of the E-Commerce website project.
Repository: https://github.com/Avinash-3069/E_com_website.git

---

## ?? License
[Specify your license here]

---

## ?? Troubleshooting

### LocalDB Not Found
```powershell
# Install SQL Server Express with LocalDB
# Download from: https://www.microsoft.com/sql-server/sql-server-downloads
```

### Cannot Attach Database
```powershell
# Stop LocalDB instance
sqllocaldb stop MSSQLLocalDB

# Delete existing instance
sqllocaldb delete MSSQLLocalDB

# Create new instance
sqllocaldb create MSSQLLocalDB

# Start instance
sqllocaldb start MSSQLLocalDB
```

### Connection Issues
- Verify LocalDB is running: `sqllocaldb info MSSQLLocalDB`
- Check connection string in appsettings.json or Web.config
- Ensure App_Data folder has proper permissions

---

**Database Created**: ?  
**Admin Login**: ?  
**Customer Login**: ?  
**Role-Based Access**: ?  
**Dashboard Views**: ?  
**Activity Logging**: ?  
