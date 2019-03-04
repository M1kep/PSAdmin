﻿# New-PSAdminMachine
Module: PSAdmin

Searches PSAdminMachine for an machine with Specified Matching Name.

``` powershell
New-PSAdminMachine
        -VaultName <String>
        -Name <String>
        [-Description <String>]
        [-LastOnline <DateTime>]
        [-AssetNumber <String>]
        [-SerialNumber <String>]
        [-DeviceSKU <String>]
        [-OSVersion <String>]
        [-Location <String>]
        [-Building <String>]
        [-Room <String>]
        [-Rack <String>]
        [-Slot <String>]
        [-VMHost <String>]
        [-MachineDefinition <String>]
        [-ProvisioningState <String>]
        [-DesiredVersion <String>]
        [-ActualVersion <String>]
        [-Domain <String>]
        [-Forest <String>]
        [-PublicFQDN <String>]
        [-LoadBalancer <String>]
        [-PublicIP <IPAddress>]
        [-LocalIP <IPAddress>]
        [-MACAddress <String>]
        [-Tags <String>]
        [-Notes <String>]
        [-Exact]
```

## Description
Searches PSAdminMachine for an machine with Specified Matching Name.

## Examples
### Example 1:   
***

``` powershell
New-PSAdminMachine -VaultName "<VaultName>" -Name "<HostName>"
```

### Example 2:   
***

``` powershell
New-PSAdminMachine -VaultName "<VaultName>" -Name "<HostName>" -<Parameter> "Value"
```

## Parameters

### \-VaultName

Specify VaultName
```
Type:                       String  
Position:                   1  
Default Value:                
Accept pipeline input:      true (ByValue, ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Name

Specify Name
```
Type:                       String  
Position:                   2  
Default Value:                
Accept pipeline input:      true (ByValue, ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Description

Specify Description
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-LastOnline

Specify LastOnline
```
Type:                       DateTime  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-AssetNumber

Specify AssetNumber
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-SerialNumber

Specify SerialNumber
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-DeviceSKU

Specify DeviceSKU
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-OSVersion

Specify OSVersion
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Location

Specify Location
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Building

Specify Building
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Room

Specify Room
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Rack

Specify Rack
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Slot

Specify Slot
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-VMHost

Specify VMHost
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-MachineDefinition

Specify MachineDefinition
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-ProvisioningState

Specify ProvisioningState
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-DesiredVersion

Specify DesiredVersion
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-ActualVersion

Specify ActualVersion
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Domain

Specify Domain
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Forest

Specify Forest
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-PublicFQDN

Specify PublicFQDN
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-LoadBalancer

Specify LoadBalancer
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-PublicIP

Specify PublicIP
```
Type:                       IPAddress  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-LocalIP

Specify LocalIP
```
Type:                       IPAddress  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-MACAddress

Specify MACAddress
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Tags

Specify Tags
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Notes

Specify Notes
```
Type:                       String  
Position:                   named  
Default Value:                
Accept pipeline input:      true (ByPropertyName)  
Accept wildcard characters: Unknown  
```
### \-Exact

Specify Search Mode
```
Type:                       SwitchParameter  
Position:                   named  
Default Value:              False  
Accept pipeline input:      false  
Accept wildcard characters: Unknown  
```