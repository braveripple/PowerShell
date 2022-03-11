# タイムスタンプを付けてアイテムをその場にコピーする
$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | 
    ../Copy-ItemWithTimestamp.ps1 `
        -Format "yyyyMMddHHmmss" `
        -Prefix "_" `
        -OverWrite
