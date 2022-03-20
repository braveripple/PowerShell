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
    [ValidateSet("CurrentTime", "WriteTime", "AccessTime", "CreationTime")]
    [string]
    $TimestampType = "CurrentTime",

    [Parameter(Mandatory = $False)]
    [switch]
    $OverWrite
)
begin {
    $currentTime = (Get-Date).ToString($Format)
}
process {
    $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
    foreach ($p in $InputPath) {
        $targets = @()
        try {
            if ($PSBoundParameters.ContainsKey('Path')) {
                $targets = Convert-Path -Path $p -ErrorAction Stop
            }
            else {
                $targets = Convert-Path -LiteralPath $p -ErrorAction Stop
            }
        }
        catch {
            Write-Error $_.Exception.Message -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") {
                return
            }
        }
        foreach ($target in $targets) {
            $file = Get-Item -LiteralPath $target
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
            $operation = "Rename {0} with Timestamp" -f $(if ($file.PSIsContainer) { "Directory" } else { "File" })
            if ($PSCmdlet.ShouldProcess($targetVerbose, $operation)) {
                Rename-Item -LiteralPath $target -NewName $newFilePath
            }
        }
    }
}
