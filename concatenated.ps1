

#region File BuildNewURI.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:08
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildNewURI.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Fortigate
    
    .DESCRIPTION
        Internal function used to build a URIBuilder object.
    
    .PARAMETER Hostname
        Hostname of the Fortigate API
    
    .PARAMETER Segments
        Array of strings for each segment in the URL path
    
    .PARAMETER Parameters
        Hashtable of query parameters to include
    
    .PARAMETER HTTPS
        Whether to use HTTPS or HTTP
    
    .PARAMETER Port
        A description of the Port parameter.
    
    .PARAMETER APIInfo
        A description of the APIInfo parameter.
    
    .EXAMPLE
        PS C:\> BuildNewURI
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$Hostname,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Segments,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters,
        
        [Parameter(Mandatory = $false)]
        [boolean]$HTTPS = $true,
        
        [ValidateRange(1, 65535)]
        [uint16]$Port = 443,
        
        [switch]$SkipConnectedCheck
    )
    
    Write-Verbose "Building URI"
    
    if (-not $SkipConnectedCheck) {
        # There is no point in continuing if we have not successfully connected to an API
        $null = CheckFortigateIsConnected
    }
    
    if (-not $Hostname) {
        $Hostname = Get-FortigateHostname
    }
    
    if ($HTTPS) {
        Write-Verbose " Setting scheme to HTTPS"
        $Scheme = 'https'
    } else {
        Write-Warning " Connecting via non-secure HTTP is not-recommended"
        
        Write-Verbose " Setting scheme to HTTP"
        $Scheme = 'http'
        
        if (-not $PSBoundParameters.ContainsKey('Port')) {
            # Set the port to 80 if the user did not supply it
            Write-Verbose " Setting port to 80 as default because it was not supplied by the user"
            $Port = 80
        }
    }
    
    # Begin a URI builder with HTTP/HTTPS and the provided hostname
    $uriBuilder = [System.UriBuilder]::new($Scheme, $Hostname, $Port)
    
    # Generate the path by trimming excess slashes and whitespace from the $segments[] and joining together
    $uriBuilder.Path = "api/v2/cmdb/{0}/" -f ($Segments.ForEach({ $_.trim('/').trim() }) -join '/')
    
    Write-Verbose " URIPath: $($uriBuilder.Path)"
    
    if ($parameters) {
        # Loop through the parameters and use the HttpUtility to create a Query string
        [System.Collections.Specialized.NameValueCollection]$URIParams = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        foreach ($param in $Parameters.GetEnumerator()) {
            Write-Verbose " Adding URI parameter $($param.Key):$($param.Value)"
            $URIParams[$param.Key] = $param.Value
        }
        
        $uriBuilder.Query = $URIParams.ToString()
    }
    
    Write-Verbose " Completed building URIBuilder"
    # Return the entire UriBuilder object
    $uriBuilder
}





#endregion

#region File BuildURIComponents.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 11:58
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildURIComponents.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function BuildURIComponents {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$URISegments,
        
        [Parameter(Mandatory = $true)]
        [object]$ParametersDictionary,
        
        [string[]]$SkipParameterByName
    )
    
    Write-Verbose "Building URI components"
    
    $URIParameters = @{}
    
    foreach ($CmdletParameterName in $ParametersDictionary.Keys) {
        if ($CmdletParameterName -in $script:FortigateURICommonParameterNamesToIgnore) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping common parameter [$CmdletParameterName]"
            continue
        }
        
        if ($CmdletParameterName -in $SkipParameterByName) {
            Write-Debug "Skipping parameter [$CmdletParameterName] by SkipParameterByName"
            continue
        }
        
        switch ($CmdletParameterName) {
            "format" {
                $URIParameters['format'] = $ParametersDictionary[$CmdletParameterName] -join '|'
                
                break
            }
            
            'vdom' {
                $URIParameters['vdom'] = $ParametersDictionary[$CmdletParameterName] -join ','
                
                break
            }
            
            'WithMeta' {
                $URIParameters['with_meta'] = $ParametersDictionary[$CmdletParameterName]
                
                break
            }
            
            #            "id" {
            #                # Check if there is one or more values for Id and build a URI or query as appropriate
            #                if (@($ParametersDictionary[$CmdletParameterName]).Count -gt 1) {
            #                    Write-Verbose " Joining IDs for parameter"
            #                    $URIParameters['id__in'] = $ParametersDictionary[$CmdletParameterName] -join ','
            #                } else {
            #                    Write-Verbose " Adding ID to segments"
            #                    [void]$uriSegments.Add($ParametersDictionary[$CmdletParameterName])
            #                }
            #                
            #                break
            #            }
            #            
            #            'Query' {
            #                Write-Verbose " Adding query parameter"
            #                $URIParameters['q'] = $ParametersDictionary[$CmdletParameterName]
            #                break
            #            }
            #            
            #            'CustomFields' {
            #                Write-Verbose " Adding custom field query parameters"
            #                foreach ($field in $ParametersDictionary[$CmdletParameterName].GetEnumerator()) {
            #                    Write-Verbose "  Adding parameter 'cf_$($field.Key) = $($field.Value)"
            #                    $URIParameters["cf_$($field.Key.ToLower())"] = $field.Value
            #                }
            #                
            #                break
            #            }
            
            default {
                Write-Verbose " Adding [$($CmdletParameterName.ToLower())] parameter"
                $URIParameters[$CmdletParameterName.ToLower()] = $ParametersDictionary[$CmdletParameterName]
                break
            }
        }
    }
    
    return @{
        'Segments' = [System.Collections.ArrayList]$URISegments
        'Parameters' = $URIParameters
    }
}

