[CmdletBinding(
    SupportsShouldProcess,
    DefaultParameterSetName = 'Path'
)]
param (
    [SupportsWildCards()]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'Path',
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]$Path,

    [Alias('LP')]
    [Alias('PSPath')]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath',
        ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True)]
    [string[]]$LiteralPath,

    [Parameter(Mandatory = $False)]
    [switch]$NoCreate
)
process {
    $targets = @()
    if ($PSBoundParameters.ContainsKey('Path')) {
        Write-Debug "Path:${Path}"
        $Path | ForEach-Object {
            if (Test-Path -Path $_ -PathType Any) {
                Write-Debug "P:$(${_}) is exist"
                $targets += Convert-Path -Path $_
            } else {
                Write-Debug "P:$(${_}) is not exist"
                $parent = Split-Path -Path $_ -Parent
                $child = Split-Path -Path $_ -Leaf
                if (Test-Path -LiteralPath $parent -PathType Container) {
                    $targets += Join-Path -Path (Convert-Path $parent) -ChildPath $child
                } else {
                    $targets += Join-Path -Path (Get-Location) -ChildPath $child
                }
            }
        }
    }
    else {
        Write-Debug "LiteralPath:${LiteralPath}"
        $LiteralPath | ForEach-Object {
            if (Test-Path -LiteralPath $_ -PathType Any) {
                Write-Debug "LP:$(${_}) is exist."
                $targets += Convert-Path -LiteralPath $_
            } else {
                Write-Debug "LP:$(${_}) is not exist."
                $parent = Split-Path -Path $_ -Parent
                $child = Split-Path -Path $_ -Leaf
                if (Test-Path -LiteralPath $parent -PathType Container) {
                    $targets += Join-Path -Path (Convert-Path $parent) -ChildPath $child
                } else {
                    $targets += Join-Path -Path (Get-Location) -ChildPath $child
                }
            }
        }
    }
    $targets | Foreach-Object {
        if ($PSCmdlet.ShouldProcess($_, 'touch')) {
            If (Test-Path -LiteralPath $_ -PathType Any) {
                $date = Get-Date
                $file = (Get-Item -LiteralPath $_)
                $file.LastWriteTime = $date
                $file.LastAccessTime = $date
                $file
            } else {
                if($NoCreate) {
                } else {
                    New-Item -Path $_ -ItemType File
                }
            }
        }
    }
}
