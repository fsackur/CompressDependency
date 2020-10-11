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

    process
    {
        $Output = 1 | Select-Object (
            'Path',
            'Bytes'
        )

        if (-not (Test-Path $Path -PathType Leaf))
        {
            Write-Error "Path '$Path' is not a file."
            return
        }

        if (-not [IO.Path]::IsPathRooted($Path))
        {
            $Path = (Resolve-Path (Join-Path $PWD $Path)).Path
        }


        $Bytes = [IO.File]::ReadAllBytes($Path)

        $Output.Path  = $Path
        $Output.Bytes = [Convert]::ToBase64String($Bytes)


        $Output
    }
}
