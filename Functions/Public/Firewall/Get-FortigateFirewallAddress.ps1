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