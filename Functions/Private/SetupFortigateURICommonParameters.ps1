<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 12:04
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	SetupFortigateURICommonParameters.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function SetupFortigateURICommonParametersToIgnore {
    [CmdletBinding()]
    param ()
    
    # Build a list of common paramters so we can omit them to build URI parameters
    $script:FortigateURICommonParameterNamesToIgnore = New-Object System.Collections.ArrayList
    [void]$script:FortigateURICommonParameterNamesToIgnore.AddRange(@([System.Management.Automation.PSCmdlet]::CommonParameters))
    [void]$script:FortigateURICommonParameterNamesToIgnore.AddRange(@([System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
    [void]$script:FortigateURICommonParameterNamesToIgnore.Add('Raw')
}

