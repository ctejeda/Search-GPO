# Search-GPO PowerShell Function

The `Search-GPO` function is a PowerShell utility designed to facilitate the searching of Group Policy Objects (GPOs) within an Active Directory (AD) environment. It searches through each GPO's XML data for a specified string, helping administrators identify GPOs containing specific settings or configurations.

## Features

- **Domain-Aware:** Automatically detects the current domain and initiates the search across all GPOs in that domain.
- **Site-Aware:** Identifies the site in which the domain controller resides and searches GPOs accordingly.
- **Selective Output:** Provides an option to display only the GPOs that match the search criteria.
- **Detailed Results:** Outputs a custom object for each GPO, detailing the GPO name, the search string, match status, and GPO GUID.

## Prerequisites

Before using the `Search-GPO` function, ensure you have the following:

- **PowerShell:** The script is written in PowerShell and needs to be run in a PowerShell environment.
- **Active Directory Module:** The function utilizes cmdlets from the Active Directory module. Ensure it's installed and imported into your PowerShell session.

## Parameters

The function offers the following parameters:

- `$string`: (Mandatory) The string you want to search for within the GPOs.
- `$ShowMatchedOnly`: (Optional) A switch parameter. If used, the function will only output GPOs where the specified string is found.

## Usage

1. **Import the Function:**
   - Ensure the function is loaded into your PowerShell session. This can typically be done by dot-sourcing the script file:
     ```powershell
     . .\path\to\Search-GPO.ps1
     ```
   
2. **Execute the Function:**
   - Run the function with the required parameters:
     ```powershell
     Search-GPO -string "YourSearchString" -ShowMatchedOnly
     ```
   - To get results for all GPOs, including those where the string wasn't found, omit the `-ShowMatchedOnly` switch:
     ```powershell
     Search-GPO -string "YourSearchString"
     ```

## Output

The function outputs a list of custom objects, each representing a GPO. The objects contain the following properties:

- `GPO`: The display name of the GPO.
- `String`: The search string provided as input.
- `Matched`: Indicates whether the search string was found in the GPO (`True` or `False`).
- `GUID`: The unique identifier of the GPO.

## Notes

- This function is read-only and does not make any changes to GPOs or the Active Directory environment.
- Always review and test scripts in a safe, non-production environment before use.
- Ensure you have the necessary permissions to query GPOs in your Active Directory.

## Disclaimer

This script is provided 'as is' and comes with no warranties. Use it at your own risk. Always ensure you have backups and recovery procedures in place before working with production environments.
