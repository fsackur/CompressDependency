function Read-ModuleFile
{
    <#
        .SYNOPSIS
        Get metadata and content of a file.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )

    begin
    {
        $OutputProperties = (
            @{Name = 'Path'; Expression = {
                if ([IO.Path]::IsPathRooted($Path))
                {
                    $Path
                }
                else
                {
                    Join-Path $PWD $Path
                }
            }},
            'Bytes'
        )
    }

    process
    {
        if (-not (Test-Path $Path -PathType Leaf))
        {
            Write-Error "Path '$Path' is not a file."
            return
        }

        $Output = 1 | Select-Object $OutputProperties

        $Bytes = [IO.File]::ReadAllBytes($Output.Path)
        $Output.Bytes = [Convert]::ToBase64String($Bytes)

        $Output
    }
}
