# ファイル名に更新日時を付与してその場にコピー
Get-Item -LiteralPath $Args | 
    ForEach-Object {
        $copyPath = $_.DirectoryName + "/" + $_.BaseName + "_" + $_.LastWriteTime.ToString("yyyyMMddHHmmss") + $_.Extension
        Copy-Item -LiteralPath $_ -Destination $copyPath -WhatIf
    }
