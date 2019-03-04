﻿# Get-PSAdminMachine
Module: PSAdmin

Searches PSAdminMachine for an machine with Specified Matching Name

``` powershell
Get-PSAdminMachine
        [-Id <String>]
        -VaultName <String>
        [-Name <String>]
        [-Tags <String[]>]
        [-Exact]
```

## Description
Searches PSAdminMachine for an machine with Specified Matching Name

## Examples
### Example 1:   
***



### Example 2:   
***



## Parameters

### \-Id

Specify Id
```
Type:                       String  
Position:                   named  
Default Value:              *  
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-VaultName

Specify VaultName
```
Type:                       String  
Position:                   1  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Name

Specify Machine Name
```
Type:                       String  
Position:                   2  
Default Value:              *  
Accept pipeline input:      true (ByValue, ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Tags

```
Type:                       String[]  
Position:                   named  
Default Value:              *  
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Exact

Specify Exact Search Mode
```
Type:                       SwitchParameter  
Position:                   named  
Default Value:              False  
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```