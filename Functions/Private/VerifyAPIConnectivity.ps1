<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 10:16
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	VerifyAPIConnectivity.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('system', 'status'))
    
    $uri = BuildNewURI -Segments $uriSegments -SkipConnectedCheck
    
    InvokeFortigateRequest -URI $uri -Raw
}