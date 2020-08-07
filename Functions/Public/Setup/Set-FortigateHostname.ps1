<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-FortigateHostname.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-FortigateHostName {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname
    )
    
    if ($PSCmdlet.ShouldProcess('Fortigate Hostname', 'Set')) {
        $script:FortigateConfig.Hostname = $Hostname.Trim()
        $script:FortigateConfig.Hostname
    }
}