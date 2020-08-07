<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 09:41
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-FortigateRequestTimeout.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-FortigateRequestTimeout {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 300)]
        [uint16]$Timeout
    )
    
    if ($null -eq $Script:FortigateConfig) {
        throw "Fortigate configuration is not defined!"
    }
    
    if ($PSCmdlet.ShouldProcess('Fortigate Request Timeout', 'Set')) {
        $script:FortigateConfig.RequestTimeout = $Timeout
        $script:FortigateConfig.RequestTimeout
    }
}