# ファイルの更新日時を更新する
$timestamp = Get-Date
Get-Item -LiteralPath $Args | 
    ForEach-Object {
        $_.LastAccessTime = $timestamp
        $_.LastWriteTime = $timestamp
    }

