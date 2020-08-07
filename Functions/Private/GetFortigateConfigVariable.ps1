<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 11:19
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateConfigVariable.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function GetFortigateConfigVariable {
    if ($null -eq $script:FortigateConfig) {
        Write-Warning "FortigateConfig is not defined"
    } else {
        $script:FortigateConfig
    }
}