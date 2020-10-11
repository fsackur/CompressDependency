function Write-ModuleFile
{
    <#
        .SYNOPSIS
        Write file content.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Bytes
    )

    process
    {
        $Container = Split-Path $Path
        if (-not (Test-Path $Container -PathType Container))
        {
            $null = New-Item $Container -ItemType Directory -Force
        }

        $RawBytes = [Convert]::FromBase64String($Bytes)
        [IO.File]::WriteAllBytes($Path, $RawBytes)
    }
}
