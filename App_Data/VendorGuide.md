# EComJew Vendor Management Guide

## ?? Multi-Vendor Marketplace

EComJew supports a multi-vendor marketplace model where multiple vendors can register, get approved, and manage their own products independently.

---

## ?? Vendor Registration Flow

### Step 1: Vendor Registers
Vendor fills out registration form with:
- Username (unique)
- Email (unique)
- Password (hashed)
- Business Name
- Contact Information
- Business Address

### Step 2: Admin Approval
- Admin reviews vendor application in admin dashboard
- Admin can approve or reject vendor
- Until approved, vendor cannot login (`IsApproved = 0`)

### Step 3: Vendor Access Granted
- Once approved (`IsApproved = 1`), vendor can login
- Vendor gets access to vendor dashboard
- Vendor can start adding products

---

## ?? Vendor Authentication

### Login Credentials
```
Username: vendor1
Email: vendor1@ecomjew.com
Password: Vendor@123
```

### Login States
- **SUCCESS**: Login successful, return JWT token
- **PENDING**: Account awaiting admin approval
- **LOCKED**: Account locked after 5 failed attempts (20 minutes)
- **ERROR**: Invalid credentials

### Stored Procedure
```sql
EXEC sp_VendorLogin 
    @UserName = 'vendor1',
    @PasswordHash = 'hashed_password_here'
```

---

## ??? Vendor Product Management

### VendorProducts Table Structure
```sql
CREATE TABLE VendorProducts (
    VendorProductId INT PRIMARY KEY IDENTITY(1,1),
    VendorId INT NOT NULL,
    ItemCode NVARCHAR(50) NOT NULL,
    LotNo NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18, 2) NOT NULL,
    UOM NVARCHAR(20),              -- Unit of Measure (PCS, PAIR, GRAM, etc.)
    Category NVARCHAR(50),
    Material NVARCHAR(50),          -- Gold, Silver, Platinum, etc.
    Stones NVARCHAR(100),           -- Diamond, Pearl, Emerald, etc.
    Karatage NVARCHAR(20),          -- 18K, 22K, 925, etc.
    StockAvailable INT DEFAULT 0,
    ProductImage NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME,
    CONSTRAINT UQ_VendorProduct UNIQUE (VendorId, ItemCode, LotNo)
)
```

### Product Identification
Each vendor product has a unique combination of:
- **VendorId**: Links product to vendor
- **ItemCode**: Product SKU/code (e.g., GR001, GN001)
- **LotNo**: Batch/lot number (e.g., LOT2024-001)

### Product Categories
Common jewelry categories:
- Rings
- Necklaces
- Earrings
- Bracelets
- Watches
- Pendants
- Chains

### Materials
- Gold (10K, 14K, 18K, 22K, 24K)
- Silver (925 Sterling, 999 Fine)
- Platinum (950, 900)
- Rose Gold
- White Gold
- Palladium

### Gemstones/Stones
- Diamond
- Pearl
- Emerald
- Ruby
- Sapphire
- Topaz
- Opal
- Amethyst
- Carnelian

### Unit of Measure (UOM)
- **PCS**: Individual pieces (rings, pendants)
- **PAIR**: Paired items (earrings)
- **GRAM**: Weight-based (gold chains)
- **SET**: Complete sets (necklace + earrings)

---

## ?? Sample Vendor Products

### Example 1: Gold Diamond Ring
```sql
ItemCode: GR001
LotNo: LOT2024-001
ProductName: Gold Diamond Ring
Price: $2,500.00
UOM: PCS
Category: Rings
Material: Gold
Stones: Diamond
Karatage: 18K
StockAvailable: 25
```

### Example 2: Pearl Necklace
```sql
ItemCode: GN001
LotNo: LOT2024-002
ProductName: Gold Pearl Necklace
Price: $3,200.00
UOM: PCS
Category: Necklaces
Material: Gold
Stones: Pearl
Karatage: 22K
StockAvailable: 15
```

### Example 3: Silver Earrings
```sql
ItemCode: SE001
LotNo: LOT2024-003
ProductName: Silver Earrings
Price: $850.00
UOM: PAIR
Category: Earrings
Material: Silver
Stones: Emerald
Karatage: 925
StockAvailable: 40
```

