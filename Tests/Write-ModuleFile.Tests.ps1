. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Write-ModuleFile {

    $Script:TestDrive2 = $env:TEMP |
        Join-Path -ChildPath ($Module.Name + '.Test') |
        Join-Path -ChildPath (Get-Random -Minimum 10000000 -Maximum 99999999)

    $Script:ModulePath = Join-Path $TestDrive2 ModulePath
    $null = New-Item $ModulePath -ItemType Directory

    $Script:TestDataFolder = Join-Path $PSScriptRoot Data
    $TestDataFile = $TestDataFolder |
        Join-Path -ChildPath OutputPath |
        Join-Path -ChildPath Compressed.ps1

    $Script:TestData = . $TestDataFile
    $TestData | ForEach-Object {
        $_.Path = $_.Path -replace [regex]::Escape($TestDataFolder), $TestDrive2
    }



    Context Default {

        $TestData | Write-ModuleFile

        It "Copies all files" {

            $ExpectedFiles = Get-ChildItem (Join-Path $TestDataFolder ModulePath) -Name -Recurse
            $WrittenFiles  = Get-ChildItem $ModulePath -Name -Recurse
            Compare-Object $ExpectedFiles $WrittenFiles | Should -BeNullOrEmpty
        }
    }


    AfterAll {
        Pop-Location
        Remove-Item $Script:TestDrive2 -Recurse -Force
    }
}
