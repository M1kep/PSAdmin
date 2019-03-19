function Protect-PSAdminKeyVault
{
        <#
        .SYNOPSIS
            Protects the KeyVault with a Certificate from the KeyVaultCertificate store.

        .DESCRIPTION
            Protects the KeyVault with a Certificate from the KeyVaultCertificate store.
        
        .PARAMETER VaultName
            VaultName of Existing Vault
        
        .PARAMETER Thumbprint
            Thumbprint of the KeyVaultCertificate you wish to protect the KeyVault VaultKey

        .EXAMPLE

            ``` powershell
            Protect-PSAdminKeyVault -VaultName "<VaultName>" -Thumbprint "<GuidOfThumbprint>"
            ```

        .INPUTS
            None. Protect-PSAdminKeyVault does not take Pipeline Input.

        .OUTPUTS
            None. If Successful

        .NOTES

        .LINK

    #>
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

        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName -Exact
        $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $Thumbprint -Exact

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
        $x509 = $Certificate.Certificate

        if ((!$x509.HasPrivateKey) -or (!$x509.PrivateKey)) {
            throw New-PSAdminException -ErrorID KeyVaultCertificateExceptionPrivateKey
        }

        try {
            
            $Database = Connect-PSAdminSQLite @Script:PSAdminDBConfig
            $DBQuery = @{
                Database        = $Database
                Keys            = $Script:KeyVaultConfig.TableKeys
                Table           = $Script:KeyVaultConfig.TableName
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
    }

    end
    {

    }
}