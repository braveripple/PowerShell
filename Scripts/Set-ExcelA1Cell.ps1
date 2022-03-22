[CmdletBinding(
    SupportsShouldProcess = $True,
    DefaultParameterSetName = 'Path'
)]
param (
    [SupportsWildCards()]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'Path',
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]$Path,

    [Alias('LP')]
    [Alias('PSPath')]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath',
        ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True)]
    [string[]]$LiteralPath
)
begin {
    function cleanUp() {
        try {
            if ($null -ne $excel) {
                $excel.Quit()
                $excel = $null
                [GC]::collect()
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }

    try {
        $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        $excel.DisplayAlerts = $false
    }
    catch {
        Write-Error $_.Exception.Message -ErrorAction Continue
        cleanUp
        exit 255
    }

}
process {
    $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
    foreach ($p in $InputPath) {
        $targets = @()
        try {
            $param = @{ $PSCmdlet.ParameterSetName = $p }
            $targets = @(Convert-Path @param -ErrorAction Stop)
        }
        catch {
            Write-Error $_.Exception.Message -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") { return }
        }
    }    
    foreach ($target in $targets) {
        $file = Get-Item -LiteralPath $target
        If ($file.Extension -notin @('.xls', '.xlsx', '.xlsm')) {
            Write-Error "'$target' file is not Excel file." -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") { return }
        }
        if ($PSCmdlet.ShouldProcess($target)) {
            try {
                $wb = $excel.Workbooks.Open($target, [Type]::Missing, [Type]::Missing, [Type]::Missing, [Type]::Missing)
                foreach ($ws in $wb.Worksheets()) {
                    $tmp = $ws.Activate()
                    $tmp = $ws.Range("A1").Select()
                    $tmp = $excel.ActiveWindow.Zoom() = 100
                    $tmp = $excel.ActiveWindow.ScrollColumn() = 1
                    $tmp = $excel.ActiveWindow.ScrollRow() = 1
                    $tmp > $null
                }
                $wb.Worksheets(1).Activate()
                $wb.Save()
            }
            catch {
                Write-Error $_.Exception.Message -ErrorAction Continue
                if ($ErrorActionPreference -eq "Stop") {
                    if ($null -ne $wb) {
                        $wb.Close()
                    }
                    return
                }
            }
            finally {
                if ($null -ne $wb) {
                    $wb.Close()
                }
            }
        }
    }
}
end {
    cleanUp
}