# EComJew Authentication Guide

## Role-Based Access Control

The EComJew database implements separate authentication systems for **Admin**, **Customer**, and **Vendor** users.

---

## ?? Admin Login System

### Admin Table: `AdminUsers`
- **Purpose**: Separate login for admin dashboard
- **Access Level**: Full system access, view overall dashboard
- **Features**:
  - Separate authentication from customers
  - Activity logging
  - Account lockout after 5 failed attempts (30-minute lockout)
  - Super admin privileges

### Default Admin Credentials
```
Username: admin
Email: admin@ecomjew.com
Password: Admin@123
```
?? **IMPORTANT**: Change the password after first login!

### Admin Login Stored Procedure
```sql
EXEC sp_AdminLogin 
    @UserName = 'admin', 
    @PasswordHash = 'hashed_password_here'
```

### Admin Dashboard Features
- View overall statistics (total customers, products, orders, revenue)
- Monitor recent orders
- Track top-selling products
- View low stock alerts
- Manage products, categories, and users
- View activity logs

---

## ?? Customer Login System

### Customer Table: `Users`
- **Purpose**: Customer website access
- **Access Level**: Browse products, place orders, manage profile
- **Features**:
  - Role-based permissions (Customer, Manager)
  - Activity logging
  - Account lockout after 5 failed attempts (15-minute lockout)
  - Shopping cart and order history

### Sample Customer Credentials
```
Username: customer
Email: customer@example.com
Password: Customer@123
```

### Customer Login Stored Procedure
```sql
EXEC sp_CustomerLogin 
    @UserName = 'customer', 
    @PasswordHash = 'hashed_password_here'
```

### Customer Features
- Browse and search products
- Add items to shopping cart
- Place orders
- View order history
- Write product reviews
- Manage shipping addresses

---

## ?? Vendor Login System

### Vendor Table: `Vendors`
- **Purpose**: Multi-vendor marketplace access
- **Access Level**: Manage own products, view sales, manage inventory
- **Features**:
  - Separate authentication from customers and admins
  - Product management dashboard
  - Vendor approval system (requires admin approval)
  - Activity logging
  - Account lockout after 5 failed attempts (20-minute lockout)
  - Rating system

### Sample Vendor Credentials
```
Username: vendor1
Email: vendor1@ecomjew.com
Password: Vendor@123
```
?? **NOTE**: Vendor accounts require admin approval before login access.

### Vendor Login Stored Procedure
```sql
EXEC sp_VendorLogin 
    @UserName = 'vendor1', 
    @PasswordHash = 'hashed_password_here'
```

### Vendor Dashboard Features
- Add and manage products (with ItemCode and LotNo)
- Update product inventory
- View product sales statistics
- Manage product categories and specifications
- View customer reviews
- Track vendor rating
- View activity logs

### Vendor Product Management
Vendors can manage products with detailed specifications:
- Item Code & Lot Number (unique identifier)
- Product details (name, description, price)
- Material specifications (Gold, Silver, Platinum, etc.)
- Gemstone information
- Karatage (18K, 22K, 925 Silver, etc.)
- Stock availability
- Product images
- Unit of Measure (PCS, PAIR, GRAM, etc.)

---

## ?? Roles

| RoleId | RoleName | Description | Access |
|--------|----------|-------------|---------|
| 1 | Admin | Administrator | Admin Dashboard - Full system access |
| 2 | Customer | Regular Customer | Website - Browse, shop, order |
| 3 | Manager | Store Manager | Limited admin access |
| 4 | Vendor | Product Vendor | Vendor Dashboard - Manage own products |

---

## ??? Database Tables

### Authentication Tables:
1. **Roles** - User role definitions
2. **Users** - Customer accounts with role assignment
3. **AdminUsers** - Admin accounts (separate from customers)
4. **Vendors** - Vendor accounts (separate from customers and admins)
5. **AdminActivityLog** - Admin action tracking
6. **UserActivityLog** - Customer activity tracking
7. **VendorActivityLog** - Vendor activity tracking

