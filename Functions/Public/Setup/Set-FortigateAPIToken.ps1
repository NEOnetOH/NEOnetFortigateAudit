<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-FortigateAPIToken.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-FortigateAPIToken {
    [CmdletBinding(DefaultParameterSetName = 'CredsObject',
                   ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscredential])]
    param
    (
        [Parameter(ParameterSetName = 'CredsObject',
                   Mandatory = $true)]
        [pscredential]$Credential,
        
        [Parameter(ParameterSetName = 'UserPass',
                   Mandatory = $true)]
        [securestring]$Token
    )
    
    if ($PSCmdlet.ShouldProcess('Fortigate APIToken', 'Set')) {
        switch ($PsCmdlet.ParameterSetName) {
            'CredsObject' {
                $script:FortigateConfig.APIToken = $Credential
                break
            }
            
            'UserPass' {
                $script:FortigateConfig.APIToken = [System.Management.Automation.PSCredential]::new('notapplicable', $Token)
                break
            }
        }
        
        $script:FortigateConfig.APIToken
    }
}