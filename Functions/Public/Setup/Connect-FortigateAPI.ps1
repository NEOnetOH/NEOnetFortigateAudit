<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 10:14
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Connect-FortigateAPI.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Connect-FortigateAPI {
<#
    .SYNOPSIS
        Connects to the Fortigate API and ensures Credential work properly
    
    .DESCRIPTION
        A detailed description of the Connect-FortigateAPI function.
    
    .PARAMETER Hostname
        A description of the Hostname parameter.
    
    .PARAMETER Credential
        A description of the Credential parameter.
    
    .EXAMPLE
        PS C:\> Connect-FortigateAPI -Hostname "Fortigate.domain.com"
        
        This will prompt for Credential, then proceed to attempt a connection to Fortigate
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        
        [Parameter(Mandatory = $false)]
        [pscredential]$Credential
    )
    
    if (-not $Credential) {
        try {
            $Credential = Get-FortigateAPIToken -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -UserName 'username-not-applicable' -Message "Enter API token for Fortigate")) {
                throw "Token is necessary to connect to a Fortigate API."
            }
        }
    }
    
    $null = Set-FortigateHostName -Hostname $Hostname
    $null = Set-FortigateAPIToken -Credential $Credential
    
    try {
        Write-Verbose "Verifying API connectivity..."
        $APIResult = VerifyAPIConnectivity
        $script:FortigateConfig.Connected = $true
        Write-Verbose "Successfully connected! Fortigate version [$($APIResult.Version)]"
    } catch {
        Write-Verbose "Failed to connect. Generating error"
        Write-Verbose $_.Exception.Message
        if (($_.Exception.Response) -and ($_.Exception.Response.StatusCode -eq 403)) {
            throw "Invalid token"
        } else {
            throw $_
        }
    }
        
    Write-Verbose "Connection process completed"
}