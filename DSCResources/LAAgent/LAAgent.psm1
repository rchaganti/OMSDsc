#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'OMSDsc.Helper' `
                                                     -ChildPath 'OMSDsc.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -filename LAAgent.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -filename LAAgent.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Gets the current state of the LAAgent resource.

.DESCRIPTION
Gets the current state of the LAAgent resource.

.PARAMETER InstallerPath
Specifies the path to the Microsoft Monitoring agent installer.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $InstallerPath
    )

    if (-not (Test-Path -Path $InstallerPath))
    {
        throw $localizedData.InstallerNotFound
    }
    $configuration = @{
        InstallerPath = $InstallerPath
    }

    $laAgent = Get-LAAgent -Verbose
    if ($laAgent)
    {
        Write-Verbose -Message $localizedData.LAAgentInstalled
        $configuration.Add('ProductName', $laAgent.ProductName)
        $configuration.Add('ProductVersion', $laAgent.ProductVersion)
        $configuration.Add('ProductId',$laAgent.ProductId)
        $configuration.Add('Ensure','Present')
    }
    else
    {
        Write-Verbose -Message $localizedData.LAAgentNotInstalled
        $configuration.Add('Ensure','Absent')
    }

    return $configuration
}

<#
.SYNOPSIS
Sets the LAAgent resource to specified desired state.

.DESCRIPTION
Sets the LAAgent resource to specified desired state.

.PARAMETER InstallerPath
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER Ensure
Specifies if Microsoft Monitoring Agent should be installed or removed.
Valid values are Present and Absent. Default value is Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $InstallerPath,

        [Parameter()]
        [String] $ProductVersion,
        
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    $laAgent = Get-LAAgent -Verbose

    if ($laAgent)
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message $localizedData.RemovingLAAgent
            #Build the msiexec uninstall string and use start-process to remove the agent
            
            $msiExecArgs = "/x{$($laAgent.productId)} /qn /norestart"
            $unInstallProcess = Start-Process -FilePath msiexec.exe -Argumentlist $msiExecArgs -Wait -Passthru -Verbose
            if ($unInstallProcess.HasExited)
            {
                if ($unInstallProcess.ExitCode -eq 0)
                {
                    Write-Verbose -Message $localizedData.UninstallComplete
                }
                else
                {
                    throw $localizedData.UninstallFailed
                }
            }
        }
        else
        {
            if ($ProductVersion)
            {
                if ([version]$ProductVersion -gt [version]$laAgent.ProductVersion)
                {
                    Write-Verbose -Message $localizedData.PerformUpgrade
                    $upgradeProcess = Start-Process -FilePath $InstallerPath -Argumentlist '/q:a /r:n /C:"setup.exe /qn AcceptEndUserLicenseAgreement=1"' -Wait -Passthru -Verbose
                    if ($upgradeProcess.HasExited)
                    {
                        Write-Verbose -Message $localizedData.UpgradeExited    

                        if ($upgradeProcess.ExitCode -eq 0)
                        {
                            Write-Verbose -Message $localizedData.UpgradeComplete
                        }
                        elseif ($upgradeProcess.ExitCode -eq 3010)
                        {
                            Write-Verbose -Message $localizedData.UpgradeNeedsReboot
                            $global:DSCMachineStatus = 1
                        }
                        else
                        {
                            throw $localizedData.UpgradeFailed
                        }
                    }                    
                }
            }
        }
    }
    else
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.InstallingLAAgent
            $installProcess = Start-Process -FilePath $InstallerPath -Argumentlist '/C:"setup.exe /qn AcceptEndUserLicenseAgreement=1"' -Wait -Passthru -Verbose
            if ($installProcess.HasExited)
            {
                Write-Verbose -Message $localizedData.InstallExited    

                if ($installProcess.ExitCode -ne 0)
                {
                    throw $localizedData.InstallFailed
                }
                else
                {
                    Write-Verbose -Message $localizedData.InstallComplete
                }
            }            
        }
    }
}

<#
.SYNOPSIS
Test if the LAAgent resource is in desired state.

.DESCRIPTION
test if the LAAgent resource is in desired state.

.PARAMETER InstallerPath
Specifies the path to the Microsoft Monitoring agent installer.

.PARAMETER Ensure
Specifies if Microsoft Monitoring Agent should be installed or removed.
Valid values are Present and Absent. Default value is Present.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $InstallerPath,

        [Parameter()]
        [String] $ProductVersion,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    $laAgent = Get-LAAgent -Verbose

    if ($laAgent)
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message $localizedData.RemoveLAAgent
            return $false
        }
        else
        {
            if ($ProductVersion)
            {
                if ([version]$ProductVersion -gt [version]$laAgent.ProductVersion)
                {
                    Write-Verbose -Message $localizedData.UpgradeNeeded
                    return $false
                }
            }
            
            #We just return $true otherwise.
            Write-Verbose -Message $localizedData.LAAgentPresentNoAction
            return $true
        }
    }
    else
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message $localizedData.InstallLAAgent
            return $false
        }
        else
        {
            Write-Verbose -Message $localizedData.LAAgentNotPresentNoAction
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
