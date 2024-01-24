Function Search-GPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$string,
        [Parameter(Mandatory=$false)]
        [switch]$ShowMatchedOnly
    )

    $gpoarray = @()
    $domain = (Get-CIMInstance CIM_ComputerSystem).Domain.toLower()
    $site = [void](nltest /dsgetsite)
    $dc = if ($site) {
        (Get-ADDomainController -Discover -Domain $domain -SiteName $site).hostname[0].toLower()
    } else {
        (Get-ADDomainController -Discover -Domain $domain).hostname[0].toLower()
    }

    $DomainGPOs = Get-GPO -All -Domain $domain -Server $dc
    
    foreach ($gpo in $DomainGPOs) {
        $gpoid = $gpo.Id
        $gpoDisplayName = $gpo.DisplayName
        $report = Get-GPOReport -Guid $gpoid -ReportType Xml -Domain $domain -Server $dc
        $gpoPath = "\\$domain\SYSVOL\$domain\Policies\{$gpoid}"

        if ($report -match $string) {
            $gpoarray += [pscustomobject] @{
                GPO = $gpoDisplayName
                String = $string
                Matched = "True"
                GUID = "$gpoid"
                Path = $gpoPath
            }
        } else {
            $gpoarray += [pscustomobject] @{
                GPO = $gpoDisplayName
                String = $string
                Matched = "False"
                GUID = "$gpoid"
                Path = $gpoPath
            }
        }
    }

    if ($ShowMatchedOnly) {
        $gpoarray | Where-Object {$_.Matched -eq 'True'}
    } else {
        $gpoarray
    }
}
