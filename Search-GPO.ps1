Function Search-GPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$string,
        [Parameter(Mandatory=$false)]
        [switch]$ShowMatchedOnly
    )

    $gpoarray = @()
    $domain = (Get-ADDomain).DNSRoot
    $gpos = Get-GPO -All -Domain $domain

    foreach ($gpo in $gpos) {
        $gpoid = $gpo.Id
        $gpoDisplayName = $gpo.DisplayName
        $report = Get-GPOReport -Guid $gpoid -ReportType Xml -Domain $domain

        $links = Get-GPOLink -Guid $gpoid
        foreach ($link in $links) {
            $ou = $link.SOMName
            $path = $link.SOMPath

            if ($report -match $string) {
                $gpoarray += [pscustomobject] @{
                    GPO = $gpoDisplayName
                    String = $string
                    Matched = "True"
                    GUID = $gpoid
                    Location = $ou
                    Path = $path
                }
            } else {
                $gpoarray += [pscustomobject] @{
                    GPO = $gpoDisplayName
                    String = $string
                    Matched = "False"
                    GUID = $gpoid
                    Location = $ou
                    Path = $path
                }
            }
        }
    }

    if ($ShowMatchedOnly) {
        $gpoarray | Where-Object {$_.Matched -eq 'True'}
    } else {
        $gpoarray
    }
}
