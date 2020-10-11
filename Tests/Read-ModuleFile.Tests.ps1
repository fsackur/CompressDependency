. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Read-ModuleFile {

    $TestDrive = $env:TEMP |
        Join-Path -ChildPath ($Module.Name + '.Test') |
        Join-Path -ChildPath (Get-Random -Minimum 10000000 -Maximum 99999999)

    $Script:ModulePath = Join-Path $TestDrive ModulePath
    $null = New-Item $ModulePath -ItemType Directory

    $PSScriptRoot |
        Join-Path -ChildPath 'Data' |
        Join-Path -ChildPath 'ModulePath' |
        Get-ChildItem |
        Copy-Item -Destination $ModulePath -Recurse

    Push-Location $TestDrive


    Context Default {

        $Script:Output = 'ModulePath', 'ModulePath\Dep1\Dep1.psd1', '.\ModulePath\curl.exe' |
            Read-ModuleFile -ErrorVariable Script:ErrorOutput -ErrorAction SilentlyContinue

        It 'Errors on directories' {

            $ErrorOutput[0] | Should -Match "Path 'ModulePath' is not a file."
        }

        It "Doesn't error on anything else" {

            $ErrorOutput.Count | Should -Be 1
        }

        It "Resolves non-dotted path" {

            $Output[0].Path | Should -BeExactly "$ModulePath\Dep1\Dep1.psd1"
        }

        It "Resolves dotted path" {

            $Output[1].Path | Should -BeExactly "$ModulePath\curl.exe"
        }

        It "Reads .psd1 bytes" {

            $Bytes = $Output[0].Bytes
            $Bytes.Length | Should -BeExactly 240
            $Bytes.Substring(0, 10) | Should -BeExactly 'QHsNCiAgIC'
            $Bytes.Substring($Bytes.Length - 10) | Should -BeExactly 'AwJw0KfQ0K'
        }

        It "Reads .exe bytes" {

            $Bytes = $Output[1].Bytes
            $Bytes.Length | Should -BeExactly 561836
            $Bytes.Substring(0, 10) | Should -BeExactly 'TVqQAAMAAA'
            $Bytes.Substring($Bytes.Length - 10) | Should -BeExactly 'AAAAAAAAA='
        }
    }


    Pop-Location
    Remove-Item $TestDrive -Recurse -Force
}
