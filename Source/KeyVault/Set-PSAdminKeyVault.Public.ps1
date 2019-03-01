function Set-PSAdminKeyVault
{
        <#
        .SYNOPSIS
            Sets KeyVault with Specified Values

        .DESCRIPTION
            Sets KeyVault with Specified Values
        
        .PARAMETER VaultName
            A Unique Name (Note this is Wildcard Searchable)
        
        .PARAMETER Location
            Specify a Location

        .PARAMETER VaultURI
            Specify a URI for Reference

        .PARAMETER SoftDeleteEnabled
            Specify Soft Delete Enabled (Note: This feature is not enabled)

        .PARAMETER Tags
            Specify a Tag or Multiple Tags

        .EXAMPLE

            ``` powershell
            Set-PSAdminKeyVault -VaultName "MyVaultName" -Location "Office"
            ```
        .INPUTS
            PSAdminKeyVault.PSAdmin.Module, or any specific object that contains Id, Name

        .OUTPUTS
            None.

        .NOTES

        .LINK

    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Id,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$VaultName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$VaultURI,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String]$SKU,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("True", "False")]
        [System.String]$SoftDeleteEnabled,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]]$Tags

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
        $DBQuery = @{
            Database        = $Database
            Keys            = ("VaultName", "Id")
            Table           = "PSAdminKeyVault"
            InputObject = [PSCustomObject]@{ }

        }

        foreach ($Param in $PSBoundParameters.GetEnumerator())
        {
            Add-Member -InputObject $DBQuery.InputObject -MemberType NoteProperty -Name $Param.Key -Value $Param.Value
        }

        $Result = Set-PSAdminSQliteObject @DBQuery
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