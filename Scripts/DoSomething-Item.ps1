# コマンドレットのサンプル
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
Begin {
    # リソースの準備はBegin句で行う。
    # リソースの準備に失敗した場合普通はプログラム続行不可なのでexitで終了する。
    Write-Verbose "Begin"

    function cleanUp() {
        Write-Output "*リソースの解放*"
        try {
            # if ($null -ne $excel) {
            #     $excel.Quit()
            #     $excel = $null
            #     [GC]::collect()
            # }
        }
        catch {
            Write-Error "リソースの開放中にエラーが発生しました"
        }

    Write-Output "*リソースの準備*"
    try {
        # $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        # $excel.DisplayAlerts = $false
    }
    catch {
        Write-Error "リソースの準備に失敗しました" -ErrorAction Continue
        cleanUp
        exit 255
    }

}
Process {
    Write-Verbose "Process"
    $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
    $targets = @()
    foreach ($p in $InputPath) {
        Write-Verbose "'$p'を絶対パスに変換"
        try {
            $param = @{ $PSCmdlet.ParameterSetName = $p }
            $convertPath = Convert-Path @param -ErrorAction Stop
            Write-Verbose "絶対パス：$convertPath"
            $targets += $convertPath
        }
        catch {
            Write-Error $_.Exception.Message -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") {
                # 呼び出し元の-ErrorActionがStopの場合、処理を打ち切る
                return
            }
        }
    }
    ################
    # メイン処理
    ################
    foreach ($target in $targets) {
        if ($PSCmdlet.ShouldProcess($target, 'something')) {
            try {
                Write-Output "'$target':何かの処理をする"
                # ファイル名が"hoge.txt"のとき意図的にエラーを起こす
                if ((Get-Item $target).Name -eq "hoge.txt") {
                    throw "'$target'の処理でエラーが発生した"
                }
                Write-Output "'$target':何かの処理をした"
            }
            catch {
                Write-Error $_.Exception.Message -ErrorAction Continue
                if ($ErrorActionPreference -eq "Stop") {
                    # 呼び出し元の-ErrorActionがStopの場合、処理を打ち切る
                    return
                }
            }
        }
    }
} 
End {
    Write-Verbose "End"
    cleanUp
}