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

        # Find where the GPO is linked
        $gpoLinks = Get-GPInheritance -Target "ou=$domain,dc=$dc" | Select-Object -ExpandProperty GpoLinks
        $ouPaths = $gpoLinks | Where-Object { $_.GpoId -eq $gpoid } | ForEach-Object { $_.Target }

        if ($report -match $string) {
            $gpoarray += [pscustomobject] @{
                GPO = $gpoDisplayName
                String = $string
                Matched = "True"
                GUID = "$gpoid"
                OUs = $ouPaths -join ", "
            }
        } else {
            $gpoarray += [pscustomobject] @{
                GPO = $gpoDisplayName
                String = $string
                Matched = "False"
                GUID = "$gpoid"
                OUs = $ouPaths -join ", "
            }
        }
    }

    if ($ShowMatchedOnly) {
        $gpoarray | Where-Object {$_.Matched -eq 'True'}
    } else {
        $gpoarray
    }
}
