﻿# Invoke-PSAdminCommand
Module: PSAdmin


Invoke-PSAdminCommand -VaultName <string> -ComputerName <string> -ScriptBlock <scriptblock> [-UsePublicIP] [-ArgumentList <Object[]>] [-HideComputerName] [<CommonParameters>]

Invoke-PSAdminCommand -VaultName <string> -ComputerName <string> -Command <string> [-UsePublicIP] [-ArgumentList <Object[]>] [-HideComputerName] [<CommonParameters>]


``` powershell
Invoke-PSAdminCommand
        [-ArgumentList <Object[]>]
        -Command <string>
        -ComputerName <string>
        [-HideComputerName]
        -ScriptBlock <scriptblock>
        [-UsePublicIP]
        -VaultName <string>
```

## Description


## Examples
## Parameters

### \-ArgumentList

```
Type:                       Object[]  
Position:                   Named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-Command

```
Type:                       string  
Position:                   Named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-ComputerName

```
Type:                       string  
Position:                   Named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-HideComputerName

```
Type:                       switch  
Position:                   Named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-ScriptBlock

```
Type:                       scriptblock  
Position:                   Named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-UsePublicIP

```
Type:                       switch  
Position:                   Named  
Default Value:                
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```
### \-VaultName

```
Type:                       string  
Position:                   Named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
