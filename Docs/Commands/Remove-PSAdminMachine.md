﻿# Remove-PSAdminMachine
Module: PSAdmin

Removes PSAdminMachine and removes Specified Matching item.

``` powershell
Remove-PSAdminMachine
        [-Id <String>]
        -VaultName <String>
        -Name <String>
        [-Match]
        [-WhatIf]
        [-Confirm]
```

## Description
Removes PSAdminMachine and removes Specified Matching item.

## Examples
### Example 1:   
***

``` powershell
Remove-PSAdminMachine -VaultName "<VaultName>" -Name "<HostName>" 
```

### Example 2:   
***

``` powershell
Remove-PSAdminMachine -VaultName "<VaultName>" -Name "<HostName>" -Match
```

## Parameters

### \-Id

Specify identifier
```
Type:                       String  
Position:                   1  
Default Value:              *  
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-VaultName

Specify VaultName
```
Type:                       String  
Position:                   2  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Name

Specify Machine Name
```
Type:                       String  
Position:                   3  
Default Value:                
Accept pipeline input:      true (ByValue, ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Match

Specify Match Search Mode
```
Type:                       SwitchParameter  
Position:                   named  
Default Value:              False  
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-WhatIf

```
Type:                       SwitchParameter  
Position:                   named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-Confirm

```
Type:                       SwitchParameter  
Position:                   named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```