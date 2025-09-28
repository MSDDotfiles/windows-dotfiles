${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

Set-Alias touch Touch-File

if (Get-Command -Name "edit" -ErrorAction SilentlyContinue) {
	
} else {
	winget install Microsoft.Edit --force --accept-source-agreements --accept-package-agreements
}

if (Get-Command -Name "bat" -ErrorAction SilentlyContinue) {
	Set-Alias cat bat
} else {
	winget install sharkdp.bat --force --accept-source-agreements --accept-package-agreements
}