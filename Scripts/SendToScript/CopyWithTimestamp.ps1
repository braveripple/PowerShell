# タイムスタンプを付けてファイルをコピーする
$datetime = (Get-Date).ToString("yyyyMMddHHmmss")
foreach ($file_path in $Args) {
    if (Test-Path -LiteralPath $file_path) {
        # パスの分解.
        $folder = [System.IO.Path]::GetDirectoryName($file_path)
        $file = [System.IO.Path]::GetFileNameWithoutExtension($file_path)
        $ext = [System.IO.Path]::GetExtension($file_path)
        # コピー先パスの作成.
        $new_file_path = [System.IO.Path]::Combine($folder, $file + "_" + $datetime + $ext )
        # ファイルコピー.
        Copy-Item -LiteralPath $file_path $new_file_path -Recurse
    }
}
