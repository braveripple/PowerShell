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
    [ValidateSet("CurrentTime","WriteTime","AccessTime","CreationTime")]
    [string]
    $TimestampType = "CurrentTime"
)
begin {
    $currentTime = (Get-Date).ToString($Format)
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
                # コピーファイルパスの作成
                $new_file_path = [System.IO.Path]::Combine(
                    $file.Directory.FullName, 
                    $file.BaseName + "_" + $timestamp + $file.Extension
                )
                Rename-Item -LiteralPath $_ -NewName $new_file_path
            }
        }
    }
}
