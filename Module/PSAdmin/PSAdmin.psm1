#---------------------------------------------------------[BEGIN\Base                    ]--------------------------------------------------------
<#

param(
    [Hashtable]$ArgumentList
)
if ($ArgumentList)
{
    if ($ArgumentList.VerbosePreference)
    {
        $VerbosePreference = $ArgumentList.VerbosePreference
    }
    if ($ArgumentList.DebugPreference)
    {
        $DebugPreference = $ArgumentList.DebugPreference
    }
}


#>

$Script:PSAdminConfig   = $null
$Script:PSAdminDB       = $null
$Script:PSAdminDBConfig = $null

$Script:PSAdminLocale =  & {
    write-host $PSScriptRoot
    $Path = "{0}/Locale/{1}/globalization.xml" -f $PSScriptRoot, [System.Globalization.CultureInfo]::CurrentCulture.Name
    if ( Test-Path $Path ) {
        return [xml](Get-Content $Path)
    }
    $Path = "{0}/Locale/Default/globalization.xml" -f $PSScriptRoot
    if ( Test-Path $Path ) {
        return [xml](Get-Content $Path)
    }
    throw "cannot load language locale"
}


function Write-Log
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [System.String[]]$Message,
        [ValidateSet("Information", "Verbose", "Debug", "Message", "Warning", "Success", "Failed", "Error", "Unknown")]
        [System.String]$Status = "Information",
        [int]$Offset = 0

    )

    $Pref = Get-Variable "*Preference" | Where-Object Name -EQ "$($Status)Preference"
    if (($Pref) -and ($Pref.Value -ne "Continue")) {
        return
    }

    Write-Host ("[{0}] " -f [DateTime]::UTCNow.ToString("HH:mm:ss.ffff")) -NoNewline
    Write-Host ("[{0,11}]" -f $Status.ToUpper()) -NoNewline

    #(Get-PSCallStack)[1]
    Write-Host (" " * ($Offset * 2)), "*", $Message
}

$ModuleName = "PSAdmin"
#---------------------------------------------------------[INIT\SQLite                   ]--------------------------------------------------------
Write-Log "SQLite.init.ps1" -Status Debug -Offset 2

#Throw "KevinException NotImplemented"

if ([System.Environment]::Is64BitProcess)
{
    $Libraries = Get-ChildItem -Path "$PSScriptRoot/x64/*.dll"
}
else 
{
    $Libraries = Get-ChildItem -Path "$PSScriptRoot/x86/*.dll"
}

Write-Log "Loading Dependencies" -Status Debug -Offset 3

#Load Libraries
foreach ($Lib in $Libraries) {
    try {
        Add-Type -Path $Lib.FullName
        Write-Log $Lib.BaseName -Status Debug -Offset 3
    }
    catch {
        Write-Log "Unable to load DLL: $($Lib.BaseName)" -Status Warning -Offset 3
        Write-Error [System.String]::Format("Unable to load DLL: {0}", $Lib.FullName)
    }
}
#---------------------------------------------------------[PRIVATE\Base                  ]--------------------------------------------------------
function New-PSAdminException
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.String]$ErrorID,

        [Parameter()]
        [System.String[]]$ArgumentList
    )

    begin
    {

    }

    process
    {
        $Exception = $Script:PSAdminLocale.GetElementById($ErrorID)

        if (!$Exception)
        {
            throw "Invalid Exception Name"
        }
        if ($ArgumentList) {
            return New-Object -TypeName $Exception.TypeName -ArgumentList ($Exception.Value -f $ArgumentList)
        }
        return New-Object -TypeName $Exception.TypeName -ArgumentList ($Exception.Value)

    }

    end 
    {

    }
}
#---------------------------------------------------------[PRIVATE\KeyVaultSecret        ]--------------------------------------------------------
function ConvertTo-PSAdminKeyVaultSecretValue
{
    param(
        [Parameter(Mandatory)]
        [System.String]$VaultName,
    
        [Parameter(Mandatory)]
        [System.String]$InputData
    )

    begin
    {

    }
    
    process
    {
        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName

        $EncKey = $KeyVault.VaultKey

        if ($KeyVault.Thumbprint)
        {
            $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $KeyVault.Thumbprint
            $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([byte[]]$Certificate.Certificate, $Certificate.Thumbprint)
            $EncKey = $x509.PrivateKey.Decrypt($EncKey, $True)
        }
        
        return ($InputData | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -Key $EncKey)
        
    }

    end 
    {

    }
}

