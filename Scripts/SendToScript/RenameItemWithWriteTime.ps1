# ファイル名に更新日時を付与してリネーム
Get-Item -LiteralPath $Args | 
    Rename-Item -NewName { 
        $_.BaseName + "_" + $_.LastWriteTime.ToString("yyyyMMddHHmmss") + $_.Extension 
    }
