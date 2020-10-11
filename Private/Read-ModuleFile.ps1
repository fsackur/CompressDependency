function Read-ModuleFile
{
    <#
        .SYNOPSIS
        Get metadata and content of a file.

        .PARAMETER RelativeTo
        Provide a path within which to search for files. Has no effect on absolute paths.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,

        [Parameter()]
        [string]$RelativeTo = $PWD.Path
    )

    begin
    {
        $RelativeTo      = Resolve-Path $RelativeTo -ErrorAction Stop
        $RelativePattern = [regex]::Escape($RelativeTo) + [regex]::Escape([IO.Path]::DirectorySeparatorChar)
    }


    process
    {
        if (-not [IO.Path]::IsPathRooted($Path))
        {
            $FullPath = Join-Path $RelativeTo $Path
        }
        else
        {
            $FullPath = $Path
        }

        $Resolved = Resolve-Path $FullPath
        if (-not $?) {return}
        $FullPath = $Resolved.Path


        $Output = 1 | Select-Object (
            'Path',
            'Bytes'
        )

        $Bytes = [IO.File]::ReadAllBytes($FullPath)

        $Output.Path  = $Path
        $Output.Bytes = [Convert]::ToBase64String($Bytes)


        $Output
    }
}
