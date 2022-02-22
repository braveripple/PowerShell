# タイムスタンプを付けてファイルをコピーする
$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | 
../Copy-ItemWithTS.ps1 -Format "FileDateTime"
