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