function ConvertFrom-PSAdminKeyVaultSecretValue
{
    param(
        [Parameter(Mandatory)]
        [System.String]$VaultName,
    
        [Parameter(Mandatory)]
        [System.String]$InputData,

        [Parameter()]
        [Switch]$Decrypt
    )

    begin
    {

    }
    
    process
    {
        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName

        $EncKey = $KeyVault.VaultKey

        if ($KeyVault.Thumbprint)
        {
            $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $KeyVault.Thumbprint
            $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([byte[]]$Certificate.Certificate, $Certificate.Thumbprint)
            $EncKey = $x509.PrivateKey.Decrypt($EncKey, $True)
        }

        $SecureString = ($InputData | ConvertTo-SecureString -Key $EncKey)
        if ($Decrypt)
        {

            return [PSCredential]::new("_", $SecureString).GetNetworkCredential().Password
        }
        return $SecureString
        
    }

    end 
    {

    }
}
#---------------------------------------------------------[PRIVATE\SQLite                ]--------------------------------------------------------
function Connect-PSAdminSQLite {
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]$ConnectionType,
        [Parameter()]
        [System.String]$ConnectionString    = "Data Source='{0}';Pooling={1};FailIfMissing={2};Synchronous={3};",
        [Parameter()]
        [System.String]$DataSource          = "PSAdmin.DB",
        [Parameter()]
        [ValidateSet("True", "False")]
        [System.String]$Pooling                      = $True,
        [Parameter()]
        [ValidateSet("True", "False")]
        [System.String]$FailIfMissing                = $False,
        [Parameter()]
        [ValidateSet("Full")]
        [System.String]$Synchronous                  = "Full",
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [System.String]$Path
    )

    [System.IO.Directory]::SetCurrentDirectory($Path)
    $ConnectionString = $ConnectionString -f $DataSource, $Pooling, $FailIfMissing, $Synchronous
    Write-Debug ("{0}: {1}" -f $MyInvocation.MyCommand, "Connecting to Database.")

    return [System.Data.SQLite.SQLiteConnection]::new($ConnectionString)
}
function Disconnect-PSAdminSQLite() {
	param(
		[Parameter(Mandatory)]
		[System.Data.SQLite.SQLiteConnection]$Database
	)
	Write-Debug ("{0}: {1}" -f $MyInvocation.MyCommand, "Disconnecting from database.")
	$Database.Dispose()
}
function Get-PSAdminSQLiteObject
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Data.SQLite.SQLiteConnection]$Database,
        [Parameter(Mandatory)]
        [System.String]$Table,
        [Parameter(Mandatory)]
        [System.String[]]$Keys,
        [Parameter(Mandatory)]
        [PSCustomObject]$InputObject
    )
    
    begin
    {

    }

    process
    {

        $Filter = foreach ($Item in $InputObject.PSObject.Properties)
        {
            
            if ($Keys -eq $Item.Name) {

                ("``{0}`` LIKE '{1}'" -f $Item.Name, $Item.Value.Replace('_', '\_').Replace("*", "%") )
            }
        }

        $Query = "SELECT * From ``{0}`` WHERE {1} ESCAPE '\'" -f $Table, ($Filter -join " AND ")
        #$Query | Write-Host
        $Result = Request-PSAdminSQLiteQuery -Database $Database -Query $Query
        $Result
        
    }

    end
    {

    }
}
function Invoke-PSAdminSQLiteQuery
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[System.Data.SQLite.SQLiteConnection]$Database,
		[String]$Query
	)
	
	begin
	{

		$Database.Open()

	}

	process
	{

		Write-Verbose ("{0}: {1}" -f $MyInvocation.MyCommand, $Query)
		$Call = [System.Data.SQLite.SQLiteCommand]::new($Query, $Database)

		$Result = -1
		try {
			$result = $call.ExecuteNonQuery()
		} catch {
			$result = -1
		}
		$Result

	}

	end
	{
		$Database.Close()
	}
}
function New-PSAdminSQLiteObject
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Data.SQLite.SQLiteConnection]$Database,
        [Parameter(Mandatory)]
        [System.String[]]$Keys,
        [Parameter(Mandatory)]
        [System.String]$Table,
        [Parameter(Mandatory)]
        [PSObject]$InputObject
    )
    begin
    {
        
        $Database.Open()

    }

    process
    {

        $cmd = [System.Data.SQLite.SQLiteCommand]::new($Database)
 
        $tableSchema = new-object System.Collections.Arraylist
        $tableValues = new-object System.Collections.Arraylist

        foreach ($i in $InputObject.PSObject.Properties) {
            $tableSchema.Add($i.Name) | out-null
            $tableValues.Add("@"+$i.Name) | out-null
            $cmd.Parameters.AddWithValue("@"+$i.Name, $i.Value) | out-null
        }

        $Query = "INSERT INTO {0} ({1}) VALUES ({2}) " -f $Table, ($tableSchema -join ","), ( $tableValues -join ",")
        $cmd.CommandText = $Query
    
        $result = -1
        
        try {
            $result = $cmd.ExecuteNonQuery();
        }
        catch {
            $result = -1
        }

        return $result

    }

    end
    {

        $Database.Close()

    }

}
function New-PSAdminSQLiteTable
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Data.SQLite.SQLiteConnection]$Database,
        [Parameter(Mandatory)]
        [System.String]$Table,
        [Parameter(Mandatory)]
        [PSCustomObject]$PSCustomObject
    )
    begin
    {

    }
    process
    {
        $Properties = New-Object System.Collections.ArrayList

        foreach ($i in $PSCustomObject.PSObject.Properties)
        {
    
            $NameType = $null
            
            Switch ($i.TypeNameOfValue) {
                "System.String" { $NameType = "String" }
                "System.Int32" { $NameType = "INTEGER" }
                "System.Char[]" { $NameType = "BLOB" }
                "System.Byte[]" { $NameType = "BLOB" }
                Default { write-host $i.Name, $i.TypeNameOfValue }
            }

            $Properties.Add( ("``{0}`` {1}" -f $i.Name, $NameType)) | out-null
    
        }
        
        Invoke-PSAdminSQLiteQuery -Database $Database -Query ("CREATE TABLE IF NOT EXISTS ``{0}`` ({1})" -f $Table, ($Properties -join ", "))
    
    }

    end
    {

    }
}
function Remove-PSAdminSQLiteObject
{
    [CmdletBinding()]
    Param(
		[Parameter(Mandatory)]
		[System.Data.SQLite.SQLiteConnection]$Database,
        [Parameter(Mandatory)]
        [System.String]$Table,
        [Parameter(Mandatory)]
        [System.String[]]$Keys,
        [Parameter(Mandatory)]
        [PSCustomObject]$InputObject
    )

    begin
    {

    }

    process
    {
        $Filter = foreach ($Item in $InputObject.PSObject.Properties)
        {
            if ($Keys -eq $Item.Name) {
                "``{0}`` LIKE '{1}'" -f $Item.Name, $Item.Value.Replace('*', '%')
            }
        }

        $Filter = $Filter -join " AND "
        
        if ([System.String]::IsNullOrEmpty($Filter))
        {
            Write-Error "PSCustomObject InputObject must contain a $Key Property"
        }

        $Query = "DELETE FROM {0} WHERE {1}" -f $Table, $Filter
        Invoke-PSAdminSQLiteQuery -Database $Database -Query $Query
        
    }

    end
    {

    }
}

