. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Resolve-DependencyPath {

    $Script:ModuleFilter = {$Module -in ('foo', '.\foo') -or ($Module.ModuleName -eq 'foo' -and $Module.ModuleVersion -eq '1.2.3')}
    $Script:PathFilter = {$Path -in ('bar.exe', '.\bar.exe', 'BarFolder', '.\BarFolder')}

    BeforeAll {
        Mock Resolve-ModulePath -ModuleName $Module -ParameterFilter $ModuleFilter {
            if ($Module.ModuleVersion -eq '1.2.3')
            {
                return 'C:\Program Files\WindowsPowerShell\Modules\foo\1.2.3'
            }
            return 'C:\Program Files\WindowsPowerShell\Modules\foo'
        }

        Mock Resolve-Path -ModuleName $Module -ParameterFilter $PathFilter {
            return @{Path = "C:\Windows\System32\$($Path -replace '^\.\\')"}
        }
    }

    Context Default {

        InModuleScope $Module {

            It "Finds modules" {

                $Output = 'foo' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Program Files\WindowsPowerShell\Modules\foo'
                $Output.BasePath | Should -Be 'C:\Program Files\WindowsPowerShell\Modules'

                $Output = '.\foo' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Program Files\WindowsPowerShell\Modules\foo'
                $Output.BasePath | Should -Be 'C:\Program Files\WindowsPowerShell\Modules'

                $Output = @{ModuleName = 'foo'; ModuleVersion = '1.2.3'} | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Program Files\WindowsPowerShell\Modules\foo\1.2.3'
                $Output.BasePath | Should -Be 'C:\Program Files\WindowsPowerShell\Modules'
            }

            It "Finds binaries" {

                Mock Test-Path -ParameterFilter {$PathType -eq 'Leaf'} {return $Path -notmatch 'Folder'}

                $Output = 'bar.exe' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Windows\System32\bar.exe'
                $Output.BasePath | Should -Be 'C:\Windows\System32'

                $Output = '.\bar.exe' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Windows\System32\bar.exe'
                $Output.BasePath | Should -Be 'C:\Windows\System32'

                $Output = 'BarFolder' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Windows\System32\BarFolder'
                $Output.BasePath | Should -Be 'C:\Windows\System32\BarFolder'

                $Output = '.\BarFolder' | Resolve-DependencyPath
                $Output.Path     | Should -Be 'C:\Windows\System32\BarFolder'
                $Output.BasePath | Should -Be 'C:\Windows\System32\BarFolder'
            }
        }
    }
}
