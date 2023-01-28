. $PSScriptRoot/utilities.ps1

class Builder
{
    [String]$TargetPlatform
    [String]$TargetArch
    [String]$TargetConfig
    [String]$TargetGenerator

    [String]$TargetTriplet
    [String]$RootDir
    [String]$BuildDir
    [String[]]$BuildParams

    [Boolean]$MultiConfig
    [Switch]$BuildPython = $False
    [Switch]$BuildDotnet = $False
    [Switch]$BuildJava = $False
    
    # Constructor
    Builder([String]$Platform, [String]$Arch, [String]$Config, [string]$Generator)
    {
        $this.TargetPlatform = $Platform.ToString().ToLower()
        $this.TargetArch = $Arch.ToString().ToLower()
        $this.TargetConfig = $Config
        $this.TargetGenerator = $Generator

        $this.MultiConfig = $False
        $this.RootDir = Resolve-Path "$PSScriptRoot/.."
        if ($this.TargetArch -eq ""){ $this.TargetArch = GetHostArch }
    }

    [void] PrepareBuildSetings()
    {
        $Arch = $this.TargetArch
        $Platform = $this.TargetPlatform
        $Triplet = "$Arch-$Platform"
        $this.TargetTriplet = $Triplet

        $Config = $this.TargetConfig
        $Root = $this.RootDir
        $this.BuildDir = "$Root/build/$Triplet"
    
        $this.BuildParams = @("-S", $this.RootDir, "-B", $this.BuildDir)
        if ($this.BuildPython) {$this.BuildParams += "-DBUILD_PYTHON=ON"}
        if ($this.BuildDotnet) {$this.BuildParams += "-DBUILD_DOTNET=ON"}
        if ($this.BuildJava) {$this.BuildParams += "-DBUILD_JAVA=ON"}

        $vcpkgToolChainFile = "$Root/vcpkg/scripts/buildsystems/vcpkg.cmake"
        $this.BuildParams += @("-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolChainFile")
    }

    [void] SetupBuild()
    {  
        # Start building section
        Write-Host "Setting up dependencies for $($this.TargetTriplet)"
        $vcpkgScript = Join-Path $this.RootDir "scripts/vcpkg.ps1"
        . $vcpkgScript -TargetTriplet $this.TargetTriplet

        $Triplet = $this.TargetTriplet
        Write-Host "Setting up build for $Triplet ..."
        Write-Host "cmake $($this.BuildParams)"
        & cmake $this.BuildParams | Write-Host
    }

    [void] Build()
    {  
        # Start building section
        if ($this.MultiConfig){
            $Config = $this.TargetConfig
            if ($Config -eq "") { $Config = "Debug" }
            Write-Host "MultiConfig: cmake --build $($this.BuildDir) --config $Config"
            & cmake --build $this.BuildDir --config $Config | Write-Host
        }
        else{
            Write-Host "SingleConfig: cmake --build $($this.BuildDir)"
            & cmake --build $this.BuildDir | Write-Host
        }
    }
}

class LinuxBuilder : Builder
{   
    # Constructor
    LinuxBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("linux", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x64" -Or $Arch -ieq "arm64" -Or $Arch -ieq "arm")){
            throw "Invalid target architecture"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Unix Makefiles" -Or $Generator -eq "Ninja")){
            throw "invalid generator"
        }
    }

    [void] PrepareBuildSetings()
    {
        ([Builder]$this).PrepareBuildSetings()
    
        $Triplet = $this.TargetTriplet    
        $this.BuildParams +=@("-DVCPKG_TARGET_TRIPLET=$Triplet")            

        $Dir = $this.RootDir
        $Arch = $this.TargetArch
        $this.BuildParams +=@("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$Dir/cmake/toolchains/$Arch-linux-gnu.cmake")            

        if (-Not $this.TargetGenerator -eq "")
        {
            $this.BuildParams += @("-G", $this.TargetGenerator)
        }

        $Config = $this.TargetConfig
        if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_BUILD_TYPE=$Config") }
    }
}

class MacOSBuilder : Builder
{   
    # Constructor
    MacOSBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("osx", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x64" -Or $this.TargetArch -ieq "arm64")){
            throw "Invalid target architecture"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Xcode" -Or $Generator -eq "Ninja")){
            throw "invalid generator"
        }
    }

    [void] PrepareBuildSetings()
    {
        ([Builder]$this).PrepareBuildSetings()

        if ($this.TargetArch -ieq "x64"){ $this.BuildParams += @("-DCMAKE_OSX_ARCHITECTURES=x86_64") }
        if ($this.TargetArch -ieq "arm64"){ $this.BuildParams += @("-DCMAKE_OSX_ARCHITECTURES=arm64") }
        
        $Triplet = $this.TargetTriplet
        $this.BuildParams += @("-DVCPKG_TARGET_TRIPLET=$Triplet")

        $Generator = $this.TargetGenerator
        if ($Generator -eq ""){ $Generator = "Xcode" }
        $this.BuildParams += @("-G", $Generator)

        $Config = $this.TargetConfig
        
        if ($Generator -eq "Xcode"){
            $this.MultiConfig = $True
            if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_CONFIGURATION_TYPES=$Config") }   
        }
        else{
            if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_BUILD_TYPE=$Config") }    
        }
    }
}

