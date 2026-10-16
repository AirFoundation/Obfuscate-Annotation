<#
.SYNOPSIS
    Compiles AirFoundation/Obfuscate-Annotation into a standalone JAR.
.PARAMETER OutputJar
    Path where the output JAR will be saved. Default: .\obfuscate-annotations.jar
.PARAMETER JavaTarget
    Target Java bytecode version (default: 8 for maximum backwards compatibility).
.PARAMETER SourceDir
    Source directory containing the tech/AirFoundation/... package structure.
#>
[CmdletBinding()]
param (
    [string]$OutputJar = "obfuscate-annotations.jar",
    [string]$JavaTarget = "8",
    [string]$SourceDir = ""
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $SourceDir) {
    $SourceDir = Join-Path (Split-Path -Parent $scriptDir) "resources\src"
}

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

$tempClasses = Join-Path $env:TEMP ("obf-build-" + [System.Guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Force -Path $tempClasses | Out-Null
    
    $javaFiles = @(Get-ChildItem -Path $SourceDir -Recurse -Filter "*.java" | Select-Object -ExpandProperty FullName)
    if ($javaFiles.Count -eq 0) {
        Write-Error "No Java source files found in: $SourceDir"
        exit 1
    }

    Write-Host "[*] Compiling $($javaFiles.Count) annotation classes with Java target $JavaTarget..."
    $argList = @("--release", $JavaTarget, "-encoding", "UTF-8", "-d", $tempClasses) + $javaFiles
    $proc = Start-Process -FilePath "javac" -ArgumentList $argList -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "javac compilation failed with exit code $($proc.ExitCode)"
        exit 1
    }

    $outFull = [System.IO.Path]::GetFullPath($OutputJar)
    $outDir = Split-Path -Parent $outFull
    if ($outDir -and -not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    }

    Write-Host "[*] Packaging into $outFull..."
    $jarProc = Start-Process -FilePath "jar" -ArgumentList @("cf", $outFull, "-C", $tempClasses, ".") -NoNewWindow -Wait -PassThru
    if ($jarProc.ExitCode -ne 0) {
        Write-Error "jar command failed with exit code $($jarProc.ExitCode)"
        exit 1
    }

    Write-Host "[+] Successfully generated: $outFull"
}
finally {
    if (Test-Path $tempClasses) {
        Remove-Item -Recurse -Force $tempClasses -ErrorAction SilentlyContinue
    }
}