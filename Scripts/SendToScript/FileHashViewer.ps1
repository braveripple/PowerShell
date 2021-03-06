#Requires -Modules BurntToast

$TITLE = "đăăĄă€ă«ăźăăă·ă„ć€ăèȘżăčă"

# ăăĄă€ă«ăăă·ă„ăă°ăȘăăèĄšç€șăă
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
    Out-GridView -Title $TITLE -OutputMode Single

# ă°ăȘăăăźăăŒăżăéžæăăăăăŻăȘăăăăŒăă«ăłăăŒăă
if ($null -ne $select) {
    Set-Clipboard $select.Hash
    New-BurntToastNotification `
        -Text (
            "ăăă·ă„ć€ăăŻăȘăăăăŒăă«ăłăăŒăăŸăăă`n" +
            "$($select.Hash)`n" +
            "ă»ăăĄă€ă«ć:$($select.Name)`n" +
            "ă»ăąă«ăŽăȘășă :$($select.Algorithm)"
            ) `
        -Header (New-BTHeader -Id 1 -Title $TITLE)
}
