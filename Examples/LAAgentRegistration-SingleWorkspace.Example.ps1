Configuration LAAgentDemo
{
    param (
        [String] $Wkp1Id,
        [String] $Wkp1Key,
        [String] $Wkp1CloudType
    )

    Import-DscResource -ModuleName OMSDsc -Name LAAgentRegistration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LAAgentRegistration WKP1Registration
    {
        WorkspaceId = $Wkp1Id
        WorkspaceKey = $Wkp1Key
        AzureCloudType = $Wkp1CloudType
        Ensure = 'Present'
    }
}

LAAgentDemo -Wkp1ID 'WKP-Id' -Wkp1Key 'WKP-Key' -Wkp1CloudType 'AzureCommercial'