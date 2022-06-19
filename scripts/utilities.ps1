function GetArch
{
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Arch)
    
    if ($Arch -ieq "x86_64"){ return "x64" }
    if ($Arch -ieq "amd64"){ return "x64" }
    if ($Arch -ieq "i386"){ return "x86" }
    if ($Arch -ieq "aarch"){ return "arm64" }
    if ($Arch -ieq "arm"){ return "arm" }
    if ($Arch -ieq "armhf"){ return "arm" }

    return $Arch;
}

function GetHostArch
{
    # $IsLinux or $IsMacOS is available when $PSVersionTable.PSVersion.Major -ge 6
    if ($IsLinux){
        # On a Linux host
        $HostArch = GetArch (& uname -m)
    }
    elseif ($IsMacOS){
        # On a MacOS host
        $HostArch = GetArch (& uname -m)
    }
    else{
        # On a Windows host
        $HostArch = GetArch $Env:PROCESSOR_ARCHITECTURE
    }

    return $HostArch;
}

function GetHostOS
{
    # $IsLinux or $IsMacOS is available when $PSVersionTable.PSVersion.Major -ge 6
    if ($IsLinux){ return "linux" }
    if ($IsMacOS){ return "osx" }
    return "windows"
}
