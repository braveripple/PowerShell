# ファイル名にタイムスタンプを付与してその場にコピー
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Get-Item -LiteralPath $Args | 
    ForEach-Object {
        $copyPath = $_.DirectoryName +"/"+ $_.BaseName + "_" + $timestamp + $_.Extension
        Copy-Item -LiteralPath $_ -Destination $copyPath
    }
