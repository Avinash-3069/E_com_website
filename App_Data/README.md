# EComJew Database

This directory contains the SQL Server database file (EComJew.mdf) for the E-commerce website.

## Repository
https://github.com/Avinash-3069/E_com_website.git

## Database Information

- **Database Name:** EComJew
- **Database File:** EComJew.mdf
- **Log File:** EComJew_log.ldf

## Connection Strings

### LocalDB Connection (Default)
```
Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\EComJew.mdf;Integrated Security=True;Connect Timeout=30
```

### SQL Server Connection
```
Data Source=localhost;Initial Catalog=EComJew;Integrated Security=True
```

## Database Schema

The database includes the following tables:

### Authentication Tables:
1. **Roles** - User roles (Admin, Customer, Manager, Vendor)
2. **Users** - Customer and user accounts
3. **AdminUsers** - Admin accounts (separate authentication)
4. **Vendors** - Vendor accounts (multi-vendor marketplace)
5. **AdminActivityLog** - Admin activity tracking
6. **UserActivityLog** - Customer activity tracking
7. **VendorActivityLog** - Vendor activity tracking

### E-commerce Tables:
8. **Categories** - Product categories
9. **Products** - Product catalog
10. **VendorProducts** - Products managed by vendors (with ItemCode, LotNo)
11. **Orders** - Customer orders
12. **OrderDetails** - Order line items
13. **ShoppingCart** - Shopping cart items
14. **Addresses** - Customer shipping addresses
15. **Reviews** - Product reviews and ratings

## Setup Instructions

### Option 1: Using PowerShell Script (Recommended)
Run the following command from the project root:
```powershell
.\CreateDatabase.ps1
```

### Option 2: Using SQL Script
1. Open SQL Server Management Studio or Visual Studio
2. Connect to (LocalDB)\MSSQLLocalDB
3. Execute the script: `App_Data\CreateEComJewDatabase.sql`

### Option 3: Manual Setup
1. Create database named `EComJew`
2. Run the full SQL script
3. Verify vendors and products are created

---

## ?? Documentation

- **[Authentication Guide](AuthenticationGuide.md)** - Complete guide for Admin, Customer, and Vendor authentication
- **[Vendor Guide](VendorGuide.md)** - Comprehensive vendor management documentation
- **[Vendor Product Summary](VENDOR_PRODUCT_SUMMARY.md)** - Overview of 100 sample products
- **[Vendor Quick Reference](VENDOR_QUICK_REFERENCE.md)** - Quick SQL queries and API examples

---

## ?? Sample Data Included

### Vendors (5 businesses)
- Premium Jewelers Inc (vendor1)
- Golden Touch Jewelry (vendor2)
- Silver Dreams Ltd (vendor3)
- Diamond Palace (vendor4)
- Luxury Gems Co (vendor5)

### Products (100 items)
- 20 products per vendor
- Mix of Gold (18K, 22K) and Silver (925) items
- 20 diamond-studded products
- Price range: $1,010 - $2,000
- Total inventory: 6,055 units

### Test Credentials
**Admin**: admin / Admin@123
**Customer**: customer / Customer@123
**Vendor**: vendor1 / Vendor@123 (all vendors use same password)

## Prerequisites

- SQL Server LocalDB or SQL Server Express
- .NET Framework 4.7.2 or higher (for .NET Framework projects)
- OR .NET Core 3.1+ / .NET 5+ (for .NET Core projects)

## Notes

- The database file will be created in the `App_Data` folder
- Sample categories are pre-populated
- All tables use Identity columns for primary keys
- Foreign key relationships are established between related tables
