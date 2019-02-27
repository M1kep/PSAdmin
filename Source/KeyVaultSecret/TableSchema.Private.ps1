class PSAdminKeyVaultSecret
{
    [System.String]         $VaultName
    [System.String]         $Name
    [System.String]         $Version
    [System.String]         $Id
    [System.String]         $Enabled
    [Nullable[Datetime]]    $Expires
    [Nullable[Datetime]]    $NotBefore
    [Nullable[Datetime]]    $Created
    [Nullable[Datetime]]    $Updated
    [System.String]         $ContentType
    [System.String[]]       $Tags
    [PSObject]              $SecretValue
}

$Script:KeyVaultSecretConfig = @{
    TableName           = "PSAdminKeyVaultSecret"
    TableKeys           = @("VaultName", "Name", "Id", "Tags")
    TableSchema         = [PSAdminKeyVaultSecret]@{}
}