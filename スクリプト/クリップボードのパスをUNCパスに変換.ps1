Add-Type -AssemblyName System.Web

# ネットワークドライブ一覧を取得
$networkDrives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like "\\*\*" }

Get-ClipBoard | ForEach-Object {
    # Excelの「リンクをクリップボードでコピーする」のファイルパスは"file:///"がついているので除去する
    $p = $_ -replace "file:///?",""
    # Excelの「リンクをクリップボードでコピーする」のファイルパスはURLエンコードされている場合があるのでデコードする
    $p = [System.Web.HttpUtility]::UrlDecode($p)

    # 無視する。
    # ネットワークドライブパスの手前の空白や囲み文字を許容する
    if ($p -match "[""''\t\s]?([ABD-Z]:\\)") {
        $driveRoot = $Matches[1]
        $driveLetter = $driveRoot.Substring(0, 1)
        $networkDirectoryPath = $networkDrives | ? { $_.Name -eq $driveLetter } | select -ExpandProperty DisplayRoot
        $p.Replace($driveRoot, $networkDirectoryPath + "\")
    } else {
        $p
    }
} | Set-Clipboard

# トースト通知をWindows PowerShellにやってもらう
powershell -Command {
	$bodyText = $args[0]
	$ToastText01 = [Windows.UI.Notifications.ToastTemplateType, Windows.UI.Notifications, ContentType = WindowsRuntime]::ToastText01
	$TemplateContent = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::GetTemplateContent($ToastText01)
	$TemplateContent.SelectSingleNode('//text[@id="1"]').InnerText = $bodyText
	$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
	[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($TemplateContent)
} -args "UNCパスに変換しました。"
