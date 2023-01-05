# コンソールに表示するだけ
Write-Host $Args -Separator "`n"
Write-Host ""
Get-Item -LiteralPath $Args
Write-Host ""
pause