function Request-PSAdminSQLiteQuery() {
	[CmdletBinding()]
    param(
		[Parameter(Mandatory)]
		[System.Data.SQLite.SQLiteConnection]$Database,
		[Parameter(Mandatory)]
		[String]$Query
	)
	begin
	{
		
		$Database.Open()

	}

	process
	{

		$cmd = [System.Data.SQLite.SQLiteCommand]::new($Query, $Database)

		$reader = $cmd.ExecuteReader()

		while ($reader.Read()) {
			
			$Result = [PSCustomObject]@{}

			foreach ($i in (0..$($reader.FieldCount - 1))) {
				$Result | Add-Member -MemberType NoteProperty -Name $reader.GetName($i) -Value (. ({$reader.GetValue($i)}, { $null } )[$reader.IsDBNull($i)])
			}

			$Result

		}
		
	}

	end
	{

		$Database.Close()

	}
}

function Set-PSAdminSQLiteObject
{
    [CmdletBinding()]    
    param(
		[Parameter(Mandatory)]
		[System.Data.SQLite.SQLiteConnection]$Database,
        [Parameter(Mandatory)]
        [System.String]$Table,
        [Parameter(Mandatory)]
        [System.String[]]$Keys,
        [Parameter(Mandatory)]
        [PSCustomObject]$InputObject
    )

    begin
    {

        $Database.Open()

    }

    process
    {

        $Filter = foreach ($Item in $InputObject.PSObject.Properties)
        {
            if ($Keys -eq $Item.Name) {
                "``{0}`` LIKE '{1}'" -f $Item.Name, $Item.Value
            }
        }

        $Filter = $Filter -join " AND "

        if ([System.String]::IsNullOrEmpty($Filter))
        {
            Write-Error "PSCustomObject InputObject must contain a $Key Property"
        }

        $cmd = [System.Data.SQLite.SQLiteCommand]::new($Database)

        $tableSchema = new-object System.Collections.Arraylist
        
        foreach ($i in $InputObject.PSObject.Properties) {
            if ($Keys -eq $i.Name) {
                Continue;
            }
            $tableSchema.Add(("{0} = @{0}" -f $i.Name)) | out-null
            $cmd.Parameters.AddWithValue($i.Name, $i.Value) | out-null
        }

        $Query = "UPDATE {0} SET {1} WHERE {2}" -f $table, ($tableSchema -join ","), $Filter

        $cmd.CommandText = $Query
        $result = -1
        
        try {
            $result = $cmd.ExecuteNonQuery();
        }
        catch {
            $result = -1
        }

        return $result

    }
    end
    {

        $Database.Close()

    }
}
#---------------------------------------------------------[PUBLIC\KeyVault               ]--------------------------------------------------------
function Get-PSAdminKeyVault {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*",

        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [System.String]$VaultName = "*"

    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Id")
            Table           = "PSAdminKeyVault"
            InputObject = [PSCustomObject]@{
                Id                      = $Id
                VaultName               = $VaultName
            }
        }
        $Results = Get-PSAdminSQliteObject @DBQuery
        
        foreach ($Result in $Results) {
            $Result.PSObject.TypeNames.Insert(0, "PSAdminKeyVault.PSAdmin.Module")            
            $Result
        }
    }

    end
    {
        Cleanup
    }

}
function New-PSAdminKeyVault
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.String]$VaultName,
        
        [Parameter()]
        [System.String]$Location            = "",

        [Parameter()]
        [System.String]$VaultURI            = "",
        
        [Parameter()]
        [System.String]$SoftDeleteEnabled   = "True",

        [Parameter()]
        [System.String[]]$Tags              = ("")
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {

        $VaultKey = new-object byte[](32)
        $null = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($VaultKey)

        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName")
            Table           = "PSAdminKeyVault"
            InputObject     = [PSCustomObject]@{
                Id                              = [Guid]::NewGuid().ToString().Replace('-', '')
                VaultName                       = $VaultName
                Location                        = $Location
                VaultURI                        = $VaultURI
                SKU                             = ""
                SoftDeleteEnabled               = $SoftDeleteEnabled
                Tags                            = ($Tags -join ";")
                Thumbprint                      = ""
                VaultKey                        = $VaultKey
                ResourceGroup                   = ""
                ResourceID                      = ""
            }
        }

        $Result = Get-PSAdminKeyVault -VaultName $VaultName

        if ($Result)
        {
            Cleanup
            throw New-PSAdminException -ErrorID KeyVaultExceptionVaultNameExists -ArgumentList $VaultName
            
        }

        $Result = New-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }

    }

    end
    {
        Cleanup
    }
}

