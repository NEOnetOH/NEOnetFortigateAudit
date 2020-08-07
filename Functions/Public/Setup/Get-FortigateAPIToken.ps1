<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/1/2020 15:27
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateCredential.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateAPIToken {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()
    
    if (($null -eq $script:FortigateConfig.APIToken) -or (-not $script:FortigateConfig.APIToken)) {
        throw "Fortigate APIToken not set! You may set with Set-FortigateAPIToken"
    }
    
    $script:FortigateConfig.APIToken
}