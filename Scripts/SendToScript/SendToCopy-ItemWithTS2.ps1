# タイムスタンプを付けてファイルを特定のディレクトリにコピーする
$backupDirectory = "$($Env:USERPROFILE)\Documents\Backup"
New-Item -Path $backupDirectory -ItemType Directory -Force

$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | 
../Copy-ItemWithTS.ps1 -Format "FileDateTime" -Destination $backupDirectory

