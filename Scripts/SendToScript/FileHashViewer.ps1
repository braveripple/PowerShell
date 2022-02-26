#Requires -Modules BurntToast

# ファイルハッシュをグリッド表示する
$select = $Args | 
    Where-Object {
        Test-Path -LiteralPath $_ -PathType Leaf
    } |
    ForEach-Object {
        Get-FileHash -LiteralPath $_ -Algorithm SHA256
        Get-FileHash -LiteralPath $_ -Algorithm MD5
        Get-FileHash -LiteralPath $_ -Algorithm SHA1
    } |
    Select-Object -Property @{Name="Name";Expression={[System.IO.Path]::GetFileName($_.Path)}}, Algorithm, Hash, Path | 
    Out-GridView -Title "🔍ファイルのハッシュ値を調べる" -OutputMode Single

# グリッドのデータが選択されたらクリップボードにコピーする
if ($null -ne $select) {
    Set-Clipboard $select.Hash
    New-BurntToastNotification `
        -Text (
            "ハッシュ値をクリップボードにコピーしました。`n" +
            "$($select.Hash)`n" +
            "・ファイル名:$($select.Name)`n" +
            "・アルゴリズム:$($select.Algorithm)"
            ) `
        -Header (New-BTHeader -Id 1 -Title $TITLE)
}
