<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 09:42
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateRequestTimeout.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateRequestTimeout {
    [CmdletBinding()]
    [OutputType([uint16])]
    param ()
    
    Write-Verbose "Getting Fortigate request timeout"
    if ($null -eq $script:FortigateConfig) {
        throw "Fortigate Configuration is not set!"
    }
    
    $script:FortigateConfig.RequestTimeout
}