function Protect-PSAdminKeyVault
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [System.String]$VaultName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2)]
        [System.String]$Thumbprint
    )

    begin
    {

    }

    process
    {

        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName
        $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $Thumbprint

        #Check if Thumbprint is already installed
        if ($KeyVault.Thumbprint)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionCertificateNotInstalled
        }
        
        #Check Result Counts
        if (@($KeyVault).Count -ne 1)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionResultCount -ArgumentList "VaultName", $VaultName, 1, @($KeyVault).Count
        }

        if (@($Certificate).Count -ne 1)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionResultCount -ArgumentList "CertificateThumbprint", $Thumbprint, 1, @($KeyVault).Count
        }
        
        #Load Certificate
        $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([Byte[]]$Certificate.Certificate, $Thumbprint)

        if ((!$x509.HasPrivateKey) -or (!$x509.PrivateKey)) {
            throw New-PSAdminException -ErrorID KeyVaultCertificateExceptionPrivateKey
        }

        try {
            $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
            $DBQuery = @{
                Database        = $Database
                Keys            = ("VaultName", "Id")
                Table           = "PSAdminKeyVault"
                InputObject = [PSCustomObject]@{
                    VaultName               = $VaultName
                    Id                      = $KeyVault.Id
                    Thumbprint              = $x509.Thumbprint
                    VaultKey                = [byte[]]$x509.PublicKey.Key.Encrypt($KeyVault.VaultKey, $True)
                }
            }
            
            $Result = Set-PSAdminSQliteObject @DBQuery
            if ($Result -eq -1)
            {
                Cleanup
                throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
            }

        }
        catch {
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }
        finally {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $x509.Dispose()
        <#
        $EncStr = [System.Text.Encoding]::UTF8.GetBytes($InputString)
           

        $DecryptedValue = "Hello world from Encrypted Value"
        $DecryptedValue = [System.Text.Encoding]::UTF8.GetBytes($DecryptedValue)
        #Test Encryption
        $EncryptedValue = $x509.PublicKey.Key.EncryptValue([byte[]]$DecryptedValue)

        $EncryptedValue

        $Certificate | ft | Out-String | Write-Host -ForegroundColor Cyan
        $KeyVault | ft | out-String | Write-Host -ForegroundColor Yellow
        #>
    }

    end
    {

    }
}
function Remove-PSAdminKeyVault
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*",

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName

    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        
        if (!$PSCmdlet.ShouldProcess(($Script:PSAdminLocale.GetElementById("KeyVaultRemoveAll").Value -f $VaultName)))
        {
            return
        }
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Id")
            Table           = "PSAdminKeyVault"
            InputObject     = [PSCustomObject]@{
                Id              = $Id
                VaultName       = $VaultName
            }
        }

        Write-Debug -Message ($Script:PSAdminLocale.GetElementById("KeyVaultRemoveCertificates").Value -f $VaultName)
        Remove-PSAdminKeyVaultCertificate -VaultName $VaultName -Name "*"

        Write-Debug -Message ($Script:PSAdminLocale.GetElementById("KeyVaultRemoveSecrets").Value -f $VaultName)
        Remove-PSAdminKeyVaultSecret -VaultName $VaultName -Name "*"
        
        $Result = Remove-PSAdminSQliteObject @DBQuery
        
        if ($Result -eq -1)
        {

            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }

    }
    
    end
    {
        Cleanup
    }

}
function Set-PSAdminKeyVault
{
    [CmdletBinding()]
    param(
        #[Parameter(ValueFromPipelineByPropertyName)]
        #[System.String]$Id = "*",

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$VaultURI,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$SKU,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("True", "False")]
        [System.String]$SoftDeleteEnabled,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]]$Tags

    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Id")
            Table           = "PSAdminKeyVault"
            InputObject = [PSCustomObject]@{
                VaultName               = $VaultName
                Id                      = $Id
            }
        }

        $Result = Set-PSAdminSQliteObject @DBQuery
        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }
        
    }

    end
    {
        Cleanup
    }

}
function Unprotect-PSAdminKeyVault
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [System.String]$VaultName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2)]
        [System.String]$Thumbprint
    )

    begin
    {

    }

    process
    {
        #Try Load
        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName
        $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $Thumbprint

        #Check if Thumbprint is already installed
        if (!$KeyVault.Thumbprint)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionCertificateNotInstalled
        }

        #Check Result Counts
        if (@($KeyVault).Count -ne 1)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionResultCount -ArgumentList "VaultName", $VaultName, 1, @($KeyVault).Count
        }

        if (@($Certificate).Count -ne 1)
        {
            throw New-PSAdminException -ErrorID KeyVaultExceptionResultCount -ArgumentList "CertificateThumbprint", $Thumbprint, 1, @($KeyVault).Count
        }

        #Load Certificate
        $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([Byte[]]$Certificate.Certificate, $Thumbprint)

        if ((!$x509.HasPrivateKey) -or (!$x509.PrivateKey)) {
            throw New-PSAdminException -ErrorID KeyVaultCertificateExceptionPrivateKey
        }

        try {
            
            $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
            $DBQuery = @{
                Database        = $Database
                Keys            = ("VaultName", "Id")
                Table           = "PSAdminKeyVault"
                InputObject = [PSCustomObject]@{
                    VaultName               = $VaultName
                    Id                      = $KeyVault.Id
                    Thumbprint              = ""
                    VaultKey                = $x509.PrivateKey.Decrypt($KeyVault.VaultKey, $True)
                }
            }
            $Result = Set-PSAdminSQliteObject @DBQuery
            if ($Result -eq -1)
            {
                Cleanup
                throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
            }

        }
        catch {
            Throw $_
        }
        finally {
            Disconnect-PSAdminSQLite -Database $Database
        }
    }

    end
    {

    }
}
#---------------------------------------------------------[PUBLIC\KeyVaultCertificate    ]--------------------------------------------------------
function Get-PSAdminKeyVaultCertificate {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*",

        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [System.String]$VaultName = "*",

        [Parameter(ValueFromPipelineByPropertyName, Position = 1)]
        [System.String]$Name = "*",

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Thumbprint = "*"
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {

        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id", "Thumbprint")
            Table           = "PSAdminKeyVaultCertificate"
            InputObject = [PSCustomObject]@{
                Thumbprint              = $Thumbprint
                VaultName               = $VaultName
                Name                    = $Name
                Id                      = $Id
            }
        }
        $Results = Get-PSAdminSQliteObject @DBQuery
        foreach ($Result in $Results) {
            $Result.PSObject.TypeNames.Insert(0, "PSAdminKeyVaultCertificate.PSAdmin.Module")            
            $Result
        }
        
    }

    end
    {
        Cleanup
    }

}
function Import-PSAdminKeyVaultCertificate
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = "ImportFromString")]
        [Parameter(Mandatory, ParameterSetName = "ImportFromFile")]
        [System.String]$VaultName,

        [Parameter(ParameterSetName = "ImportFromString")]
        [Parameter(ParameterSetName = "ImportFromFile")]
        [System.String]$Name,

        [Parameter(Mandatory, ParameterSetName = "ImportFromFile")]
        [System.String]$FilePath,
        
        [Parameter(Mandatory, ParameterSetName = "ImportFromString")]
        [System.String]$CertificateString,

        [Parameter(Mandatory, ParameterSetName = "ImportFromString")]
        [Parameter(Mandatory, ParameterSetName = "ImportFromFile")]
        [SecureString]$Password,
        
        [Parameter(ParameterSetName = "ImportFromString")]
        [Parameter(ParameterSetName = "ImportFromFile")]
        [System.String[]]$Tag = ""
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {

        $Result = Get-PSAdminKeyVaultCertificate -Name $Name -VaultName $VaultName
        if ($Result)
        {
            Cleanup
            throw New-PSAdminException -ErrorID KeyVaultCertificateExceptionExists -ArgumentList $VaultName, $Name
        }

        switch ($PSCmdlet.ParameterSetName)
        {
            "ImportFromFile" {
                $CertificateByteArray = Get-Content -Path $FilePath -Encoding Byte
            }
            "ImportFromString" {
                $CertificateByteArray = [System.Convert]::FromBase64String($CertificateString)
            }
        }

        $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([byte[]]$CertificateByteArray, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

        if ((!$x509.HasPrivateKey) -or (!$x509.PrivateKey)) {
            $x509.Dispose()
            Cleanup
            throw New-PSAdminException -ErrorID KeyVaultCertificateExceptionPrivateKey
        }

        if ([String]::IsNullOrWhiteSpace($Name))
        {
            $Name = $x509.FriendlyName
        }

        $x509Password = $x509.Thumbprint | ConvertTo-SecureString -AsPlainText -Force
        $RawCert = $x509.Export( [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $x509Password )

        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name")
            Table           = "PSAdminKeyVaultCertificate"
            InputObject = [PSCustomObject]@{
                Certificate             = $RawCert
                KeyId                   = $x509.SerialNumber
                SecretId                = $x509.SerialNumber
                Thumbprint              = $x509.Thumbprint
                RecoveryLevel           = "Default"
                ScheduledPurgeDate      = ""
                DeletedDate             = ""
                Enabled                 = "True"
                Expires                 = $x509.NotAfter
                NotBefore               = $x509.NotBefore
                Created                 = [DateTime]::UtcNow
                Updated                 = [DateTime]::UtcNow
                Tags                    = $Tag -join ";"
                VaultName               = $VaultName
                Name                    = $Name
                Version                 = 0
                Id                      = [guid]::NewGuid().ToString().Replace('-', '')
            }
        }

        $x509.Dispose()

        $Result = New-PSAdminSQliteObject @DBQuery
        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }
    }

    end
    {
        Cleanup
    }

}

