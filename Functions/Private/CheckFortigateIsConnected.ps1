<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 14:24
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckFortigateIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckFortigateIsConnected {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Checking connection status"
    if (-not $script:FortigateConfig.Connected) {
        throw "Not connected to a Fortigate API! Please run 'Connect-FortigateAPI'"
    }
}