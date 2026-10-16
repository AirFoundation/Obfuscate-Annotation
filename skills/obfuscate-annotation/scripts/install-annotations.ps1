<#
.SYNOPSIS
    Integrates AirFoundation/Obfuscate-Annotation library into a target Java/Kotlin project.
.PARAMETER TargetProjectDir
    Path to the target project directory. Defaults to current working directory.
.PARAMETER Mode
    Integration mode:
      - 'auto' (default: inspects project and determines best strategy)
      - 'gradle-module' (adds as a standalone Gradle subproject)
      - 'maven-source' (copies source directly into src/main/java)
      - 'maven-jar' (compiles to libs/obfuscate-annotations.jar)
      - 'maven-module' (creates a Maven sub-module)
      - 'ide-source' (drops source directly into project src)
      - 'ide-jar' (compiles into libs/obfuscate-annotations.jar)
.PARAMETER ModuleName
    Name of the sub-module when using gradle-module or maven-module. Default: 'obfuscate-annotations'
.PARAMETER TargetModule
    Target subproject to add the dependency to (optional, e.g. 'app' or 'core').
#>
[CmdletBinding()]
param (
    [string]$TargetProjectDir = ".",
    [ValidateSet('auto', 'gradle-module', 'maven-source', 'maven-jar', 'maven-module', 'ide-source', 'ide-jar')]
    [string]$Mode = "auto",
    [string]$ModuleName = "obfuscate-annotations",
    [string]$TargetModule = ""
)

