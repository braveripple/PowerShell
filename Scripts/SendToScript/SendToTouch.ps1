# SendToスクリプトの引数を高度な関数に渡すときは`Get-Item -LiteralPath`でファイル名解決する。
# そうするとパイプを使って１度に処理を渡すことができる。
$resolvePaths = foreach ($arg in $Args) {
    Get-Item -LiteralPath $arg
}
$resolvePaths | ../touch.ps1
