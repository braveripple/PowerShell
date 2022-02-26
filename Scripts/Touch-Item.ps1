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
    write-host "begin"
}
process {
    if ($PSBoundParameters.ContainsKey('Path')) {
        $targets = Convert-Path -Path $Path
    }
    else {
        $targets = Convert-Path -LiteralPath $LiteralPath
    }
    $targets | Foreach-Object {
        if ($PSCmdlet.ShouldProcess($_)) {
            If (Test-Path -LiteralPath $_ -PathType Any) {
                (Get-Item -LiteralPath $_).LastWriteTime = Get-Date
                Get-Item -LiteralPath $_
            }
        }
    }
}
