# アイテムにタイムスタンプを付ける
$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | 
    ../Rename-ItemWithTimestamp.ps1 `
        -Format "yyyyMMddHHmmss" `
        -Prefix "_" `
        -OverWrite

