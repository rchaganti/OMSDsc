$configData = 
@{
    AllNodes = 
    @(
        @{
            NodeName = 'localhost'
            PsDscAllowPlainTextPassword = $true
        }
    )  
}

Configuration LAAgentDemo
{        
    param (
        [String] $ProxyUrl,
        [pscredential] $ProxyCredential
    )
    Import-DscResource -ModuleName OMSDsc -Name LAAgentProxy
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName
    {
        LAAgentProxy Proxy
        {
            ProxyUrl = $ProxyURL
            ProxyCredential = $ProxyCredential
            Force = $true
            Ensure = 'Present'
        }
    }
}

LAAgentDemo -ProxyUrl 'proxy.mydomain.in:3128' -ProxyCredential (Get-Credential) -ConfigurationData $ConfigData