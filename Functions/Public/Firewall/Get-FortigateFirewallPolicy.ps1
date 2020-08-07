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