---

## ?? Vendor Dashboard Features

### Product Management
- ? Add new products
- ? Update product details
- ? Update inventory/stock
- ? Upload product images
- ? Activate/deactivate products
- ? View product sales statistics

### Order Management
- View orders containing vendor products
- Track order status
- View customer reviews for products

### Analytics
- Total products listed
- Total products sold
- Revenue generated
- Average product rating
- Low stock alerts

### Profile Management
- Update business information
- Update contact details
- View vendor rating
- View activity log

---

## ?? Vendor API Endpoints

### Authentication
```
POST /api/vendor/register
POST /api/vendor/login
POST /api/vendor/logout
```

### Product Management
```
GET    /api/vendor/products              - Get all vendor products
GET    /api/vendor/products/{id}         - Get specific product
POST   /api/vendor/products              - Add new product
PUT    /api/vendor/products/{id}         - Update product
DELETE /api/vendor/products/{id}         - Delete product
PATCH  /api/vendor/products/{id}/stock   - Update stock
```

### Orders
```
GET /api/vendor/orders                   - Get orders with vendor products
GET /api/vendor/orders/{id}              - Get order details
```

### Analytics
```
GET /api/vendor/analytics/dashboard      - Get dashboard stats
GET /api/vendor/analytics/sales          - Get sales report
GET /api/vendor/analytics/products       - Get product performance
```

---

## ??? Security Features

### Account Security
- Password hashing with salt (BCrypt recommended)
- 5 failed login attempts ? 20-minute lockout
- Activity logging to `VendorActivityLog`
- IP address tracking

### Approval Workflow
- New vendors cannot login until approved
- Admin must set `IsApproved = 1`
- Admin can deactivate vendor accounts (`IsActive = 0`)

### Product Validation
- Unique constraint on (VendorId, ItemCode, LotNo)
- Price validation (must be positive)
- Stock validation (must be >= 0)
- Required fields validation

---

## ?? Implementation Example (C#)

### Vendor Registration
```csharp
[HttpPost("vendor/register")]
public async Task<IActionResult> VendorRegister([FromBody] VendorRegistrationModel model)
{
    // Validate model
    if (!ModelState.IsValid)
        return BadRequest(ModelState);
    
    var hashedPassword = HashPassword(model.Password);
    var salt = GenerateSalt();
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand(@"
            INSERT INTO Vendors (VendorUserName, VendorEmail, PasswordHash, PasswordSalt, 
                                VendorFirstName, VendorLastName, BusinessName, PhoneNumber, 
                                BusinessAddress, IsActive, IsApproved)
            VALUES (@UserName, @Email, @PasswordHash, @Salt, @FirstName, @LastName, 
                    @BusinessName, @Phone, @Address, 1, 0)", conn);
        
        cmd.Parameters.AddWithValue("@UserName", model.UserName);
        cmd.Parameters.AddWithValue("@Email", model.Email);
        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
        cmd.Parameters.AddWithValue("@Salt", salt);
        cmd.Parameters.AddWithValue("@FirstName", model.FirstName);
        cmd.Parameters.AddWithValue("@LastName", model.LastName);
        cmd.Parameters.AddWithValue("@BusinessName", model.BusinessName);
        cmd.Parameters.AddWithValue("@Phone", model.PhoneNumber);
        cmd.Parameters.AddWithValue("@Address", model.BusinessAddress);
        
        conn.Open();
        await cmd.ExecuteNonQueryAsync();
        
        return Ok(new { message = "Registration successful. Awaiting admin approval." });
    }
}
```