#$FileString = Get-Content $PSScriptRoot\cert.pfx -Encoding Byte
#$FileString = [System.Convert]::ToBase64String($FileString)

#Write-Host "MyHash", $FileString
#$Password = ConvertTo-SecureString -String "123456" -AsPlainText -force
#Import-PSAdminKeyVaultCertificate -VaultName "Default" -CertificateString $FileString -Password $Password


#$FileName = Get-ChildItem $PSScriptRoot\cert.pfx
#$Password = ConvertTo-SecureString -String "123456" -AsPlainText -force
#Import-PSAdminKeyVaultCertificate -VaultName "Default" -FilePath $FileName.FullName.ToString() -Password $Password


<#
$FileName = Get-Item .\Source\KeyVaultCertificate\cert.pfx
$Password = ConvertTo-SecureString -String "123456" -AsPlainText -force
Import-PSAdminKeyVaultCertificate -VaultName "Default" -FilePath $FileName.FullName.ToString() -Password $Password
#>
#Encrypt 
<#

$DBObject = New-Object PSObject | Select UserName,ENCRYPTEDHASH,ENCRYPTED,x509ThumbPrint,x509Serial,x509Expire,x509DNSName
    $DBObject.USERNAME = $Credential.USERNAME
    # Generate New Encryption key for Database
    $key = new-object byte[](32)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
    $DBObject.ENCRYPTEDHASH = Get-CentralAdminSecureVaultEncryptedValue -Value $Credential.USERNAME -Key $Credential.Password
    $DBObject.ENCRYPTED = Get-CentralAdminSecureVaultEncryptedValue -Value ([System.Text.Encoding]::ASCII.GetString($KEY)) -Key $Credential.Password
    $KEY = $null # Cleanup Memory

