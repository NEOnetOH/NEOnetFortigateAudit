<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 14:13
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Assert-FortigateAPIIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Assert-FortigateAPIIsConnected {
<#
    .SYNOPSIS
        Checks if the API is successfully connected
    
    .DESCRIPTION
        A detailed description of the Assert-FortigateAPIIsConnected function.
    
    .EXAMPLE
        		PS C:\> Assert-FortigateAPIIsConnected
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([boolean])]
    param ()
    
    try {
        $APIResult = VerifyAPIConnectivity -ErrorAction Stop
        $true
    } catch {
        $false
    }
}