class WindowsBuilder : Builder
{
    # Constructor
    WindowsBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("windows", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x64" -Or $Arch -ieq "x86" -Or $Arch -ieq "arm" -Or $Arch -ieq "arm64")){
            throw "Invalid target architecture"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Visual Studio 16 2019" -Or $Generator -eq "Visual Studio 17 2022" -Or $Generator -eq "Ninja")){
            throw "Invalid Generator"
        }
    }

    [void] PrepareBuildSetings()
    {
        ([Builder]$this).PrepareBuildSetings()

        $Arch = $this.TargetArch
        if ($Arch -ieq "x86"){ $Arch = "Win32" }

        $Config = $this.TargetConfig
        $Generator = $this.TargetGenerator
        if($Generator -eq ""){
            # Use default Visual Studio generator 
            $this.BuildParams += @("-DCMAKE_CONFIGURATION_TYPES=Debug;Release")
            $this.BuildParams += @("-A", $Arch)
            $this.MultiConfig = $True
        }
        else{
            $this.BuildParams += @("-G", $Generator)
            if ($Generator -ieq "Visual Studio 16 2019" -Or $Generator -ieq "Visual Studio 17 2022"){
                if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_CONFIGURATION_TYPES=Debug;Release") }
                $this.BuildParams += @("-A", $Arch)
                $this.MultiConfig = $True
            }
            else{
                $Triplet = $this.TargetTriplet
                $Root = $this.RootDir
                $this.BuildDir = "$Root/build/$Triplet"
                if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_BUILD_TYPE=$Config") }
            }
        } 
    }
}

class WasmBuilder : Builder
{   
    # Constructor
    WasmBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("wasm", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "wasm32")){
            throw "Invalid target architecture"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Unix Makefiles" -Or $Generator -eq "Ninja")){
            throw "invalid generator"
        }

        if ($Arch -eq ""){ $this.TargetArch = "wasm32" }
    }

    [void] PrepareBuildSetings()
    {
        $Triplet = "wasm32-emscripten"
        $this.TargetTriplet = $Triplet

        $Config = $this.TargetConfig
        $RootDir = $this.RootDir 
        $this.BuildDir = "$RootDir/build/$Triplet-$Config"

        $this.BuildParams = @("-S", ".", "-B", $this.BuildDir)

        $Triplet = $this.TargetTriplet    
        $this.BuildParams +=@("-DVCPKG_TARGET_TRIPLET=$Triplet")            

        $vcpkgToolChainFile = "$RootDir/vcpkg/scripts/buildsystems/vcpkg.cmake"
        $this.BuildParams += @("-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolChainFile")

        $EmsdkDir = $Env:EMSDK
        $this.BuildParams += @("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$EmsdkDir/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake")
        
        if (-Not $this.TargetGenerator -eq "")
        {
            $this.BuildParams += @("-G", $this.TargetGenerator)
        }

        $Config = $this.TargetConfig
        if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_BUILD_TYPE=$Config") }
    }
}

class AndroidBuilder : Builder
{   
    # Constructor
    AndroidBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("android", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x86" -Or $Arch -ieq "x64" -Or $Arch -ieq "arm" -Or $Arch -ieq "arm-neon" -Or $Arch -ieq "arm64")){
            throw "Invalid target architecture, valid values: x86, x64, arm, arm-neon, and arm64"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Unix Makefiles" -Or $Generator -eq "Ninja")){
            throw "invalid generator"
        }
    }

    [void] PrepareBuildSetings()
    {
        $Arch = $this.TargetArch
        $this.TargetTriplet = "$Arch-android"
        
        $Config = $this.TargetConfig
        $Root = $this.RootDir 
        $this.BuildDir = "$Root/build/$Arch-android-$Config"

        $this.BuildParams = @("-S", ".", "-B", $this.BuildDir)

        $Triplet = $this.TargetTriplet    
        $this.BuildParams +=@("-DVCPKG_TARGET_TRIPLET=$Triplet")            

        $abi = ""
        switch($Arch){
            "x64" { $abi = "x86_64" }
            "arm" { $abi = "armeabi-v7a" }
            "arm-neon" { $abi = "armeabi-v7a" }
            "arm64" { $abi = "arm64-v8a" }
            default { $abi = $this.TargetArch }
        }
        $this.BuildParams += @("-DANDROID_ABI=$abi")

        # For API level 23 and above, NEON is set to ON. 
        $this.BuildParams += @("-DANDROID_PLATFORM=23")
        if ($Arch -ieq "arm"){ $this.BuildParams += @("-DANDROID_ARM_NEON=OFF") }
        if ($Arch -ieq "arm-neon"){ $this.BuildParams += @("-DANDROID_ARM_NEON=ON") }

        $vcpkgToolChainFile = "$Root/vcpkg/scripts/buildsystems/vcpkg.cmake"
        $this.BuildParams += @("-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolChainFile")

        $ndkDir = $Env:ANDROID_NDK_HOME
        $this.BuildParams += @("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$ndkDir/build/cmake/android.toolchain.cmake")
        
        if (-Not $this.TargetGenerator -eq "")
        {
            $this.BuildParams += @("-G", $this.TargetGenerator)
        }

        $Config = $this.TargetConfig
        if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_BUILD_TYPE=$Config") }
    }
}

