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

    $ous = Get-ADOrganizationalUnit -Filter * -Properties gPLink

    foreach ($gpo in $gpos) {
        $gpoid = $gpo.Id
        $gpoDisplayName = $gpo.DisplayName
        $report = Get-GPOReport -Guid $gpoid -ReportType Xml -Domain $domain

        foreach ($ou in $ous) {
            if ($ou.gPLink -match $gpoid) {
                $location = $ou.Name
                $path = $ou.DistinguishedName

                if ($report -match $string) {
                    $gpoarray += [pscustomobject] @{
                        GPO = $gpoDisplayName
                        String = $string
                        Matched = "True"
                        GUID = $gpoid
                        Location = $location
                        Path = $path
                    }
                } else {
                    $gpoarray += [pscustomobject] @{
                        GPO = $gpoDisplayName
                        String = $string
                        Matched = "False"
                        GUID = $gpoid
                        Location = $location
                        Path = $path
                    }
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
