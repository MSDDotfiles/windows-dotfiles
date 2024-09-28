$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
$ENV:STARSHIP_DISTRO = " Windows"
Invoke-Expression (&starship init powershell)

Import-Module Terminal-Icons

Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionViewStyle ListView
