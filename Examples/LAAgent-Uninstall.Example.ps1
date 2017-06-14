Configuration LAAgentDemo
{
    param (
        [String] $InstallerPath
    )

    Import-DscResource -ModuleName OMSDsc -Name LAAgent
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LAAgent Install
    {
        InstallerPath = $InstallerPath
        Ensure = 'Absent'
    }
}

LAAgentDemo -InstallerPath 'D:\OMSDsc\MMASetup-AMD64.exe'