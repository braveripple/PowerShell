$pgpassfile = $env:APPDATA + "/postgresql/pgpass.conf"
if (!(Test-Path $pgpassfile -PathType Leaf)) {
    New-Item $pgpassfile -ItemType File -Force > $null
}
code $pgpassfile
