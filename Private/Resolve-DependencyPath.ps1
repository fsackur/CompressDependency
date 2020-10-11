function Resolve-DependencyPath
{
    <#
        .SYNOPSIS
        Given a module name, path or ModuleSpec, or a non-module path, gets the resolved path and
        base path for the dependency.

        .EXAMPLE
        'Pester' | Resolve-DependencyPath | fl

        Path     : C:\Program Files\WindowsPowerShell\Modules\Pester\5.0.2
        BasePath : C:\Program Files\WindowsPowerShell\Modules

        .EXAMPLE
        'C:\Sysinternals\PsExec.exe' | Resolve-DependencyPath | fl

        Path     : C:\Sysinternals\PsExec.exe
        BasePath : C:\Sysinternals

        .EXAMPLE
        @{ModuleName = 'Pester'; MaximumVersion = '4.99'} | Resolve-DependencyPath | fl

        Path     : C:\Program Files\WindowsPowerShell\Modules\Pester\4.10.1
        BasePath : C:\Program Files\WindowsPowerShell\Modules
    #>
    [CmdletBinding(DefaultParameterSetName = 'AsPSObject')]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Dependency
    )

    begin
    {
        $VersionPattern = '\d+\.\d+\.\d+(\.\d+)?'
        $VersionFolderPattern = [regex]::Escape([IO.Path]::DirectorySeparatorChar) + $VersionPattern + '$'
    }


    process
    {
        $NonModules = [Collections.ArrayList]::new()
        $ModuleBases = [Collections.ArrayList]::new()
        $Dependency | ForEach-Object {
            $ModuleBase = $_ | Resolve-ModulePath -ErrorAction SilentlyContinue
            $null = if ($ModuleBase)
            {
                $ModuleBases.Add($ModuleBase)
            }
            else
            {
                $Resolved = Resolve-Path $_
                if ($?)
                {
                    $NonModules.Add($Resolved.Path)
                }
            }
        }


        $ModuleBases | ForEach-Object {
            $BasePath = Split-Path ($_ -replace $VersionFolderPattern)
            [pscustomobject]@{
                Path     = $_
                BasePath = $BasePath
            }
        }

        $NonModules | ForEach-Object {
            if (Test-Path $_ -PathType Leaf)
            {
                $BasePath = Split-Path $_
            }
            else
            {
                $BasePath = $_
            }

            [pscustomobject]@{
                Path     = $_
                BasePath = $BasePath
            }
        }
    }
}