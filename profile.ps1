Push-Location (Split-Path -parent $profile)
	"aliases","starship","functions","terminal-icons","readline","syntax-highlight" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location
