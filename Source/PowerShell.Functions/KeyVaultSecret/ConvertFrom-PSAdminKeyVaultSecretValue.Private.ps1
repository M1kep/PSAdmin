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
        
        $KeyVault = Get-PSAdminKeyVault -VaultName $VaultName -Exact

        $EncKey = $KeyVault.VaultKey

        if ($KeyVault.Thumbprint)
        {

            $Certificate = Get-PSAdminKeyVaultCertificate -VaultName $VaultName -Thumbprint $KeyVault.Thumbprint -Exact
            $x509 = $Certificate.Certificate
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