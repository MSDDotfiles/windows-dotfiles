function Out-HostColored {
    [CmdletBinding(DefaultParameterSetName = 'SingleColor')]
    param(
        [Parameter(ParameterSetName = 'SingleColor', Position = 0, Mandatory = $True)]
        [string[]] $Pattern,
        [Parameter(ParameterSetName = 'SingleColor', Position = 1)]
        [ConsoleColor] $ForegroundColor = [ConsoleColor]::Yellow,
        [Parameter(ParameterSetName = 'SingleColor', Position = 2)]
        [ConsoleColor] $BackgroundColor,
        [Parameter(ParameterSetName = 'PerPatternColor', Position = 0, Mandatory = $True)]
        [System.Collections.IDictionary] $PatternColorMap,
        [Parameter(ValueFromPipeline = $True)] $InputObject,
        [switch] $WholeLine,
        [switch] $SimpleMatch,
        [switch] $CaseSensitive
    )

    begin {
        Set-StrictMode -Version 1

        if ($PSCmdlet.ParameterSetName -eq 'SingleColor') {
            $PatternColorMap = @{
                $Pattern = $ForegroundColor, $BackgroundColor
            }
        }

        try {
            [System.Text.RegularExpressions.RegexOptions] $reOpts = 
            if ($CaseSensitive) { 'Compiled, ExplicitCapture' }
            else { 'Compiled, ExplicitCapture, IgnoreCase' }

            $map = [ordered] @{}
            foreach ($entry in $PatternColorMap.GetEnumerator()) {
                if ($entry.Value -is [array]) {
                    $fg, $bg = $entry.Value
                }
                else {
                    $fg, $bg = $entry.Value -split ','
                }
                $colorArgs = @{}
                if ($fg) { $colorArgs['ForegroundColor'] = [ConsoleColor] $fg }
                if ($bg) { $colorArgs['BackgroundColor'] = [ConsoleColor] $bg }

                $re = New-Object regex -Args `
                    $(if ($SimpleMatch) {
                        ($entry.Key | ForEach-Object { [regex]::Escape($_) }) -join '|'
                    }
                    else {
                        ($entry.Key | ForEach-Object { '({0})' -f $_ }) -join '|'
                    }),
                    $reOpts

                $map[$re] = $colorArgs
            }
        }
        catch { throw }

        $htArgs = @{ Stream = $True }
        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $htArgs.InputObject = $InputObject
        }

        $scriptCmd = {
            & $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Out-String', 'Cmdlet') @htArgs | ForEach-Object {

                $matchInfos = :patternLoop foreach ($entry in $map.GetEnumerator()) {
                    foreach ($m in $entry.Key.Matches($_)) {
                        @{ Index = $m.Index; Text = $m.Value; ColorArgs = $entry.Value }
                        if ($WholeLine) { break patternLoop }
                    }
                }

                if (-not $matchInfos) {
                    Write-Host -NoNewline $_
                }
                elseif ($WholeLine) {
                    $colorArgs = $matchInfos.ColorArgs
                    Write-Host -NoNewline @colorArgs $_
                }
                else {
                    $offset = 0
                    foreach ($mi in $matchInfos | Sort-Object { $_.Index }) {
                        if ($mi.Index -lt $offset) {
                            continue
                        }
                        elseif ($offset -lt $mi.Index) {
                            Write-Host -NoNewline $_.Substring($offset, $mi.Index - $offset)
                        }
                        $offset = $mi.Index + $mi.Text.Length
                        $colorArgs = $mi.ColorArgs
                        Write-Host -NoNewline @colorArgs $mi.Text
                    }

                    if ($offset -lt $_.Length) {
                        Write-Host -NoNewline $_.Substring($offset)
                    }
                }
                Write-Host ''
            }
        }

        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    }

    process
    {
        $steppablePipeline.Process($_)
    }

    end
    {
        $steppablePipeline.End()
    }
}


function Touch-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
		if (Get-Item -Path $Path -EA 0) {
			'File already created in ' + (Get-Item -Path $Path).Directory | Out-HostColored @{
				'File already created in' = 'Red'
			}
		} else {
			(New-Item -ItemType File -Path $Path -Force)
		}
    } catch {
        Write-Error "An error occurred: $_"  | Out-HostColored @{
			'An error occurred:' = 'Red'
		}
    }
}