$targetDir = [System.IO.Path]::GetFullPath($TargetProjectDir)
if (-not (Test-Path $targetDir)) {
    Write-Error "Target project directory does not exist: $targetDir"
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$skillDir = Split-Path -Parent $scriptDir
$sourceDir = Join-Path $skillDir "resources\src"
$buildJarScript = Join-Path $scriptDir "build-jar.ps1"

Write-Host "=========================================================="
Write-Host "  AirFoundation/Obfuscate-Annotation Installer"
Write-Host "  Target: $targetDir"
Write-Host "=========================================================="

# 1. Project Type Detection if Mode is 'auto'
$isGradle = (Test-Path (Join-Path $targetDir "build.gradle")) -or `
            (Test-Path (Join-Path $targetDir "build.gradle.kts")) -or `
            (Test-Path (Join-Path $targetDir "settings.gradle")) -or `
            (Test-Path (Join-Path $targetDir "settings.gradle.kts"))

$isMaven = (Test-Path (Join-Path $targetDir "pom.xml"))

if ($Mode -eq "auto") {
    if ($isGradle) {
        Write-Host "[i] Detected Gradle build system."
        $Mode = "gradle-module"
    } elseif ($isMaven) {
        Write-Host "[i] Detected Maven build system."
        # Default recommendation for Maven is source injection or JAR
        $Mode = "maven-source"
    } else {
        Write-Host "[i] Detected IDE / Direct Management project."
        $Mode = "ide-source"
    }
}

Write-Host "[*] Selected Integration Mode: $Mode"

# Helper to copy package
function Copy-AnnotationSource([string]$destDir) {
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    $sourceTech = Join-Path $sourceDir "tech"
    $destTech = Join-Path $destDir "tech"
    Copy-Item -Recurse -Force $sourceTech $destDir
    Write-Host "[+] Copied annotation source files to: $destTech"
}

switch ($Mode) {
    "gradle-module" {
        $modulePath = Join-Path $targetDir $ModuleName
        $moduleSrc = Join-Path $modulePath "src\main\java"
        Copy-AnnotationSource $moduleSrc

        $isKts = (Test-Path (Join-Path $targetDir "settings.gradle.kts")) -or `
                 (Test-Path (Join-Path $targetDir "build.gradle.kts"))

        if ($isKts) {
            $gradleBuildFile = Join-Path $modulePath "build.gradle.kts"
            $buildContent = @"
plugins {
    `java-library`
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}
"@
            [System.IO.File]::WriteAllText($gradleBuildFile, $buildContent, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host "[+] Created: $gradleBuildFile"

            # Update settings.gradle.kts
            $settingsKts = Join-Path $targetDir "settings.gradle.kts"
            if (Test-Path $settingsKts) {
                $settingsContent = Get-Content $settingsKts -Raw -ErrorAction SilentlyContinue
                if ($settingsContent -notmatch [regex]::Escape($ModuleName)) {
                    Add-Content -Path $settingsKts -Value "`ninclude(`"$ModuleName`")"
                    Write-Host "[+] Registered :$ModuleName in settings.gradle.kts"
                }
            }
        } else {
            $gradleBuildFile = Join-Path $modulePath "build.gradle"
            $buildContent = @"
plugins {
    id 'java-library'
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}
"@
            [System.IO.File]::WriteAllText($gradleBuildFile, $buildContent, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host "[+] Created: $gradleBuildFile"

            # Update settings.gradle
            $settingsFile = Join-Path $targetDir "settings.gradle"
            if (Test-Path $settingsFile) {
                $settingsContent = Get-Content $settingsFile -Raw -ErrorAction SilentlyContinue
                if ($settingsContent -notmatch [regex]::Escape($ModuleName)) {
                    Add-Content -Path $settingsFile -Value "`ninclude ':$ModuleName'"
                    Write-Host "[+] Registered :$ModuleName in settings.gradle"
                }
            }
        }

        Write-Host "`n----------------------------------------------------------"
        Write-Host " [Next Step] Add dependency to your application module:"
        Write-Host " In your build.gradle / build.gradle.kts (e.g. app or core):"
        if ($isKts) {
            Write-Host "   dependencies {"
            Write-Host "       compileOnly(project(`":$ModuleName`"))"
            Write-Host "   }"
        } else {
            Write-Host "   dependencies {"
            Write-Host "       compileOnly project(':$ModuleName')"
            Write-Host "   }"
        }
        Write-Host "----------------------------------------------------------"
    }

    "maven-source" {
        $mavenSrc = Join-Path $targetDir "src\main\java"
        if (-not (Test-Path $mavenSrc)) {
            New-Item -ItemType Directory -Force -Path $mavenSrc | Out-Null
        }
        Copy-AnnotationSource $mavenSrc
        Write-Host "[+] Successfully injected source into Maven project: $mavenSrc\tech"
    }

    "maven-jar" {
        $libsDir = Join-Path $targetDir "libs"
        if (-not (Test-Path $libsDir)) {
            New-Item -ItemType Directory -Force -Path $libsDir | Out-Null
        }
        $jarPath = Join-Path $libsDir "obfuscate-annotations.jar"
        & powershell -File $buildJarScript -OutputJar $jarPath -SourceDir $sourceDir
        Write-Host "[+] Compiled JAR placed at: $jarPath"
        Write-Host "`n----------------------------------------------------------"
        Write-Host " [Next Step] Add the local JAR to your pom.xml:"
        Write-Host @"
<dependency>
    <groupId>tech.AirFoundation</groupId>
    <artifactId>obfuscate-annotations</artifactId>
    <version>1.0.0</version>
    <scope>system</scope>
    <systemPath>`${project.basedir}/libs/obfuscate-annotations.jar</systemPath>
</dependency>
"@
        Write-Host "----------------------------------------------------------"
    }

    "ide-source" {
        $destSrc = ""
        if (Test-Path (Join-Path $targetDir "src\main\java")) {
            $destSrc = Join-Path $targetDir "src\main\java"
        } elseif (Test-Path (Join-Path $targetDir "src")) {
            $destSrc = Join-Path $targetDir "src"
        } else {
            $destSrc = Join-Path $targetDir "src"
            New-Item -ItemType Directory -Force -Path $destSrc | Out-Null
        }
        Copy-AnnotationSource $destSrc
        Write-Host "[+] Successfully injected annotations into source folder: $destSrc\tech"
    }

    "ide-jar" {
        $libsDir = Join-Path $targetDir "libs"
        if (-not (Test-Path $libsDir)) {
            New-Item -ItemType Directory -Force -Path $libsDir | Out-Null
        }
        $jarPath = Join-Path $libsDir "obfuscate-annotations.jar"
        & powershell -File $buildJarScript -OutputJar $jarPath -SourceDir $sourceDir
        Write-Host "[+] Compiled JAR placed at: $jarPath"
        Write-Host " [Next Step] Add $jarPath to your IDE project Libraries / Classpath."
    }
}

Write-Host "[+] Installation complete!"