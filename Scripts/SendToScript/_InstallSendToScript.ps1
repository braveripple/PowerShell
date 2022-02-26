$PowerShellPath = "C:\Program Files\PowerShell\7\pwsh.exe"
enum WindowStyle {
    Normal = 1
    Minimized = 7
    Maximized = 3
    Hidden = 7
}
function createSendToScriptShortcut {
    param (
        [string]$scriptPath,
        [string]$name,
        [WindowStyle]$windowStyle,
        [WindowStyle]$powershellWindowStyle = $windowStyle,
        [string]$iconLocation = $PowerShellPath
    )
    # PowerShellのパス
    
    # SendToディレクトリのパス
    $sendToDirectoryPath = Join-Path -Path ${env:APPDATA} -ChildPath "\Microsoft\Windows\SendTo"
    # SendToディレクトリに置くショートカットのパス
    $sendToShortcutPath = Join-Path -Path $sendToDirectoryPath -ChildPath "${name}.lnk"
    # PowerShellの引数
    $sendToShortcutArguments = "-WindowStyle ${powershellWindowStyle} -NoProfile -File ${scriptPath}"

    # ショートカットの作成
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($sendToShortcutPath)
    $shortcut.TargetPath = $PowerShellPath
    $shortcut.Arguments = $sendToShortcutArguments
    $shortcut.IconLocation = $iconLocation
    $shortcut.WorkingDirectory = (Split-Path -Parent $scriptPath )
    $shortcut.WindowStyle = $windowStyle.GetHashCode()

    $shortcut.Save()
}

$iconMap = @{
    "📷"="%SystemRoot%\System32\shell32.dll,117";
    "🔍"="%SystemRoot%\System32\imageres.dll,168";
    "🌟"="%SystemRoot%\System32\shell32.dll,208";
    "🕒"="%SystemRoot%\System32\shell32.dll,20";
    "📋"="%SystemRoot%\System32\shell32.dll,260";
    "💼"="%SystemRoot%\System32\shell32.dll,20";
    "💾"="%SystemRoot%\System32\shell32.dll,258";
    "PowerShell"=$PowerShellPath
}

$scriptInfo = @(
    [PSCustomObject]@{
        Name="コンソールに表示"
        Path=".\DisplayConsole.ps1"
        Icon="PowerShell"
        WindowStyle=[WindowStyle]::Normal
        PowerShellWindowStyle=[WindowStyle]::Normal
    },
    [PSCustomObject]@{
        Name="アイテム名をクリップボードにコピー"
        Path=".\CopyItemNameToClipBoard.ps1"
        Icon="📋"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Hidden
    },
    [PSCustomObject]@{
        Name="更新日時を更新"
        Path=".\TouchItem.ps1"
        Icon="🌟"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Hidden
    },
    [PSCustomObject]@{
        Name="タイムスタンプを付与してコピー"
        Path=".\CopyItemWithTimestamp.ps1"
        Icon="🕒"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Hidden
    },
    [PSCustomObject]@{
        Name="タイムスタンプを付与してバックアップ"
        Path=".\CopyItemWithTimestampToBackupDirectory.ps1"
        Icon="💾"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Hidden
    },
    [PSCustomObject]@{
        Name="タイムスタンプを付与してリネーム"
        Path=".\RenameItemWithTimestamp.ps1"
        Icon="🕒"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Hidden
    },
    [PSCustomObject]@{
        Name="ファイルのハッシュ値を調べる"
        Path=".\FileHashViewer.ps1"
        Icon="🔍"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Normal
    },
    [PSCustomObject]@{
        Name="ファイルの文字コードを調べる"
        Path=".\FileEncodingViewer.ps1"
        Icon="🔍"
        WindowStyle=[WindowStyle]::Hidden
        PowerShellWindowStyle=[WindowStyle]::Normal
    }
)

$scriptPath = Split-Path -Parent $PSCommandPath

$scriptInfo | ForEach-Object {
    $parameter = @{
        name = $_.Name
        scriptPath = (Get-Item -Path (Join-Path -Path $scriptPath -ChildPath $_.Path) | Select-Object -ExpandProperty FullName)
        windowStyle = $_.WindowStyle
        iconLocation = $iconMap[$_.Icon]
        powershellWindowStyle = $_.PowerShellWindowStyle
    }
    createSendToScriptShortcut @parameter
}
