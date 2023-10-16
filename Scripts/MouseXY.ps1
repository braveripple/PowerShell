Add-Type -AssemblyName System.Windows.Forms

# 画面サイズの横幅から表示桁数を取得
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$screenWidthDigit = $screen.Width.ToString().Length

Clear-Host;
while ($true) {
    # ちらつきを最低限に抑えるために、表示桁数で桁揃えする
    $x=[System.Windows.Forms.Cursor]::Position.X.ToString().PadLeft($screenWidthDigit);
    $y=[System.Windows.Forms.Cursor]::Position.Y.ToString().PadLeft($screenWidthDigit);
@"
Ctrl+Cで終了
{X=$x,Y=$y} 
"@
    [System.Console]::SetCursorPosition(0, 0);
    Start-Sleep 0.01
}

