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