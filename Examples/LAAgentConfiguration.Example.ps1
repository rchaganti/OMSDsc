Configuration LAAgentDemo
{
    Import-DscResource -ModuleName OMSDsc -Name LAAgentConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LAAgentConfiguration LAAConfiguration
    {
        SingleInstance ='Yes'
        LocalCollectionEnabled = $true
        ActiveDirectoryIntegrationEnabled = $false
    }
}

LAAgentDemo