### Add Vendor Product
```csharp
[HttpPost("vendor/products")]
[Authorize(Roles = "Vendor")]
public async Task<IActionResult> AddProduct([FromBody] VendorProductModel model)
{
    var vendorId = GetVendorIdFromToken(); // Extract from JWT
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand(@"
            INSERT INTO VendorProducts (VendorId, ItemCode, LotNo, ProductName, Description,
                                       Price, UOM, Category, Material, Stones, Karatage,
                                       StockAvailable, ProductImage, IsActive)
            VALUES (@VendorId, @ItemCode, @LotNo, @ProductName, @Description,
                    @Price, @UOM, @Category, @Material, @Stones, @Karatage,
                    @Stock, @Image, 1)", conn);
        
        cmd.Parameters.AddWithValue("@VendorId", vendorId);
        cmd.Parameters.AddWithValue("@ItemCode", model.ItemCode);
        cmd.Parameters.AddWithValue("@LotNo", model.LotNo);
        cmd.Parameters.AddWithValue("@ProductName", model.ProductName);
        cmd.Parameters.AddWithValue("@Description", model.Description ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Price", model.Price);
        cmd.Parameters.AddWithValue("@UOM", model.UOM ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Category", model.Category ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Material", model.Material ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Stones", model.Stones ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Karatage", model.Karatage ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@Stock", model.StockAvailable);
        cmd.Parameters.AddWithValue("@Image", model.ProductImage ?? (object)DBNull.Value);
        
        conn.Open();
        await cmd.ExecuteNonQueryAsync();
        
        // Log activity
        await LogVendorActivity(vendorId, "Product Added", 
            $"Added product: {model.ItemCode}-{model.LotNo}");
        
        return Ok(new { message = "Product added successfully" });
    }
}
```

### Update Product Stock
```csharp
[HttpPatch("vendor/products/{id}/stock")]
[Authorize(Roles = "Vendor")]
public async Task<IActionResult> UpdateStock(int id, [FromBody] int newStock)
{
    var vendorId = GetVendorIdFromToken();
    
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        SqlCommand cmd = new SqlCommand(@"
            UPDATE VendorProducts 
            SET StockAvailable = @Stock, UpdatedDate = GETDATE()
            WHERE VendorProductId = @ProductId AND VendorId = @VendorId", conn);
        
        cmd.Parameters.AddWithValue("@Stock", newStock);
        cmd.Parameters.AddWithValue("@ProductId", id);
        cmd.Parameters.AddWithValue("@VendorId", vendorId);
        
        conn.Open();
        int affected = await cmd.ExecuteNonQueryAsync();
        
        if (affected == 0)
            return NotFound(new { message = "Product not found or access denied" });
        
        return Ok(new { message = "Stock updated successfully" });
    }
}
```

---

## ?? Vendor Dashboard UI Components

### Dashboard Overview
```
???????????????????????????????????????????????
?  Vendor Dashboard - Premium Jewelers Inc    ?
???????????????????????????????????????????????
?                                             ?
?  ?? Total Products: 125                     ?
?  ? Active Products: 118                    ?
?  ?? Products Sold: 347                      ?
?  ?? Revenue: $156,780.00                    ?
?  ? Rating: 4.5/5.0                         ?
?                                             ?
???????????????????????????????????????????????
```

### Product List View
```
???????????????????????????????????????????????
?  My Products                       [+ Add]   ?
???????????????????????????????????????????????
?  ItemCode  | Product Name      | Stock | $ ?
?  GR001     | Gold Diamond Ring |  25   |2500?
?  GN001     | Pearl Necklace    |  15   |3200?
?  SE001     | Silver Earrings   |  40   | 850?
?  ...                                        ?
???????????????????????????????????????????????
```

---

## ?? Getting Started as a Vendor

1. **Register**: Submit vendor registration form
2. **Wait for Approval**: Admin reviews and approves account
3. **Login**: Use credentials to access vendor dashboard
4. **Add Products**: Start adding products with details
5. **Manage Inventory**: Keep stock levels updated
6. **Track Sales**: Monitor product performance
7. **Respond to Reviews**: Engage with customer feedback

---

## ?? Support

For vendor-related issues:
- Email: vendor-support@ecomjew.com
- Admin Portal: Contact admin for approval status
- Repository: https://github.com/Avinash-3069/E_com_website.git

---

## ? Vendor Checklist

- [ ] Register vendor account
- [ ] Wait for admin approval
- [ ] Login to vendor dashboard
- [ ] Update business profile
- [ ] Add product categories
- [ ] Upload product images
- [ ] Set competitive pricing
- [ ] Maintain adequate stock levels
- [ ] Monitor sales analytics
- [ ] Respond to customer reviews
- [ ] Keep contact information updated

---

**Last Updated**: 2024
**Version**: 1.0
