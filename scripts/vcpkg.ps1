param(
    [String]$TargetTriplet = ""
)
. $PSScriptRoot/utilities.ps1

$RootDir = Resolve-Path $PSScriptRoot/..

Push-Location $RootDir/vcpkg

# $IsLinux or $IsMacOS is available when $PSVersionTable.PSVersion.Major -ge 6
if ($IsLinux){
    # On a Linux host
    if (-Not (Test-Path -Path "$RootDir/vcpkg/vcpkg")){
        & ./bootstrap-vcpkg.sh
        & ./vcpkg integrate install
    }
}
elseif ($IsMacOS){
    # On a MacOS host
    if (-Not (Test-Path -Path "$RootDir/vcpkg/vcpkg")){
        & ./bootstrap-vcpkg.sh --allowAppleClang
        & ./vcpkg integrate install
    }
}
else{
    # On a Windows host
    if (-Not (Test-Path -Path "$RootDir/vcpkg/vcpkg.exe")){
        & .\bootstrap-vcpkg.bat
        & .\vcpkg.exe integrate install
    }
}

if ($TargetTriplet -eq ""){
    $TargetPlatform = GetHostOS
    $TargetArch = GetHostArch
    $TargetTriplet = "$TargetArch-$TargetPlatform"
}

Write-Host "Installing vcpkg components for $TargetTriplet"

& ./vcpkg install gtest:$TargetTriplet | Write-Host

Pop-Location