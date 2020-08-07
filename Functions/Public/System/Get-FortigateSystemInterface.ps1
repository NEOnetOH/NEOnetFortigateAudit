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
