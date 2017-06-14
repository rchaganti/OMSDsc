Configuration LAAgentDemo
{
    param (
        [String] $Wkp1Id,
        [String] $Wkp1Key,
        [String] $Wkp1CloudType,
        [String] $Wkp2Id,
        [String] $Wkp2Key,
        [String] $Wkp2CloudType        
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

    LAAgentRegistration WKP2Registration
    {
        WorkspaceId = $Wkp2Id
        WorkspaceKey = $Wkp2Key
        AzureCloudType = $Wkp2CloudType
        Ensure = 'Present'
    }    
}

LAAgentDemo -Wkp1ID 'WKP1-Id' -Wkp1Key 'WKP1-Key' -Wkp1CloudType 'AzureCommercial' `
            -Wkp1ID 'WKP2-Id' -Wkp1Key 'WKP2-Key' -Wkp2CloudType 'AzureCommercial'
