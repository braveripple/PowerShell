# アイテム名をクリップボードにコピーする
$result = ""
$first = $true
$Args | 
    Where-Object { Test-Path -LiteralPath $_ } | 
    Get-ChildItem | 
    Sort-Object -Property Name | 
    ForEach-Object { 
        if ($first) {
            $result += "ディレクトリ名:$($_.Directory.FullName)`n" 
            $first = $false
        }
        $result += "* $($_.Name)`n"
    }

Set-Clipboard $result