class IOSBuilder : Builder
{   
    # Constructor
    IOSBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("ios", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x86" -Or $Arch -ieq "x64" -Or $Arch -ieq "arm" -Or $Arch -ieq "arm64")){
            throw "Invalid target architecture, valid values: x86, x64, arm, and arm64"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Xcode")){
            throw "invalid generator"
        }

        $this.MultiConfig = $True
    }

    [void] PrepareBuildSetings()
    {
        $Arch = $this.TargetArch
        $this.TargetTriplet = "$Arch-ios"
        
        $Config = $this.TargetConfig
        $Root = $this.RootDir 
        $this.BuildDir = "$Root/build/$Arch-ios-$Config"

        $this.BuildParams = @("-S", ".", "-B", $this.BuildDir)

        $this.BuildParams +=@("-DVCPKG_TARGET_ARCHITECTURE=$Arch")            

        $Triplet = $this.TargetTriplet    
        $this.BuildParams +=@("-DVCPKG_TARGET_TRIPLET=$Triplet")            

        $vcpkgToolChainFile = "$Root/vcpkg/scripts/buildsystems/vcpkg.cmake"
        $this.BuildParams += @("-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolChainFile")
        $this.BuildParams += @("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$Root/vcpkg/scripts/toolchains/ios.cmake")
        
        $Generator = $this.TargetGenerator  
        if ($Generator -eq ""){ $Generator = "Xcode" }
        $this.BuildParams += @("-G", $Generator)

        $Config = $this.TargetConfig
        if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_CONFIGURATION_TYPES=$Config") }

        # Set min version of targeted platform
        $this.BuildParams += "-DCMAKE_OSX_DEPLOYMENT_TARGET=9"
    }
}

class IOSSimBuilder : Builder
{   
    # Constructor
    IOSSimBuilder([String]$Arch, [String]$Config, [String]$Generator) : base("ios", $Arch, $Config, $Generator)
    {
        if (-Not ($Arch -eq "" -Or $Arch -ieq "x64" -Or $Arch -ieq "arm64")){
            throw "Invalid target architecture, valid values: x64, and arm64"
        }

        if (-Not ($Generator -eq "" -Or $Generator -eq "Xcode")){
            throw "invalid generator"
        }

        $this.MultiConfig = $True
    }

    [void] PrepareBuildSetings()
    {
        $Arch = $this.TargetArch
        $this.TargetTriplet = "$Arch-ios-sim"
        
        $Config = $this.TargetConfig
        $Root = $this.RootDir 
        $this.BuildDir = "$Root/build/$Arch-ios-sim-$Config"

        $this.BuildParams = @("-S", ".", "-B", $this.BuildDir)

        $this.BuildParams +=@("-DVCPKG_TARGET_ARCHITECTURE=$Arch")            

        $Triplet = $this.TargetTriplet    
        $this.BuildParams +=@("-DVCPKG_TARGET_TRIPLET=$Triplet")            

        $vcpkgToolChainFile = "$Root/vcpkg/scripts/buildsystems/vcpkg.cmake"
        $this.BuildParams += @("-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolChainFile")
        $this.BuildParams += @("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$Root/vcpkg/scripts/toolchains/ios.cmake")
        $this.BuildParams += @("-DCMAKE_OSX_SYSROOT=iphonesimulator")
        
        $Generator = $this.TargetGenerator  
        if ($Generator -eq ""){ $Generator = "Xcode" }
        $this.BuildParams += @("-G", $Generator)

        $Config = $this.TargetConfig
        if (-Not $Config -eq ""){ $this.BuildParams += @("-DCMAKE_CONFIGURATION_TYPES=$Config") }

        # Set min version of targeted platform
        $this.BuildParams += "-DCMAKE_OSX_DEPLOYMENT_TARGET=9"
    }
}