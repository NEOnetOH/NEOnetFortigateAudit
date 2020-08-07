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
