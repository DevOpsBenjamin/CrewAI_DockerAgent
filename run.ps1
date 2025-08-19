# Remove container if exists
if (docker ps -a --format '{{.Names}}' | Select-String '^crewai-run$') {
    docker rm -f crewai-run
}


# run.ps1  (PowerShell 5.1 compatible)
$ErrorActionPreference = 'Stop'

# Resolve to this script's directory (so it's path-stable)
$root = $PSScriptRoot
if (-not $root) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }

# Host paths
$volumes = Join-Path $root 'volumes'
$vshome  = Join-Path $root 'vscode'
$sshDir  = Join-Path $root '.ssh'
$envFile = Join-Path $root '.env'

# Ensure dirs exist
New-Item -ItemType Directory -Force -Path $volumes, $vshome, $sshDir | Out-Null

# Absolute paths for Docker
$volumesAbs = (Resolve-Path $volumes).Path
$vshomeAbs  = (Resolve-Path $vshome).Path
$sshAbs     = (Resolve-Path $sshDir).Path
$envAbs 	= (Resolve-Path $envFile).Path

# Build args (splat avoids fragile line continuations/quoting)
$dockerArgs = @(
  'run','-d',
  '-p','8080:8080',
  '--env-file', $envAbs,
  '-v', "$($volumesAbs):/workspace",
  '-v', "$($vshomeAbs):/home/vscode",
  '-v', "$($sshAbs):/home/vscode/.ssh:ro",
  '--name','crewai-run',
  'crewai-ubuntu'
)

# Uncomment to debug:
# $dockerArgs | ForEach-Object { Write-Host "`t$_" }

docker @dockerArgs