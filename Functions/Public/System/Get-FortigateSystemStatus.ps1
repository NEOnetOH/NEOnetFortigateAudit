<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 14:19
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateSystemStatus.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateSystemStatus {
    [CmdletBinding()]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('system', 'status'))
    
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeFortigateRequest -URI $uri -Raw
}