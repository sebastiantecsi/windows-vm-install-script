if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
   $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
   Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
   Exit
  }
 }

$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$Packages = Join-Path -Path $ScriptDir -ChildPath "packages.config"
$ChocoInstalled = $false
if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
  Write-Host "Chocolatey is Installed"
  $ChocoInstalled = $true
  Write-Host
}

if (-Not ($ChocoInstalled)) {
  Write-Host "Installing Chocolatey"
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Write-Host
}

Write-Host "Installing Windows Packages"
cinst $Packages -y

refreshenv

Write-Host "Installing Visual Studio Code Extensions"
code --install-extension fbosch.addition-extension-pack

refreshenv

Write-Host "Installing Global Node Packages"
npm install -g yarn

refreshenv

Write-Host "Development Dependencies Installed"
