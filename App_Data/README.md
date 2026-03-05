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

1. **Users** - Customer and user accounts
2. **Categories** - Product categories
3. **Products** - Product catalog
4. **Orders** - Customer orders
5. **OrderDetails** - Order line items
6. **ShoppingCart** - Shopping cart items
7. **Addresses** - Customer shipping addresses
8. **Reviews** - Product reviews and ratings

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

## Prerequisites

- SQL Server LocalDB or SQL Server Express
- .NET Framework 4.7.2 or higher (for .NET Framework projects)
- OR .NET Core 3.1+ / .NET 5+ (for .NET Core projects)

## Notes

- The database file will be created in the `App_Data` folder
- Sample categories are pre-populated
- All tables use Identity columns for primary keys
- Foreign key relationships are established between related tables