#>
function Remove-PSAdminKeyVaultCertificate
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*",

        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [System.String]$VaultName = "*",

        [Parameter(ValueFromPipelineByPropertyName, Position = 1)]
        [System.String]$Name = "*",

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Thumbprint = "*"
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig        
    }

    process
    {

        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id", "Thumbprint")
            Table           = "PSAdminKeyVaultCertificate"
            InputObject = [PSCustomObject]@{
                Thumbprint              = $Thumbprint
                VaultName               = $VaultName
                Name                    = $Name
                Id                      = $Thumbprint
            }
        }

        $Result = Remove-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }
    }

    end
    {
        Cleanup
    }
}
#---------------------------------------------------------[PUBLIC\KeyVaultSecret         ]--------------------------------------------------------
function Get-PSAdminKeyVaultSecret
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$Name = "*",

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*",

        [Parameter()]
        [Switch]$Decrypt
    )

    begin
    {
        $PSTypeName = "PSAdminKeyVaultSecret.PSAdmin.Module"
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id")
            Table           = "PSAdminKeyVaultSecret"
            InputObject     = [PSCustomObject]@{
                VaultName       = $VaultName
                Name            = $Name
                Id              = $Id
            }
        }

        $Results = Get-PSAdminSQliteObject @DBQuery

        foreach ($Result in $Results) {
            $Result.SecretValue = ConvertFrom-PSAdminKeyVaultSecretValue -VaultName $VaultName -InputData $Result.SecretValue -Decrypt:$Decrypt
            $Result.PSObject.TypeNames.Insert(0, "PSAdminKeyVaultSecret.PSAdmin.Module")
            $Result
        }

    }
    
    end
    {
        Cleanup
    }

}
function New-PSAdminKeyVaultSecret
{

    #New-PSAdminKeyVaultSecret -VaultName "LocalAdministrator" -Name "127.0.0.1" -Enabled True -ContentType txt -SecretValue "12345"

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Version,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("True", "False")]
        [System.String]$Enabled,

        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$Expires,

        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$NotBefore = [DateTime]::UtcNow,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("txt", "blob")]
        [System.String]$ContentType = "txt",

        [Parameter(ValueFromPipelineByPropertyName)]
        [String[]]$Tags,

        [Parameter(ValueFromPipelineByPropertyName)]
        [PSObject]$SecretValue
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig

    }

    process
    {
        $KeyVault = @(Get-PSAdminKeyVault -VaultName $VaultName)

        if ($KeyVault.Count -ne 1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID KeyVaultExceptionResultCount -ArgumentList "VaultName", $VaultName, 1, $KeyVault.Count
        }

        $Result = Get-PSAdminKeyVaultSecret -Name $Name -VaultName $VaultName
        if ($Result)
        {
            Cleanup
            throw "Cannot create an object with Name '$($Name)' already exists"
        }

        $Id = [Guid]::NewGuid().ToString().Replace('-', '')
        $Created = [DateTime]::UTCNow
        $Updated = [DateTime]::UTCNow

        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id")
            Table           = "PSAdminKeyVaultSecret"
            InputObject     = [PSCustomObject]@{
                VaultName   = $VaultName
                Name        = $Name
                Version     = $Version
                Id          = $Id
                Enabled     = $Enabled
                Expires     = $Expires
                NotBefore   = $NotBefore
                Created     = $Created
                Updated     = $Updated
                ContentType = $ContentType
                Tags        = $Tags
                SecretValue = ConvertTo-PSAdminKeyVaultSecretValue -VaultName $VaultName -InputData $SecretValue
            }
        }
        
        $Result = New-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }

    }

    end
    {
        Cleanup
    }

}
function Remove-PSAdminKeyVaultSecret
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,
        
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id = "*"
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id")
            Table           = "PSAdminKeyVaultSecret"
            InputObject     = [PSCustomObject]@{
                VaultName       = $VaultName
                Name            = $Name
                Id              = $Id
            }
        }

        $Result = Remove-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {

            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }

    }
    
    end
    {
        Cleanup
    }

}
function Set-PSAdminKeyVaultSecret
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Version,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("True", "False")]
        [System.String]$Enabled,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$Expires,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$NotBefore = [DateTime]::UtcNow,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("txt", "blob")]
        [System.String]$ContentType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String[]]$Tags,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [PSObject]$SecretValue
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $Updated = [DateTime]::UTCNow
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Name", "Id")
            Table           = "PSAdminKeyVaultSecret"
            InputObject     = [PSCustomObject]@{}
        }

        #Needs to be dynamically generated for it to work properly
        foreach ($Param in $PSBoundParameters.GetEnumerator())
        {
            if ( ($Param.Key -eq "SecretValue") -and (!([System.String]::IsNullOrEmpty($SecretValue))) )
            {
                $SecValue = ConvertTo-PSAdminKeyVaultSecretValue -VaultName $VaultName -InputData $SecretValue
                
                Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $SecValue
                continue;
            }
            Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $Param.Value
        }
        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "Updated" -Value ([DateTime]::UtcNow)

        $Result = Set-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {
            Cleanup
            throw New-PSAdminException -ErrorID ExceptionUpdateDatabase
        }

    }
    
    end
    {
        Cleanup
    }

}
#---------------------------------------------------------[PUBLIC\Machine                ]--------------------------------------------------------
function Get-PSAdminMachine
{
    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)]
        [System.String]$Name        = "*",
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id          = "*",
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$SQLIdentity = "*"
    )

    begin
    {
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    
        $PSProperties = $Script:PSAdminMachineSchema.DB.Table.DefaultDisplayPropertySet.Split(",").Trim()
        $PSTypeName = $Script:PSAdminMachineSchema.DB.Table.TypeName
        $PSTypeData = Get-TypeData -TypeName $PSTypeName

        if (!$PSTypeData)
        {
            Update-TypeData -TypeName $PSTypeName -DefaultDisplayPropertySet $PSProperties
        }

    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = $Script:PSAdminMachineSchema.DB.Table.KEY | ForEach-Object { $_ }
            Table           = $Script:PSAdminMachineSchema.DB.Table.Name
            InputObject     = [PSCustomObject]@{
                SQLIdentity     = $SQLIdentity
                Id              = $Id
                Name            = $Name
            }
        }

        $Results = Get-PSAdminSQliteObject @DBQuery

        foreach ($Result in $Results) {
            $Result.PSObject.TypeNames.Insert(0, $PSTypeName)            
            $Result
        }


    }

    end
    {
        Disconnect-PSAdminSQLite -Database $Database
    }
}
function New-PSAdminMachine
{
    [CmdletBinding()]
    param(
        
    )
    dynamicParam
    {

        $dynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        #Get Parameters
        
        $Properties = $Script:PSAdminMachineSchema.DB.Table.ITEM | ForEach-Object { $_ }

        [Parameter()][System.String]$_paramHelper = $null

        foreach ($item in $Properties)
        {

            $itemCollection = @((Get-Variable '_paramHelper').Attributes)
            $itemParam = New-Object System.Management.Automation.RuntimeDefinedParameter($item, [System.String], $itemCollection)
            $dynamicParameters.Add($item, $itemParam)
            
        }
        
        Remove-Variable '_paramHelper'
        return $dynamicParameters
    }

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $Keys = "Name"
        
        $HasKey = foreach ($Param in $PSBoundParameters.GetEnumerator()) {
            if ($Keys -contains $Param.Key)
            {
                $true
                break
            }
        }

        if (!$HasKey)
        {
            Cleanup
            Throw "You must specify a valid Searchable Key example:'Name'"
        }

        $DBQuery = @{
            Database        = $Database
            Keys            = $Script:PSAdminMachineSchema.DB.Table.KEY | ForEach-Object { $_ }
            Table           = $Script:PSAdminMachineSchema.DB.Table.Name
            InputObject     = [PSCustomObject]@{}
        }

        foreach ($Param in $PSBoundParameters.GetEnumerator())
        {
            Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $Param.Value
        }

        if ([System.String]::IsNullOrEmpty($DBQuery.InputObject.Name))
        {
            Cleanup
            throw "A name must be specified"
        }

        $Guid = [Guid]::NewGuid().ToString()
        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "Id" -Value $Guid -Force
        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "SQLIdentity" -Value $Guid -Force
        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "Created" -Value ([DateTime]::UtcNow)
        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "Updated" -Value ([DateTime]::UtcNow)

        $Result = Get-PSAdminMachine -Name $DBQuery.InputObject.Name
        if ($Result)
        {
            Cleanup
            throw "Cannot create an object with Name '$($DBQuery.InputObject.Name)' already exists"
        }

        $Result = New-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {
            Cleanup
            throw "Unable to Update Item"
        }

    }

    end
    {
        Cleanup
    }

}
function Remove-PSAdminMachine
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Position=0, ValueFromPipelineByPropertyName)]
        [System.String]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id,
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$SQLIdentity
    )

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $DBQuery = @{
            Database        = $Database
            Keys            = $Script:PSAdminMachineSchema.DB.Table.KEY | ForEach-Object { $_ }
            Table           = $Script:PSAdminMachineSchema.DB.Table.Name
            InputObject     = [PSCustomObject]@{}
        }

        $HasKey = foreach ($Param in $PSBoundParameters.GetEnumerator()) {
            if ($DBQuery.Keys -contains $Param.Key)
            {
                $true
                break
            }
        }

        if (!$HasKey)
        {
            Cleanup
            Throw "You must specify a valid Searchable Key example:'$Keys'"
        }

        foreach ($Param in $PSBoundParameters.GetEnumerator())
        {
            Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $Param.Value
        }

        $Result = Remove-PSAdminSQliteObject @DBQuery

        if ($Result -eq -1)
        {

            Cleanup
            Throw "Unable to remove Item"
        }

    }

    end
    {
        Cleanup
    }
}
function Set-PSAdminMachine
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$Name
    )
    dynamicParam
    {
        $SkipParam = "Name"
        $dynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        #Get Parameters
        
        $Properties = $Script:PSAdminMachineSchema.DB.Table.ITEM | ForEach-Object { $_ }

        [Parameter()][System.String]$_paramHelper = $null

        foreach ($item in $Properties)
        {
            if ($SkipParam -Contains $Item)
            {
                continue;
            }
            $itemCollection = @((Get-Variable '_paramHelper').Attributes)
            $itemParam = New-Object System.Management.Automation.RuntimeDefinedParameter($item, [System.String], $itemCollection)
            $dynamicParameters.Add($item, $itemParam)
            
        }
        
        Remove-Variable '_paramHelper'
        return $dynamicParameters
    }

    begin
    {
        function Cleanup {
            Disconnect-PSAdminSQLite -Database $Database
        }
        $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
    }

    process
    {
        $Keys = $Script:PSAdminMachineSchema.DB.Table.KEY | ForEach-Object { $_ }
        $HasKey = foreach ($Param in $PSBoundParameters.GetEnumerator()) {
            if ($Keys -contains $Param.Key)
            {
                $true
                break
            }
        }

        if (!$HasKey)
        {
            Cleanup
            Throw "You must specify a valid Searchable Key Example:'$Keys'"
        }

        $DBQuery = @{
            Database        = $Database
            Keys            = $Script:PSAdminMachineSchema.DB.Table.KEY | ForEach-Object { $_ }
            Table           = $Script:PSAdminMachineSchema.DB.Table.Name
            InputObject     = [PSCustomObject]@{}
        }

        foreach ($Param in $PSBoundParameters.GetEnumerator())
        {
            Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $Param.Value
        }

        Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name "Updated" -Value ([DateTime]::UtcNow) -Force

        $Result = Set-PSAdminSQliteObject @DBQuery
        if ($Result -eq -1)
        {
            Cleanup
            Throw "Unable to update item"
        }

    }

    end
    {
        Cleanup
    }

}

