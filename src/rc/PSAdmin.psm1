if (-not (Test-Path -path "$PSScriptRoot\SQLite.Interop.dll"))
{
    #--------------------------------------------------
    #Fixes a bug where SQLite.Interop.dll is not being
    #resolved correctly from its NUGET library.
    #--------------------------------------------------

    $OSVersion = [Environment]::OSVersion
    $OSPlatform = Switch ($OSVersion.Platform)
    {
        "Unix" { "linux" }
        "Win32NT" { "win" }
    }
    $Architecture = Switch ([Environment]::Is64BitProcess)
    {
        $true { "x64" }
        $false { "x86" }
    }

    $SQLiteInterop = "$PSScriptRoot\runtimes\${OSPlatform}-${Architecture}\native\netstandard2.0\SQLite.Interop.dll"
    Write-Warning "Fixes known issue where SQLite.Core not loading correctly by moving files:"
    Write-Warning $SQLiteInterop

    Copy-Item -path "$SQLiteInterop" $PSScriptRoot
}



$Files = Get-ChildItem "$PSScriptRoot/PowerShell.Functions/*.Public.ps1" -recurse

$PubliCFunctions = new-object System.Collections.Generic.List[String]
foreach ($File in $Files) {

    . $File

    if ($File.BaseName -match "Public") {
        $str = $File.BaseName.Replace(".Public", "")
        $PublicFunctions.Add($str)
    }

}

$PSEdition = $PSVersionTable.PSEdition
Import-Module "$PSScriptRoot/${PSEdition}.dll"