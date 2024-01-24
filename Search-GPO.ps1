Function Search-GPO {


    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$true)]
        [string]$string,
        [Parameter(Mandatory=$false)]
        [switch]$ShowMatchedOnly
    )

# Get the string we want to search for 
#$string = Read-Host -Prompt "What string do you want to search for?" 
$gpoarray = @()
# Find all GPOs in the current domain
$domain = (Get-CIMInstance CIM_ComputerSystem).Domain.toLower()
$site = [void](nltest /dsgetsite)
if ($site) {
	$dc = (Get-ADDomainController -Discover -Domain $domain -SiteName $site).hostname[0].toLower()
	Write-Host -ForegroundColor Cyan "Searching GPOs in $site on $dc" 
} else {
	$dc = (Get-ADDomainController -Discover -Domain $domain).hostname[0].toLower()
	Write-Host -ForegroundColor Cyan "Searching $domain GPOs in (no site) on $dc" 
}
$DomainGPOs = Get-GPO -All -Domain $domain -Server $dc
	
# Look through each GPO's XML for the string 
foreach ($gpo in $DomainGPOs) {
	$gpoid = $gpo.Id
	$gpoDisplayName = $gpo.DisplayName
	$report = Get-GPOReport -Guid $gpoid -ReportType Xml -Domain $domain -Server $dc
	write-host "  Searching GPO $domain $gpoDisplayName for string $string : " -NoNewLine
	if ($report -match $string) { 
		Write-Host -ForegroundColor Green "matches!"
		$MatchText = ($DomainName + "\" + $gpoDisplayName + " " + $gpoid)
		$MatchedGPOList += $MatchText
        $gpoarray += [pscustomobject] @{"GPO" = $gpoDisplayName; "String" = $string; "Matched" = "True"; "GUID" = "$gpoid"}
	} # end if 
	else { 
		Write-Host -ForegroundColor Yellow "no match" 
        $gpoarray += [pscustomobject] @{"GPO" = $gpoDisplayName; "String" = $string; "Matched" = "False"; "GUID" = "$gpoid"}
	} # end else 
} # end foreach


 if ($ShowMatchedOnly)
        { $gpoarray | ? {$_.Matched -eq 'True'} }
        else {$gpoarray}


}
