# 文字列からタイムスタンプっぽいものを削除する
[CmdletBinding(
    SupportsShouldProcess = $True
)]
param (
    [Parameter(Mandatory = $True, Position = 0,
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]
    $InputString,
    
    [Parameter(Mandatory = $False)]
    [string]
    $Format = "yyyyMMddHHmmss",
    
    [Parameter(Mandatory = $False)]
    [string]
    $Prefix = "_"
)
begin {
    $formatRegex = $Format -replace "[yMdHms]","\d"
}
process {
    foreach($s in $InputString) {
        $dateStrings = [RegEx]::Matches($s, $formatRegex)
        $resultString = $s 
        foreach($dataString in $dateStrings) {
            [ref] $parsedDate = Get-Date
            $value = $dataString.Value
            if([DateTime]::TryParseExact(
                $value, 
                $Format, 
                [Globalization.DateTimeFormatInfo]::CurrentInfo,
                [System.Globalization.DateTimeStyles]::None,
                $parsedDate
            )) {
                $resultString = $resultString -replace "${Prefix}${value}", ""
            }
        }
        # ShouldProcessで表示する処理対象
        $targetVerbose = "Before: ${s} After: ${resultString}"
        if ($PSCmdlet.ShouldProcess($targetVerbose, "Remove Timestamp")) {
            $resultString
        }
    }
}