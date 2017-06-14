#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'OMSDsc.Helper' `
                                                     -ChildPath 'OMSDsc.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentConfiguration.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentConfiguration.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Gets the current state of the LAAgentConfiguration resource.

.DESCRIPTION
Gets the current state of the LAAgentConfiguration resource.

.PARAMETER SingleInstance
Specifies that this resource is a single instance resource.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [String] $SingleInstance
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose

    if ($laAgentComObject)
    {
        $configuration = @{
            SingleInstance = $SingleInstance
            ActiveDirectoryIntegrationEnabled = $laAgentComObject.ActiveDirectoryIntegrationEnabled
            LocalCollectionEnabled = $laAgentComObject.LocalCollectionEnabled
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
Sets the LAAgentConfiguration resource to specified desired state.

.DESCRIPTION
Sets the LAAgentConfiguration resource to specified desired state.

.PARAMETER SingleInstance
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER ActiveDirectoryIntegrationEnabled
Specifies if the AD integration is enabled or not. This is a Boolean property.
Defualt value is $true.

.PARAMETER LocalCollectionEnabled
Specifies if local collection is enabled or not. This is a Boolean property.
Defualt value is $false.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [String] $SingleInstance,

        [Parameter()]
        [Boolean] $LocalCollectionEnabled = $false,

        [Parameter()]
        [Boolean] $ActiveDirectoryIntegrationEnabled = $true
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        Write-Verbose -Message $localizedData.CheckLAAgentConfiguration
        if ($laAgentComObject.LocalCollectionEnabled -ne $LocalCollectionEnabled)
        {
            Write-Verbose -Message $localizedData.UpdateLocalCollection
            switch ($LocalCollectionEnabled)
            {
                $true {
                    Write-Verbose -Message $localizedData.EnableLocalCollection
                    $laAgentComObject.EnableLocalCollection()
                }

                $false {
                    Write-Verbose -Message $localizedData.DisableLocalCollection
                    $laAgentComObject.DisableLocalCollection()
                }
            }
        }

        if ($laAgentComObject.ActiveDirectoryIntegrationEnabled -ne $ActiveDirectoryIntegrationEnabled)
        {
            Write-Verbose -Message $localizedData.UpdateADIntegration
            switch ($ActiveDirectoryIntegrationEnabled)
            {
                $true {
                    Write-Verbose -Message $localizedData.EnableADIntegration
                    $laAgentComObject.EnableActiveDirectoryIntegration()
                }

                $false {
                    Write-Verbose -Message $localizedData.DisableADIntegration
                    $laAgentComObject.DisableActiveDirectoryIntegration()
                }
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
Test if the LAAgentConfiguration resource is in desired state.

.DESCRIPTION
test if the LAAgentConfiguration resource is in desired state.

.PARAMETER SingleInstance
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER ActiveDirectoryIntegrationEnabled
Specifies if the AD integration is enabled or not. This is a Boolean property.
Defualt value is $true.

.PARAMETER LocalCollectionEnabled
Specifies if local collection is enabled or not. This is a Boolean property.
Defualt value is $false.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [String] $SingleInstance,

        [Parameter()]
        [Boolean] $LocalCollectionEnabled = $false,

        [Parameter()]
        [Boolean] $ActiveDirectoryIntegrationEnabled = $true
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        Write-Verbose -Message $localizedData.CheckLAAgentConfiguration
        if ($laAgentComObject.LocalCollectionEnabled -ne $LocalCollectionEnabled)
        {
            Write-Verbose -Message $localizedData.UpdateLocalCollection
            return $false
        }

        if ($laAgentComObject.ActiveDirectoryIntegrationEnabled -ne $ActiveDirectoryIntegrationEnabled)
        {
            Write-Verbose -Message $localizedData.UpdateADIntegration
            return $false    
        }

        Write-Verbose -Message $localizedData.ConfigurationExistsAsSpecified
        return $true
    }
    else
    {
        throw $localizedData.NoLAAgentComObject
    }  
}

Export-ModuleMember -Function *-TargetResource
