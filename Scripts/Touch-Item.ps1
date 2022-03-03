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
    [string[]]$LiteralPath
)
process {
    $targets = @()
    if ($PSBoundParameters.ContainsKey('Path')) {
        #Write-Output "Path:${Path}"
        $Path | ForEach-Object {
            if (Test-Path -Path $_ -PathType Any) {
                #Write-Output "P:$(${_}) is exist"
                $targets += Convert-Path -Path $_
            } else {
                #Write-Output "P:$(${_}) is not exist"
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
        #Write-Output "LiteralPath:${LiteralPath}"
        $LiteralPath | ForEach-Object {
            if (Test-Path -LiteralPath $_ -PathType Any) {
                #Write-Output "LP:$(${_}) is exist."
                $targets += Convert-Path -LiteralPath $_
            } else {
                #Write-Output "LP:$(${_}) is not exist."
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
                (Get-Item -LiteralPath $_).LastWriteTime = Get-Date
                Get-Item -LiteralPath $_
            } else {
                New-Item -Path $_ -ItemType File
            }
        }
    }
}
