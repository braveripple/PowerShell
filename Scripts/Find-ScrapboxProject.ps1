[CmdletBinding(
    SupportsShouldProcess = $True
)]
param (
    [Parameter(Mandatory = $True, Position = 0,
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]
    $ProjectName
)

process {
    foreach ($pn in $ProjectName) {
        $targetVerbose = "https://scrapbox.io/${pn}"
        if ($PSCmdlet.ShouldProcess($targetVerbose, "Find Scrapbox Project Page")) {
            try{
                $result = Invoke-RestMethod -Method Get -Uri "https://scrapbox.io/api/pages/${pn}/"
                [PSCustomObject]@{
                    Name=$pn;
                    ProjectType="Public";
                    PageCount=$result.count
                    Uri = "https://scrapbox.io/${pn}";
                }
            } catch {
                $statusCode = $_.Exception.Response.StatusCode
                [PSCustomObject]@{
                    Name = $pn;
                    ProjectType = if ($statusCode -eq "Unauthorized") {
                        "Private"
                    } elseif ($statusCode -eq "NotFound") {
                        "NotFound"
                    } else {
                        "Unknown"
                    };
                    PageCount = 0;
                    Uri = "https://scrapbox.io/${pn}";
                }
            }
        }
    }
}
