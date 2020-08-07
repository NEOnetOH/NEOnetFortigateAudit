<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateHostname.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-FortigateHostname {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Fortigate hostname"
    if ($null -eq $script:FortigateConfig.Hostname) {
        throw "Fortigate Hostname is not set! You may set it with Set-FortigateHostname -Hostname 'hostname.domain.tld'"
    }
    
    $script:FortigateConfig.Hostname
}