#endregion

#region File CheckFortigateIsConnected.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 14:24
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckFortigateIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckFortigateIsConnected {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Checking connection status"
    if (-not $script:FortigateConfig.Connected) {
        throw "Not connected to a Fortigate API! Please run 'Connect-FortigateAPI'"
    }
}

#endregion

#region File GetFortigateConfigVariable.ps1

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

#endregion

#region File InvokeFortigateRequest.ps1

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

#endregion

#region File SetupFortigateConfigVariable.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:09
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	SetupFortigateConfigVariable.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function SetupFortigateConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )
    
    Write-Verbose "Checking for FortigateConfig hashtable"
    if ((-not ($script:FortigateConfig)) -or $Overwrite) {
        Write-Verbose "Creating FortigateConfig hashtable"
        $script:FortigateConfig = @{
            'Connected'      = $false
            'APIToken'       = $null
            'Hostname'       = $null
            'RequestTimeout' = 5
#            'Cache'          = @{
#                'System' = @{
#                    'VDOM' = $null
#                    'Interface' = $null
#                }
#                
#                'Firewall' = @{
#                    'Address' = $null
#                    'Policy'  = $null
#                    'Service' = @{
#                        'Custom' = $null
#                        'Group' = $null
#                    }
#                    'VIP' = $null
#                }
#                
#                'Router' = @{
#                    'StaticRoute' = $null
#                }
#            }
        }
    }
    
    Write-Verbose "FortigateConfig hashtable already exists"
}

#endregion

#region File SetupFortigateURICommonParameters.ps1

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


#endregion

#region File VerifyAPIConnectivity.ps1

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

#endregion