function Open-PSAdmin
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ return Test-Path -Path $_ -PathType Leaf })]
        [System.String]$Path
    )

    begin
    {

        Write-Debug "Begin Open-PSAdmin"

    }

    process
    {
        Write-Debug "Loading XML File"
        $Script:PSAdminConfig = [XML](Get-Content $Path)

        Write-Debug "Storing DB Connection String"
        $Script:PSAdminDBConfig = @{}
        $Script:PSAdminDBConfig["Path"] = Get-Item -Path $Path | ForEach-Object Directory
        $Script:PSAdminConfig.CONFIG.Database.ChildNodes | ForEach-Object { $Script:PSAdminDBConfig[$_.Name] = $_.'#Text' }

        . {
		#---------------------------------------------------------[ONLOAD\KeyVault               ]--------------------------------------------------------
		$Database = Connect-PSAdminSQlite @Script:PSAdminDBConfig
		
		$KeyVaultSchema = [PSCustomObject]@{
		    Id                              = [String]""
		    VaultName                       = [String]""
		    Location                        = [String]""
		    VaultURI                        = [String]""
		    SKU                             = [String]""
		    SoftDeleteEnabled               = [String]""
		    Tags                            = [String]""
		    Thumbprint                      = [String]""
		    VaultKey                        = [char[]]""
		    ResourceGroup                   = [String]""
		    ResourceID                      = [String]""
		
		}
		
		$null = New-PSAdminSQLiteTable -Database $Database -Table "PSAdminKeyVault" -PSCustomObject $KeyVaultSchema
		
		Disconnect-PSAdminSQLite -Database $Database
	}
	. {
		#---------------------------------------------------------[ONLOAD\KeyVaultCertificate    ]--------------------------------------------------------
		$Database = Connect-PSAdminSQlite @Script:PSAdminDBConfig
		
		$KeyVaultCertificate = [PSCustomObject]@{
		    Certificate             = [Char[]]""
		    KeyId                   = [String]""
		    SecretId                = [String]""
		    Thumbprint              = [String]""
		    RecoveryLevel           = [String]""
		    ScheduledPurgeDate      = [String]""
		    DeletedDate             = [String]""
		    Enabled                 = [String]""
		    Expires                 = [String]""
		    NotBefore               = [String]""
		    Created                 = [String]""
		    Updated                 = [String]""
		    Tags                    = [String]""
		    VaultName               = [String]""
		    Name                    = [String]""
		    Version                 = [String]""
		    Id                      = [String]""
		}
		
		$Null = New-PSAdminSQLiteTable -Database $Database -Table "PSAdminKeyVaultCertificate" -PSCustomObject $KeyVaultCertificate
		
		Disconnect-PSAdminSQLite -Database $Database
	}
	. {
		#---------------------------------------------------------[ONLOAD\KeyVaultSecret         ]--------------------------------------------------------
		$Database = Connect-PSAdminSQlite @Script:PSAdminDBConfig
		
		$KeyVaultSecretSchema = [PSCustomObject]@{
		    VaultName   = [String]""
		    Name        = [String]""
		    Version     = [String]""
		    Id          = [String]""
		    Enabled     = [String]""
		    Expires     = [String]""
		    NotBefore   = [String]""
		    Created     = [String]""
		    Updated     = [String]""
		    ContentType = [String]""
		    Tags        = [String]""
		    SecretValue = [String]""
		}
		
		$Null = New-PSAdminSQLiteTable -Database $Database -Table "PSAdminKeyVaultSecret" -PSCustomObject $KeyVaultSecretSchema
		
		Disconnect-PSAdminSQLite -Database $Database
	}
	. {
		#---------------------------------------------------------[ONLOAD\Machine                ]--------------------------------------------------------
		$Script:PSAdminMachineSchema = [XML](Get-Content "$PSScriptRoot\DBSchema.xml")
		
		function Local:GenerateTableSchema
		{
		    [CmdletBinding()]
		    param(
		        [Parameter(Mandatory)]
				[System.Data.SQLite.SQLiteConnection]$Database,
		        [Parameter(Mandatory)]
		        [System.Xml.XmlDocument]$MachineSchema
		    )
		    
		    begin
		    {
		
		    }
		
		    process
		    {
		        #Create Table Object
		        $TableName = $MachineSchema.DB.Table.Name
		        $TableObj = [PSCustomObject]@{}
		        $MachineSchema.DB.Table.ITEM | ForEach-Object { Add-Member -InputObject $TableObj -MemberType NoteProperty -Name $_ -Value "" }
		        $null = New-PSAdminSQLiteTable -Database $Database -Table $TableName -PSCustomObject $TableObj
		    }
		
		    end
		    {
		
		    }
		}
		
		function Local:UpdateTableSchema
		{
		    [CmdletBinding()]
		    param(
				[Parameter(Mandatory)]
				[System.Data.SQLite.SQLiteConnection]$Database,
		        [Parameter(Mandatory)]
		        [System.Xml.XmlDocument]$MachineSchema
		    )
		    begin
		    {
		
		    }
		    process
		    {
		        #Write-Host "Placeholder for Powershell"
		        $Schema = Request-PSAdminSQLiteQuery -Database $Database -Query "PRAGMA table_info('PSAdminMachine')"
		        #$Schema | ft -a
		        #Write-Host "-------------"
		        #$MachineSchema.DB.Table.ITEM | ForEach-Object { $_ }
		    }
		    end
		    {
		
		    }
		}
		
		$Database = Connect-PSAdminSQlite @Script:PSAdminDBConfig
		
		Local:GenerateTableSchema -Database $Database -MachineSchema $Script:PSAdminMachineSchema
		Local:UpdateTableSchema -Database $Database -MachineSchema $Script:PSAdminMachineSchema
		
		Disconnect-PSAdminSQLite -Database $Database
	}
    }

    end
    {

        Write-Debug "End Open-PSAdmin"

    }
}

Export-ModuleMember -Function 'Open-PSAdmin','Get-PSAdminKeyVault','New-PSAdminKeyVault','Protect-PSAdminKeyVault','Remove-PSAdminKeyVault','Set-PSAdminKeyVault','Unprotect-PSAdminKeyVault','Get-PSAdminKeyVaultCertificate','Import-PSAdminKeyVaultCertificate','Remove-PSAdminKeyVaultCertificate','Get-PSAdminKeyVaultSecret','New-PSAdminKeyVaultSecret','Remove-PSAdminKeyVaultSecret','Set-PSAdminKeyVaultSecret','Get-PSAdminMachine','New-PSAdminMachine','Remove-PSAdminMachine','Set-PSAdminMachine'
