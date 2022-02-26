# タイムスタンプを付けてファイルを特定のディレクトリにコピーする
$backupDirectory = "${HOME}/Documents/Backup"
New-Item -Path $backupDirectory -ItemType Directory -Force

$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | 
../Copy-ItemWithTimestamp.ps1 -Format "yyyyMMddHHmmss" -Destination $backupDirectory