#region File Get-FortigateFirewallAddress.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 14:33
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallAddress.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallAddress {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [switch]$v6,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall'))
    
    if ($v6) {
        [void]$Segments.Add('address6')
    } else {
        [void]$Segments.Add('address')
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        [void]$Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Name'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateFirewallAddressGroup.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 15:20
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallAddressGroup.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallAddressGroup {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [switch]$v6,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall'))
    
    if ($v6) {
        [void]$Segments.Add('addrgrp6')
    } else {
        [void]$Segments.Add('addrgrp')
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        [void]$Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Name'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateFirewallPolicy.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 14:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallPolicy.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallPolicy {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByID',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [uint32]$PolicyId,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [switch]$v6,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall'))
    
    if ($v6) {
        [void]$Segments.Add('policy6')
    } else {
        [void]$Segments.Add('policy')
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'ByID') {
        [void]$Segments.Add($PolicyId)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'PolicyId'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateFirewallServiceCustom.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 13:05
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallServiceCustom.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallServiceCustom {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall.service', 'custom'))
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        [void]$Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Name'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateFirewallServiceGroup.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 14:25
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallServiceGroup.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallServiceGroup {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall.service', 'group'))
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        [void]$Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Name'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateFirewallVIP.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 15:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateFirewallVIP.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateFirewallVIP {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [switch]$v6,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('firewall'))
    
    if ($v6) {
        [void]$Segments.Add('vip6')
    } else {
        [void]$Segments.Add('vip')
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        [void]$Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Name'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateRouterStaticRoute.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/8/2020 10:35
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateRouterStaticRoute.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateRouterStaticRoute {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'BySeqNum',
                   Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [uint32]$SequenceNumber,
        
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [switch]$v6,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('router', 'static'))
    
    if ($PsCmdlet.ParameterSetName -eq 'BySeqNum') {
        [void]$Segments.Add($SequenceNumber)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'SequenceNumber'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Assert-FortigateAPIIsConnected.ps1

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

#endregion

#region File Connect-FortigateAPI.ps1

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

#endregion

#region File Get-FortigateAPIToken.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/1/2020 15:27
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateCredential.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateAPIToken {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()
    
    if (($null -eq $script:FortigateConfig.APIToken) -or (-not $script:FortigateConfig.APIToken)) {
        throw "Fortigate APIToken not set! You may set with Set-FortigateAPIToken"
    }
    
    $script:FortigateConfig.APIToken
}

#endregion

#region File Get-FortigateHostname.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/7/2020 09:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateHostname.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-FortigateHostname {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Fortigate hostname"
    if ($null -eq $script:FortigateConfig.Hostname) {
        throw "Fortigate Hostname is not set! You may set it with Set-FortigateHostname -Hostname 'hostname.domain.tld'"
    }
    
    $script:FortigateConfig.Hostname
}

#endregion

#region File Get-FortigateRequestTimeout.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/14/2020 09:42
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateRequestTimeout.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateRequestTimeout {
    [CmdletBinding()]
    [OutputType([uint16])]
    param ()
    
    Write-Verbose "Getting Fortigate request timeout"
    if ($null -eq $script:FortigateConfig) {
        throw "Fortigate Configuration is not set!"
    }
    
    $script:FortigateConfig.RequestTimeout
}

#endregion

#region File Set-FortigateAPIToken.ps1

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

#endregion

#region File Set-FortigateHostname.ps1

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

#endregion

#region File Set-FortigateRequestTimeout.ps1

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

#endregion

#region File Get-FortigateSystemInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 11:46
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateSystemInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateSystemInterface {
<#
    .SYNOPSIS
        Get interfaces
    
    .DESCRIPTION
        A detailed description of the Get-FortigateSystemInterface function.
    
    .PARAMETER VDOM
        Specify the Virtual Domain(s) from which results are returned or changes are applied to. If this parameter is not provided, the management VDOM will be used. If the admin does not have access to the VDOM, a permission error will be returned.
        
        This parameter is one of:
        root (Single VDOM)
        vdom1, vdom2 (Multiple VDOMs)
        * (All VDOMs)
    
    .PARAMETER Scope
        A description of the Scope parameter.
    
    .PARAMETER Format
        List of property names to include in results
    
    .PARAMETER Datasource
        Enable to include datasource information for each linked object
    
    .PARAMETER Start
        Starting entry index
    
    .PARAMETER Count
        Maximum number of entries to return
    
    .EXAMPLE
        		PS C:\> Get-FortigateSystemInterface
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [string[]]$VDOM,
        
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [string[]]$Format,
        
        [switch]$Datasource,
        
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('system', 'interface'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

#region File Get-FortigateSystemStatus.ps1

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

#endregion

#region File Get-FortigateSystemVDOM.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/7/2020 12:46
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-FortigateSystemVDOM.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-FortigateSystemVDOM {
    [CmdletBinding(DefaultParameterSetName = 'Multiple')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $false)]
        [string]$Name,
        
        [string[]]$Format,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateSet('global', 'vdom', '*', IgnoreCase = $true)]
        [string]$Scope,
        
        [switch]$Datasource,
        
        [switch]$WithMeta,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Index')]
        [uint32]$Start,
        
        [Parameter(ParameterSetName = 'Multiple')]
        [ValidateNotNullOrEmpty()]
        [Alias('Limit')]
        [uint32]$Count,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('system', 'vdom'))
    
    if ($PsCmdlet.ParameterSetName -eq 'ByName') {
        $Segments.Add($Name)
    }
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeFortigateRequest -URI $URI -Raw:$Raw
}

#endregion

<#
    .NOTES
    --------------------------------------------------------------------------------
     Code generated by:  SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
     Generated on:       4/6/2020 16:37
     Generated by:       Claussen
     Organization:       NEOnet
    --------------------------------------------------------------------------------
    .DESCRIPTION
        Script generated by PowerShell Studio 2020
#>


SetupFortigateConfigVariable
SetupFortigateURICommonParametersToIgnore

Export-ModuleMember "*-*"
Export-ModuleMember 'GetFortigateConfigVariable'
