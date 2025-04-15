function Touch-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        (Get-Item -Path $Path -EA 0) ? ((Get-Item -Path $Path).LastWriteTime = Get-Date) : (New-Item -ItemType File -Path $Path -Force)
    } catch {
        Write-Error "An error occurred: $_"
    }
}