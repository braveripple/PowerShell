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

    [Parameter()]
    [switch]$NoCreate,

    [Parameter()]
    [string]$Reference,

    [Parameter()]
    [switch]$AccessTimeUpdate,

    [Alias('ModifyTimeUpdate')]
    [Parameter()]
    [switch]$WriteTimeUpdate,

    [Parameter()]
    [switch]$CreationTimeUpdate

)
begin {
    if ($Reference) {
        if (!(Test-Path -LiteralPath $Reference -PathType Any)) {
            throw "failed to get attlibutes of '${Reference}': No such file or directory"
        }
        $referenceFile = Get-Item -LiteralPath $Reference
        $lastWriteTime = $referenceFile.LastWriteTime
        $lastAccessTime = $referenceFile.LastAccessTime
        $creationTime = $referenceFile.CreationTime
    } else {
        $timestamp = Get-Date
        $lastWriteTime = $timestamp
        $lastAccessTime = $timestamp
        $creationTime = $timestamp
    }

    if ((!$AccessTimeUpdate) -and (!$WriteTimeUpdate) -and(!$CreationTimeUpdate)) {
        $AccessTimeUpdate = $True
        $WriteTimeUpdate = $True
    }

    if ($AccessTimeUpdate) {
        Write-Debug "AccessTimeUpdate:$($lastAccessTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }
    if ($WriteTimeUpdate) {
        Write-Debug "WriteTimeUpdate:$($lastWriteTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }
    if ($CreationTimeUpdate) {
        Write-Debug "CreationTimeUpdate:$($creationTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }

}
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
                $file = (Get-Item -LiteralPath $_)
                if ($AccessTimeUpdate) {
                    $file.LastAccessTime = $lastAccessTime
                }
                if ($WriteTimeUpdate) {
                    $file.LastWriteTime = $lastWriteTime
                }
                if ($CreationTimeUpdate) {
                    $file.CreationTime = $creationTime
                }
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
