function Resolve-ModulePath
{
    <#
        .SYNOPSIS
        Find the paths of Powershell modules.

        .DESCRIPTION
        Accepts a search path, a module name, or a ModuleSpecification object. A ModuleSpecification
        can be provided as a hashtable with the following keys being valid:

        - ModuleName
        - ModuleVersion
        - RequiredVersion
        - MaximumVersion
        - GUID

        If a matching module is already imported in the current session, it is returned. Otherwise,
        the normal module resolution order is followed, and the highest matching version is
        returned.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$Module
    )

    process
    {
        $Module | ForEach-Object {

            $Splat = @{
                FullyQualifiedName = $_
            }

            $ResolvedModule = $null
            try
            {
                $ResolvedModule = Get-Module @Splat -ErrorAction SilentlyContinue | Select-Object -First 1
            }
            catch {}

            if ($ResolvedModule)
            {
                Write-Verbose "Found $($ResolvedModule.Name) $($ResolvedModule.Version) from the current session."
                return $ResolvedModule.ModuleBase
            }


            $ResolvedModule = Get-Module @Splat -ListAvailable -Verbose:$false -ErrorAction SilentlyContinue |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if ($ResolvedModule)
            {
                Write-Verbose "Found $($ResolvedModule.Name) $($ResolvedModule.Version) at '$($ResolvedModule.ModuleBase)'."
                return $ResolvedModule.ModuleBase
            }


            Write-Error "'$_': not a Powershell module, or not in an importable location."
        }
    }
}
