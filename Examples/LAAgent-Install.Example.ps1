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
        Ensure = 'Present'
    }
}

LAAgentDemo -InstallerPath 'D:\OMSDsc\MMASetup-AMD64.exe'