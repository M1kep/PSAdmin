﻿# New-PSAdminKeyVaultSecret
Module: PSAdmin

Creates a new Secret to place in the Vault

``` powershell
New-PSAdminKeyVaultSecret
        -VaultName <String>
        -Name <String>
        [-Version <String>]
        [-Enabled <String>]
        [-Expires <Nullable`1>]
        [-NotBefore <Nullable`1>]
        [-ContentType <String>]
        [-Tags <String[]>]
        [-SecretValue <PSObject>]
```

## Description
Creates a new Secret to place in the Vault

## Examples
### Example 1:   
***

``` powershell
New-PSAdminKeyVaultSecret -VaultName "<VaultName>" -Name "<NameOfSecret>" -Enabled True -ContentType txt -SecretValue "My Secret Value"
```

## Parameters

### \-VaultName

Unique Name for KeyVault
```
Type:                       String  
Position:                   1  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Name

Unique Name for Secret
```
Type:                       String  
Position:                   2  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Version

Version for Secret
```
Type:                       String  
Position:                   3  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Enabled

Specify if Secret is enabled
```
Type:                       String  
Position:                   4  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Expires

Specify when Secret is expired
```
Type:                       Nullable`1  
Position:                   5  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-NotBefore

Specify when Secret should take effect.
```
Type:                       Nullable`1  
Position:                   6  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-ContentType

Specify ContentType Text or Blob
```
Type:                       String  
Position:                   7  
Default Value:              txt  
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Tags

Unique Tag Identifiers
```
Type:                       String[]  
Position:                   8  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-SecretValue

Secret Value to lock away in the KeyVault
```
Type:                       PSObject  
Position:                   9  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
