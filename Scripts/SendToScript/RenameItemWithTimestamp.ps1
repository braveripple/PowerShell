# ファイル名にタイムスタンプを付与してリネーム
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Get-Item -LiteralPath $Args | 
    Rename-Item -NewName { 
        $_.BaseName + "_" + $timestamp + $_.Extension
    }
