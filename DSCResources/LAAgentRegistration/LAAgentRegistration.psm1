#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'OMSDsc.Helper' `
                                                     -ChildPath 'OMSDsc.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentRegistration.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentRegistration.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Gets the current state of the LAAgentRegistration resource.

.DESCRIPTION
Gets the current state of the LAAgentRegistration resource.

.PARAMETER WorkspaceId
Specifies the Workspace ID of the OMS workspace.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $WorkspaceId
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose

    if ($laAgentComObject)
    {
        $configuration = @{
            WorkspaceId = $WorkspaceId
        }
        
        $workspace = $laAgentComObject.GetCloudWorkspace($workspaceId)
        if ($workspace)
        {
            $configuration.Add('AzureCloudType', [AzureCloudType]$workspace.AzureCloudType)
            $configuration.Add('ConnectionStatus', $workspace.ConnectionStatus)
            $configuration.Add('ConnectionStatusText', $workspace.ConnectionStatusText)
            $configuration.Add('Ensure','Present')
        }
        else
        {
            $configuration.Add('Ensure','Absent')
        }
    }
    else
    {
        throw $localizedData.NoLAAgentComObject
    }
    
    return $configuration
}

<#
.SYNOPSIS
Sets the LAAgentRegistration resource to specified desired state.

.DESCRIPTION
Sets the LAAgentRegistration resource to specified desired state.

.PARAMETER WorkspaceId
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER WorkspaceKey
Specifies the workspace key for completing OMS registration.

.PARAMETER AzureCloudType
Specifies the type of Azure Cloud. Possible values are AzureCommercial and AzureGovernment.
Default value is AzureCommercial.

.PARAMETER Force
Specifies if the workspace key must be updated.

.PARAMETER Ensure
Specifies if OMS registration should be available or removed.
Valid values are Present and Absent. Default value is Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $WorkspaceId,

        [Parameter()]
        [String] $WorkspaceKey,
        
        [Parameter()]
        [ValidateSet('AzureCommercial','AzureGovernment')]
        [String] $AzureCloudType = 'AzureCommercial', 

        [Parameter()]
        [Boolean] $Force = $false,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    if (-not $WorkspaceKey)
    {
        throw $localizedData.WorkspaceKeyNotSupplied
    }

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        $workspace = $laAgentComObject.GetCloudWorkspace($workspaceId)
        if ($workspace)
        {
            if ($Ensure -eq 'Present')
            {
                #Check if Force is specified and update the workspacekey
                if ($Force)
                {
                    Write-Verbose -Message $localizedData.UpdateWorkspaceKey
                    $workspace.UpdateWorkspaceKey($WorkspaceKey)
                    $laAgentComObject.ReloadConfiguration()
                }
            }
            else
            {
                #Workspace registration should not exist
                Write-Verbose -Message $localizedData.RemovingWorkspace
                $laAgentComObject.RemoveCloudWorkspace($WorkspaceId)
                $laAgentComObject.ReloadConfiguration()                
            }
        }
        else
        {
            if ($Ensure -eq 'Present')
            {
                Write-Verbose -Message $localizedData.RegisterWorkspace
                $laAgentComObject.AddCloudWorkspace($WorkspaceId, $WorkspaceKey, [int]([AzureCloudType]$AzureCloudType))
                $laAgentComObject.ReloadConfiguration()
            }
        }
    }
    else
    {
        throw $localizedData.NoLAAgentComObject
    }
}

<#
.SYNOPSIS
Test if the LAAgentRegistration resource is in desired state.

.DESCRIPTION
test if the LAAgentRegistration resource is in desired state.

.PARAMETER WorkspaceId
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER WorkspaceKey
Specifies the workspace key for completing OMS registration.

.PARAMETER AzureCloudType
Specifies the type of Azure Cloud. Possible values are AzureCommercial and AzureGovernment.
Default value is AzureCommercial.

.PARAMETER Force
Specifies if the workspace key must be updated.

.PARAMETER Ensure
Specifies if OMS registration should be available or removed.
Valid values are Present and Absent. Default value is Present.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $WorkspaceId,

        [Parameter()]
        [String] $WorkspaceKey,
        
        [Parameter()]
        [ValidateSet('AzureCommercial','AzureGovernment')]
        [String] $AzureCloudType = 'AzureCommercial', 

        [Parameter()]
        [Boolean] $Force = $false,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        $workspace = $laAgentComObject.GetCloudWorkspace($workspaceId)
        if ($workspace)
        {
            if ($Ensure -eq 'Present')
            {
                #Check if Force is specified and update the workspacekey
                if ($Force)
                {
                    Write-Verbose -Message $localizedData.ShouldUpdateWorkspaceKey
                    return $false
                }
                else
                {
                    Write-Verbose -Message $localizedData.WorkspaceExistsNoAction
                    return $true
                }
            }
            else
            {
                #Workspace registration should not exist
                Write-Verbose -Message $localizedData.ShouldRemoveWorkspace 
                return $false                
            }
        }
        else
        {
            if ($Ensure -eq 'Present')
            {
                Write-Verbose -Message $localizedData.ShouldRegisterWorkspace
                return $false
            }
            else
            {
                Write-Verbose -Message $localizedData.NoWorkspaceNoAction
                return $true
            }
        }
    }
    else
    {
        throw $localizedData.NoLAAgentComObject
    }    
}

Export-ModuleMember -Function *-TargetResource
