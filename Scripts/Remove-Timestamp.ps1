# 文字列からタイムスタンプっぽいものを削除する
param (
    [Parameter(Mandatory = $True, Position = 0)]
    [string]
    $InputString,
    
    [Parameter(Mandatory = $False)]
    [string]
    $Format = "yyyyMMddHHmmss",
    
    [Parameter(Mandatory = $False)]
    [string]
    $Prefix = "_"
)
$formatRegex = $Format -replace "[yMdHms]","\d"
$dateStrings = [RegEx]::Matches($InputString, $formatRegex)
$dateStrings | ForEach-Object `
-Begin { 
    $resultString = $InputString 
} `
-Process {
    [ref] $parsedDate = Get-Date
    $dateString = $_.Value
    if([DateTime]::TryParseExact(
        $dateString, 
        $Format, 
        [Globalization.DateTimeFormatInfo]::CurrentInfo,
        [System.Globalization.DateTimeStyles]::None,
        $parsedDate
    )) {
        $resultString = $resultString -replace "${Prefix}${dateString}", ""
    }
} `
-End {
    $resultString
}