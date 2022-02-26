#Requires -Modules BurntToast
# 要 nkf32.exe

# ファイルの文字コードをグリッド表示する
$select = $Args | 
    Where-Object {
        Test-Path -LiteralPath $_ -PathType Leaf
    } |
    ForEach-Object {
        $encoding = nkf32.exe -g $_
        if ($encoding -eq "BINARY") {
            $filetype = "バイナリ"
            $encoding = "-"
        } else {
            $filetype = "テキスト"
        }
        [PSCustomObject]@{
            "ファイル名" = (Get-Item -LiteralPath $_).Name
            "ファイル形式" = $filetype
            "文字コード" = $encoding
            "パス" = $_
        }
    } | 
    Out-GridView -Title "🔍ファイルの文字コードを調べる" -OutputMode Multiple

$select
