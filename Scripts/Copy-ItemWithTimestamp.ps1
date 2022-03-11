[CmdletBinding(
    SupportsShouldProcess = $True,
    DefaultParameterSetName = 'Path'
)]
param (
    [SupportsWildCards()]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'Path',
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]
    $Path,

    [Alias('LP')]
    [Alias('PSPath')]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath',
        ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True)]
    [string[]]
    $LiteralPath,

    [Parameter(Mandatory = $False)]
    [string]
    $Format = "yyyyMMddHHmmss",

    [Parameter(Mandatory = $False)]
    [string]
    $Prefix = "_",

    [Parameter(Mandatory = $False)]
    [string]
    $Destination = $null,

    [Parameter(Mandatory = $False)]
    [ValidateSet("CurrentTime","WriteTime","AccessTime","CreationTime")]
    [string]
    $TimestampType = "CurrentTime",

    [Parameter(Mandatory = $False)]
    [switch]
    $OverWrite
)
begin {
    $currentTime = (Get-Date).ToString($Format)
    if ($null -ne $PSBoundParameters.Destination) {
        if (!(Test-Path -LiteralPath $Destination -PathType Container)) {
            # コピー先が指定されている場合、コピー先のディレクトリが存在しない場合エラー
            throw "Destination Path '${Destination}' is not exists."
        }
    }
}
process {
    if ($PSBoundParameters.ContainsKey('Path')) {
        $targets = Convert-Path -Path $Path
    }
    else {
        $targets = Convert-Path -LiteralPath $LiteralPath
    }
    $targets | Foreach-Object {
        if ($PSCmdlet.ShouldProcess($_)) {
            If (Test-Path -LiteralPath $_ -PathType Any) {
                $file = Get-Item -LiteralPath $_
                # コピー先の設定
                if ($null -eq $PSBoundParameters.Destination) {
                    $folder = Split-Path -Path $file -Parent
                } else {
                    $folder = $Destination
                }
                # タイムスタンプの種類
                if ($TimestampType -eq "CurrentTime") {
                    $timestamp = $currentTime
                } elseif ($TimestampType -eq "WriteTime") {
                    $timestamp = $file.LastWriteTime.ToString($Format)
                } elseif ($TimestampType -eq "AccessTime") {
                    $timestamp = $file.LastAccessTime.ToString($Format)
                } elseif ($TimestampType -eq "CreationTime") {
                    $timestamp = $file.CreationTime.ToString($Format)
                }
                if ($OverWrite) {
                    $filename = (& "${PSScriptRoot}/Remove-Timestamp.ps1" $file.Name -Format $Format -Prefix $Prefix)
                    $filebase = Split-Path -LeafBase $filename
                } else {
                    $filebase = $file.BaseName
                }
                # コピーファイルパスの作成
                $new_file_path = [System.IO.Path]::Combine(
                    $folder, 
                    $filebase + $Prefix + $timestamp + $file.Extension
                )
                Copy-Item -LiteralPath $_ $new_file_path -Recurse
            }
        }
    }
}