### E-commerce Tables:
8. **Categories** - Product categories
9. **Products** - Product catalog
10. **VendorProducts** - Products managed by vendors (with ItemCode, LotNo)
11. **Orders** - Customer orders
12. **OrderDetails** - Order line items
13. **ShoppingCart** - Shopping cart items
14. **Addresses** - Shipping addresses
15. **Reviews** - Product reviews

---

## ?? Admin Dashboard Views

### 1. `vw_DashboardStats`
Shows overall statistics:
- Total active customers
- Total active products
- Orders this month
- Revenue this month
- Pending orders count
- Low stock products

### 2. `vw_RecentOrders`
Displays the 50 most recent orders with customer details.

### 3. `vw_TopSellingProducts`
Top 10 best-selling products with revenue.

### 4. `vw_CustomerOrders`
Customer-specific order history.

---

## ?? Security Features

### Password Security
- Passwords stored as hashed values with salt
- Password salt stored separately
- Implement BCrypt or PBKDF2 in your application layer

### Account Lockout
- **Admin**: 5 failed attempts ? 30-minute lockout
- **Customer**: 5 failed attempts ? 15-minute lockout
- **Vendor**: 5 failed attempts ? 20-minute lockout

### Activity Logging
- All admin actions logged to `AdminActivityLog`
- Customer activities logged to `UserActivityLog`
- Vendor activities logged to `VendorActivityLog`
- Includes IP address tracking

### Vendor Approval System
- New vendor registrations require admin approval
- Vendors cannot login until `IsApproved = 1`
- Admin can activate/deactivate vendor accounts

---

## ?? Implementation Example (C#)

### Admin Login Example:
```csharp
// Admin login endpoint (separate from customer login)
[HttpPost("admin/login")]
public async Task<IActionResult> AdminLogin([FromBody] LoginModel model)
{
    var hashedPassword = HashPassword(model.Password);
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand("sp_AdminLogin", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@UserName", model.UserName);
        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
        
        conn.Open();
        SqlDataReader reader = await cmd.ExecuteReaderAsync();
        
        // Process result and return JWT token for admin dashboard
    }
}
```

### Customer Login Example:
```csharp
// Customer login endpoint (for website)
[HttpPost("customer/login")]
public async Task<IActionResult> CustomerLogin([FromBody] LoginModel model)
{
    var hashedPassword = HashPassword(model.Password);
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand("sp_CustomerLogin", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@UserName", model.UserName);
        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
        
        conn.Open();
        SqlDataReader reader = await cmd.ExecuteReaderAsync();
        
        // Process result and return JWT token for customer session
    }
}
```

### Vendor Login Example:
```csharp
// Vendor login endpoint (for vendor dashboard)
[HttpPost("vendor/login")]
public async Task<IActionResult> VendorLogin([FromBody] LoginModel model)
{
    var hashedPassword = HashPassword(model.Password);
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand("sp_VendorLogin", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@UserName", model.UserName);
        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
        
        conn.Open();
        SqlDataReader reader = await cmd.ExecuteReaderAsync();
        
        if (reader.Read())
        {
            string status = reader["Status"].ToString();
            
            if (status == "PENDING")
            {
                return StatusCode(403, new { message = "Account pending approval" });
            }
            else if (status == "LOCKED")
            {
                return StatusCode(423, new { message = "Account locked" });
            }
            else if (status == "SUCCESS")
            {
                // Process result and return JWT token for vendor dashboard
            }
        }
    }
}
```

---

## ?? Getting Started

1. Run the database creation script
2. Change default admin password
3. Implement password hashing in your application (BCrypt recommended)
4. Create separate login pages:
   - `/admin/login` - For admin dashboard
   - `/login` - For customer website
   - `/vendor/login` - For vendor dashboard
5. Use JWT tokens with role claims for authorization
6. Implement role-based authorization in your API/Controllers
7. Create vendor approval workflow in admin dashboard
8. Implement vendor product management interface

---

## ?? Support
For issues or questions, refer to the repository:
https://github.com/Avinash-3069/E_com_website.git
