. (Join-Path $PSScriptRoot Test.Setup.ps1)

Describe "Resolve-ModulePath" {

    Context Default {

        BeforeAll {
            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and -not $ListAvailable} {
                return @{ModuleBase = 'foo'}
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'InstalledModule' -and -not $ListAvailable} {
                return
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and $ListAvailable} {
                throw "Should have pulled from the session!"
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'InstalledModule' -and $ListAvailable} {
                return @{ModuleBase = 'foo'}
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq '.\InstalledModule'} {
                throw "Get-Module doesn't like getting paths without ListAvailable"
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq '.\InstalledModule' -and $ListAvailable} {
                return @{ModuleBase = 'foo'}
            }

            Mock Get-Module -ModuleName $Module {
                return
            }
        }


        InModuleScope $Module {

            It "Finds imported modules by name or ModuleSpec" {

                "ImportedModule" |
                    Resolve-ModulePath | Should -BeExactly 'foo'

                @{ModuleName = "ImportedModule"; ModuleVersion = "1.2.3"} |
                    Resolve-ModulePath | Should -BeExactly 'foo'
            }

            It "Does not search for imported modules" {

                "ImportedModule" | Resolve-ModulePath

                Should -Invoke Get-Module -Exactly -Times 0 -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and $ListAvailable}
            }

            It "Finds installed modules by name or ModuleSpec" {

                "InstalledModule" |
                    Resolve-ModulePath | Should -BeExactly 'foo'

                @{ModuleName = "InstalledModule"; ModuleVersion = "1.2.3"} |
                    Resolve-ModulePath | Should -BeExactly 'foo'
            }

            It "Finds installed modules by path" {

                ".\InstalledModule" |
                    Resolve-ModulePath | Should -BeExactly 'foo'
            }
        }
    }
}
