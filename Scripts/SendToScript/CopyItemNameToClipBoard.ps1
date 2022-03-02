# アイテム名をクリップボードにコピーする
$result = ""
$first = $true
$Args | 
    Where-Object { Test-Path -LiteralPath $_ } | 
    ForEach-Object { Get-Item -LiteralPath $_ } | 
    Sort-Object -Property Name | 
    ForEach-Object {
        if ($first) {
            # アイテムがあるディレクトリ名を先頭に出力する
            $result += "$($_.Directory.FullName)`n" 
            $first = $false
        }
        $result += "* $($_.Name)`n"
    }

Set-Clipboard $result
