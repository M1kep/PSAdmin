﻿# New-PSAdminKeyVault
Module: PSAdmin

Creates a new KeyVault with the specified Unique Name

``` powershell
New-PSAdminKeyVault
        -VaultName <String>
        [-Location <String>]
        [-VaultURI <String>]
        [-SoftDeleteEnabled <String>]
        [-Tags <String[]>]
```

## Description
Creates a new KeyVault with the specified Unique Name

## Examples
### Example 1:   
***

``` powershell
New-PSAdminKeyVault -VaultName "MyVaultName" -Location "Office"
```

## Parameters

### \-VaultName

A Unique Name
```
Type:                       String  
Position:                   1  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-Location

Specify a Location
```
Type:                       String  
Position:                   2  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-VaultURI

Specify a URI for Reference
```
Type:                       String  
Position:                   3  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-SoftDeleteEnabled

Specify Soft Delete Enabled (Note: This feature is not enabled)
```
Type:                       String  
Position:                   4  
Default Value:              True  
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-Tags

Specify a Tag or Multiple Tags
```
Type:                       String[]  
Position:                   5  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
