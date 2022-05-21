# -*-mode:powershell-*- vim:ft=powershell

# ~/.config/powershell/profile.ps1
# =============================================================================
# Executed when PowerShell starts.
#
# On Windows, this file will be copied over to these locations after
# running `chezmoi apply` by the script `../../run_powershell.bat.tmpl`:
#     - %USERPROFILE%\Documents\PowerShell
#     - %USERPROFILE%\Documents\WindowsPowerShell
#
# See https://docs.microsoft.com/en/powershell/module/microsoft.powershell.core/about/about_profiles

$ColorInfo = "DarkYellow"
$ColorWarn = "DarkRed"


# Imports
# -----------------------------------------------------------------------------

# Import popular commands from Linux.
if (Get-Command Import-WslCommand -errorAction Ignore) {
    $WslCommands = @(
        "chmod",
        "grep",
        "head",
        "less",
        "ls",
        "man",
        "ssh",
        "tail",
        "touch"
    )
    $WslImportedCommands = @()
    $WslDefaultParameterValues = @{
        grep = "-E";
        less = "-i";
        ls = "-AFhl --color=auto"
    }

    $WslCommands | ForEach-Object {
        if (! Get-Command $_ -errorAction Ignore) {
            wsl command -v $_ > null
            if ($?) {
                $WslImportedCommands += $_
                Import-WslCommand "$_"
            }
            else {
                $Global:Error.RemoveAt($Global:Error.Count - 1)
            }
        }
    }
}


# Includes
# -----------------------------------------------------------------------------

# Determine user profile parent directory.
$ProfilePath=Split-Path -parent $profile

# Load functions declarations from separate configuration file.
if (Test-Path $ProfilePath/functions.ps1) {
    . $ProfilePath/functions.ps1
}

# Add missing user paths.
if (Get-Command Add-EnvPath -errorAction Ignore) {
    if ($IsWindows) {
        Add-EnvPath -Path "${Env:Programfiles}\Docker\Docker\resources\bin\" -Position "Append"
        Add-EnvPath -Path "${Env:Programfiles}\Git\cmd\" -Position "Append"
    }
    else {
        Add-EnvPath -Path "/usr/local/sbin" -Position "Prepend"
        Add-EnvPath -Path "/usr/local/bin" -Position "Prepend"
    }
}

# Load alias definitions from separate configuration file.
if (Test-Path $ProfilePath/aliases.ps1) {
    . $ProfilePath/aliases.ps1
}

# Load custom code from separate configuration file.
if (Test-Path $ProfilePath/extras.ps1) {
    . $ProfilePath/extras.ps1
}


# Varia
# -----------------------------------------------------------------------------

# Point ripgrep to its configuration file.
# See https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
$Env:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"


# Finalization
# -----------------------------------------------------------------------------



# Display if/which WSL Interop commands are imported.
if ($WslImportedCommands) {
    Write-Host "Windows Subsystem for Linux (WSL) Interop enabled." -ForegroundColor $ColorInfo
    Write-Host "WSL commands available:`n`t$($WslImportedCommands | sort)" -ForegroundColor $ColorInfo
}