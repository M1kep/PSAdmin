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