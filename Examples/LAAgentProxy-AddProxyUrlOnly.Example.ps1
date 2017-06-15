Configuration LAAgentDemo
{        
    param (
        [String] $ProxyUrl
    )
    Import-DscResource -ModuleName OMSDsc -Name LAAgentProxy
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LAAgentProxy Proxy
    {
        ProxyUrl = $ProxyURL
        Ensure = 'Present'
    }
}

LAAgentDemo -ProxyUrl 'proxy.mydomain.in:3128'