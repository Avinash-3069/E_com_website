# PowerShell Script to Create EComJew.mdf Database
# Repository: https://github.com/Avinash-3069/E_com_website.git

$databaseName = "EComJew"
$appDataPath = "$PSScriptRoot\App_Data"
$mdfPath = "$appDataPath\$databaseName.mdf"
$ldfPath = "$appDataPath\${databaseName}_log.ldf"
$sqlScriptPath = "$appDataPath\CreateEComJewDatabase.sql"

Write-Host "Creating EComJew Database..." -ForegroundColor Green

# Check if LocalDB is installed
try {
    $localDBInstances = sqllocaldb info
    Write-Host "LocalDB instances found: $localDBInstances" -ForegroundColor Cyan
} catch {
    Write-Host "SQL Server LocalDB not found. Please install SQL Server LocalDB." -ForegroundColor Red
    exit 1
}

# Create LocalDB instance if needed
$instanceName = "MSSQLLocalDB"
try {
    sqllocaldb start $instanceName
    Write-Host "LocalDB instance started: $instanceName" -ForegroundColor Green
} catch {
    Write-Host "Creating LocalDB instance: $instanceName" -ForegroundColor Yellow
    sqllocaldb create $instanceName
    sqllocaldb start $instanceName
}

# Create the database using SqlCmd
$createDbScript = @"
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = '$databaseName')
BEGIN
    ALTER DATABASE [$databaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$databaseName];
END
GO

CREATE DATABASE [$databaseName]
ON PRIMARY
(
    NAME = '${databaseName}_Data',
    FILENAME = '$mdfPath',
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5MB
)
LOG ON
(
    NAME = '${databaseName}_Log',
    FILENAME = '$ldfPath',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);
GO
"@

# Write the script to a temp file
$tempSqlFile = "$appDataPath\CreateDB_Temp.sql"
$createDbScript | Out-File -FilePath $tempSqlFile -Encoding UTF8

# Execute the database creation
try {
    Write-Host "Creating database file at: $mdfPath" -ForegroundColor Cyan
    sqlcmd -S "(LocalDB)\$instanceName" -i $tempSqlFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Database created successfully!" -ForegroundColor Green
        
        # Now run the table creation script
        if (Test-Path $sqlScriptPath) {
            Write-Host "Creating tables and schema..." -ForegroundColor Cyan
            sqlcmd -S "(LocalDB)\$instanceName" -d $databaseName -i $sqlScriptPath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Tables created successfully!" -ForegroundColor Green
            }
        }
        
        Write-Host "`nDatabase Information:" -ForegroundColor Yellow
        Write-Host "  Database Name: $databaseName" -ForegroundColor White
        Write-Host "  MDF File: $mdfPath" -ForegroundColor White
        Write-Host "  LDF File: $ldfPath" -ForegroundColor White
        Write-Host "  Connection String: Data Source=(LocalDB)\$instanceName;AttachDbFilename=$mdfPath;Integrated Security=True" -ForegroundColor White
        Write-Host "  Git Repository: https://github.com/Avinash-3069/E_com_website.git" -ForegroundColor White
    } else {
        Write-Host "Error creating database." -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    # Clean up temp file
    if (Test-Path $tempSqlFile) {
        Remove-Item $tempSqlFile -Force
    }
}

Write-Host "`nSetup complete!" -ForegroundColor Green
