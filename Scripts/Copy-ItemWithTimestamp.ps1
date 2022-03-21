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
    [ValidateSet("CurrentTime", "WriteTime", "AccessTime", "CreationTime")]
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
            Write-Error "Access to the path '$Destination' is denied."
            exit 1
        }
    }
}
process {
    $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
    foreach ($p in $InputPath) {
        try {
            $param = @{ $PSCmdlet.ParameterSetName = $p }
            $targets = @(Convert-Path @param -ErrorAction Stop)
        }
        catch {
            Write-Error $_.Exception.Message -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") {
                return
            }
            $targets = @()
        }
        foreach ($target in $targets) {
            $file = Get-Item -LiteralPath $target
            # コピー先の設定
            if ($null -eq $PSBoundParameters.Destination) {
                $folder = Split-Path -Path $file -Parent
            }
            else {
                $folder = $Destination
            }
            # タイムスタンプの種類
            if ($TimestampType -eq "CurrentTime") {
                $timestamp = $currentTime
            }
            elseif ($TimestampType -eq "WriteTime") {
                $timestamp = $file.LastWriteTime.ToString($Format)
            }
            elseif ($TimestampType -eq "AccessTime") {
                $timestamp = $file.LastAccessTime.ToString($Format)
            }
            elseif ($TimestampType -eq "CreationTime") {
                $timestamp = $file.CreationTime.ToString($Format)
            }
            # ファイル名の既存のタイムスタンプの上書き
            if ($OverWrite) {
                $filename = (& "${PSScriptRoot}/Remove-Timestamp.ps1" $file.Name -Format $Format -Prefix $Prefix)
                $filebase = Split-Path -LeafBase $filename
            }
            else {
                $filebase = $file.BaseName
            }
            # コピーファイルパスの作成
            $newFilePath = [System.IO.Path]::Combine(
                $folder, 
                $filebase + $Prefix + $timestamp + $file.Extension
            )
            # ShouldProcessで表示する処理対象
            $targetVerbose = "Item: ${target} Destination: ${newFilePath}"
            # ShouldProcessで表示する操作
            $operation = "Copy {0} with Timestamp" -f $(if ($file.PSIsContainer) { "Directory" } else { "File" })
            if ($PSCmdlet.ShouldProcess($targetVerbose, $operation)) {
                Copy-Item -LiteralPath $target $newFilePath -Recurse
            }
        }
    }
}
