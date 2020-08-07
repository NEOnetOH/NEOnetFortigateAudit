<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 10:16
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	InvokeFortigateRequest.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function InvokeFortigateRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,
        
        [Hashtable]$Headers = @{},
        
        [pscustomobject]$Body = $null,
        
        [ValidateRange(0, 300)]
        [uint16]$Timeout = $script:FortigateConfig.RequestTimeout,
        
        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', IgnoreCase = $true)]
        [string]$Method = 'GET',
        
        [switch]$Raw
    )
    
    $creds = Get-FortigateAPIToken
    
    # Re-process the query string to add the access_token
    #[System.Collections.Specialized.NameValueCollection]$URIParams = [System.Web.HttpUtility]::ParseQueryString($URI.Query)
    #$URIParams.Add('access_token', $creds.GetNetworkCredential().Password)
    #$URI.Query = $URIParams.ToString()
    $Headers.Add('Authorization', "Bearer $($creds.GetNetworkCredential().Password)")
    
    $InvokeRestMethodSplat = @{
        'Method' = $Method
        'Uri'    = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers' = $Headers
        'TimeoutSec' = $Timeout
        'ContentType' = 'application/json'
        'ErrorAction' = 'Stop'
        'Verbose' = $VerbosePreference
    }
    
    if ($null -ne $Body) {
        Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress)"
        $null = $InvokeRestMethodSplat.Add('Body', ($Body | ConvertTo-Json -Compress))
    }
    
    $result = $null
    
    try {
        $result = Invoke-RestMethod @InvokeRestMethodSplat
        
        # If the user wants the raw value from the API... otherwise return only the actual result
        if ($Raw) {
            Write-Verbose "Returning raw result by choice"
            return $result
        } else {
            if ($result.psobject.Properties.Name.Contains('results')) {
                Write-Verbose "Found Results property on data, returning results directly"
                return $result.Results
            } else {
                Write-Verbose "Did NOT find results property on data, returning raw result"
                return $result
            }
        }
    } catch {
        throw $_
    }
}