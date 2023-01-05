# アイテム名をクリップボードにコピーする
$result = (Split-Path -LiteralPath $Args[0]) + "`n"
$result += ($Args | Get-Item | Where-Object { "* $($_.name)" } | Sort-Object) -join "`n"
$result += "`n"
Set-Clipboard $result
