Configuration LAAgentDemo
{
    param (
        [String] $InstallerPath,
        [String] $ProductVersion
    )

    Import-DscResource -ModuleName OMSDsc -Name LAAgent
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LAAgent Install
    {
        InstallerPath = $InstallerPath
        ProductVersion = $ProductVersion
        Ensure = 'Present'
    }
}

LAAgentDemo -InstallerPath 'D:\OMSDsc\MMASetup-AMD64.exe' -ProductVersion '8.2.0.11409'