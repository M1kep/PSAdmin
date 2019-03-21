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
        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName -Exact

        $EncKey = $KeyVault.VaultKey

        if ($KeyVault.Thumbprint)
        {
            $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $KeyVault.Thumbprint -Exact
            $x509 = $Certificate.Certificate
            $EncKey = $x509.PrivateKey.Decrypt($EncKey, $True)
        }
        
        return ($InputData | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -Key $EncKey)
        
    }

    end 
    {

    }
    
}