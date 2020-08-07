<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/8/2020 12:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	deploy.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


Write-Host "Beginning deployment" -ForegroundColor Green

$ConcatenatedFilePath = "$PSScriptRoot\concatenated.ps1"
$PSD1OutputPath = "$PSScriptRoot\dist\NEOnetFortigateAudit.psd1"
$PSM1OutputPath = "$PSScriptRoot\dist\NEOnetFortigateAudit.psm1"

"" | Out-File -FilePath $ConcatenatedFilePath -Encoding utf8

$FunctionFilePaths = Get-ChildItem "$PSScriptRoot\Functions" -Filter "*.ps1" -Recurse

Write-Host "Found $($FunctionFilePaths.count) files in $("$PSScriptRoot\Functions")"

foreach ($File in $FunctionFilePaths) {
    Write-Host " Adding file $($File.FullName)"
    
    "`r`n#region File $($File.Name)`r`n" | Out-File -FilePath $ConcatenatedFilePath -Encoding utf8 -Append
    
    Get-Content $File.FullName -Encoding UTF8 | Out-File -FilePath $ConcatenatedFilePath -Encoding utf8 -Append
    
    "`r`n#endregion" | Out-File -FilePath $ConcatenatedFilePath -Encoding utf8 -Append
}

"" | Out-File -FilePath $ConcatenatedFilePath -Encoding utf8 -Append

Write-Host " Adding psm1"
Get-Content $PSScriptRoot\NEOnetFortigateAudit.psm1 | Out-File -FilePath $ConcatenatedFilePath -Encoding UTF8 -Append

Write-Host " Copying psd1 to $PSD1OutputPath"
Copy-Item -Path $PSScriptRoot\NEOnetFortigateAudit.psd1 -Destination $PSD1OutputPath -Force

Write-Host " Copying psm1 to $PSM1OutputPath"
Copy-Item -Path $ConcatenatedFilePath -Destination $PSM1OutputPath -Force

Write-Host "Deployment complete" -ForegroundColor Green