﻿# Protect-PSAdminKeyVault
Module: PSAdmin

Protects the KeyVault with a Certificate from the KeyVaultCertificate store.

``` powershell
Protect-PSAdminKeyVault
        -VaultName <String>
        -Thumbprint <String>
```

## Description
Protects the KeyVault with a Certificate from the KeyVaultCertificate store.

## Examples
### Example 1:   
***

``` powershell
Protect-PSAdminKeyVault -VaultName "<VaultName>" -Thumbprint "<GuidOfThumbprint>"
```

## Parameters

### \-VaultName

VaultName of Existing Vault
```
Type:                       String  
Position:                   1  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Thumbprint

Thumbprint of the KeyVaultCertificate you wish to protect the KeyVault VaultKey
```
Type:                       String  
Position:                   3  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
