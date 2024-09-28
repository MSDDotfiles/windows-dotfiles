$ENV:STARSHIP_CONFIG = ".starship\starship.toml"
$ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
$ENV:STARSHIP_DISTRO = " Windows"

Invoke-Expression (&starship init powershell)