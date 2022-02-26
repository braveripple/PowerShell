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
    $Destination
)
begin {
    $timestamp = (Get-Date).ToString($Format)
    if ($null -ne $Destination) {
        if (!(Test-Path -LiteralPath $Destination -PathType Container)) {
            # コピー先が指定されている場合、コピー先のディレクトリが存在しない場合エラー
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
                if ($null -eq $Destination) {
                    $folder = $file.Directory.FullName
                } else {
                    $folder = $Destination
                }
                # コピーファイルパスの作成
                $new_file_path = [System.IO.Path]::Combine(
                    $folder, 
                    $file.BaseName + "_" + $timestamp + $file.Extension
                )
                Copy-Item -LiteralPath $_ $new_file_path -Recurse
            }
        }
    }
}