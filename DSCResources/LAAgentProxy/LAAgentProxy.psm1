#region helper modules
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'OMSDsc.Helper' `
                                                     -ChildPath 'OMSDsc.Helper.psm1'))
#endregion

#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentProxy.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -filename LAAgentProxy.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
Gets the current state of the LAAgentProxy resource.

.DESCRIPTION
Gets the current state of the LAAgentProxy resource.

.PARAMETER ProxyUrl
Specifies the Proxy URL for OMS connectivity.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $ProxyUrl
    )

    $laAgentComObject = Get-LAAgentCOMObject -Verbose

    if ($laAgentComObject)
    {
        $configuration = @{
            ProxyUrl = $ProxyUrl
        } 

        if ($laAgentComObject.ProxyUrl -eq $ProxyUrl)
        {
            $configuration.Add('ProxyUserName',$laAgentComObject.ProxyUsername)
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
Sets the LAAgentProxy resource to specified desired state.

.DESCRIPTION
Sets the LAAgentProxy resource to specified desired state.

.PARAMETER ProxyUrl
Specifies the Proxy URL for OMS connectivity.

.PARAMETER ProxyCredential
Specifies the proxy credentials needed for OMS connectivity.

.PARAMETER Force
Specifies if the proxy credentials should be updated.

.PARAMETER Ensure
Specifies if proxy configuration for LA Agent should be Present or Absent.
Default is Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $ProxyUrl,

        [Parameter()]
        [pscredential] $proxyCredential,

        [Parameter()]
        [Boolean] $Force,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    if ($Force -and !$ProxyCredential)
    {
        throw $localizedData.ForceNeedsProxyCredentials
    }

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        if ($laAgentComObject.ProxyUrl)
        {
            if ($Ensure -eq 'Present')
            {
                if ($laAgentComObject.ProxyUrl -ne $ProxyUrl)
                {
                    Write-Verbose -Message $localizedData.UpdateProxyURL
                    $laAgentComObject.SetProxyUrl($ProxyUrl)
                }

                if ($ProxyCredential -and (-not ($laAgentComObject.proxyUsername)))
                {
                    Write-Verbose -Message $localizedData.AddProxyCredential
                    $laAgentComObject.SetProxyCredentials($ProxyCredential.UserName, $ProxyCredential.GetNetworkCredential().Password)
                }

                if ($ProxyCredential -and $Force)
                {
                    Write-Verbose -Message $localizedData.UpdatingProxyCredential
                    $laAgentComObject.SetProxyCredentials($ProxyCredential.UserName, $ProxyCredential.GetNetworkCredential().Password)                    
                }
            }
            else
            {
                Write-Verbose -Message $localizedData.RemovingProxy
                $laAgentComObject.SetProxyInfo('','','')
            }
        }
        else
        {
            if ($Ensure -eq 'Present')
            {
                Write-Verbose -Message $localizedData.AddingProxyConfiguration
                if ($ProxyCredential)
                {
                    $laAgentComObject.SetProxyInfo($ProxyUrl,$proxyCredential.UserName, $proxyCredential.GetNetworkCredential().Password)
                }
                else
                {
                    $laAgentComObject.SetProxyUrl($ProxyUrl)
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
Test if the LAAgentProxy resource is in desired state.

.DESCRIPTION
test if the LAAgentProxy resource is in desired state.

.PARAMETER ProxyUrl
Specifies the Proxy URL for OMS connectivity.

.PARAMETER ProxyCredential
Specifies the proxy credentials needed for OMS connectivity.

.PARAMETER Ensure
Specifies if proxy configuration for LA Agent should be Present or Absent.
Default is Present.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $ProxyUrl,

        [Parameter()]
        [pscredential] $proxyCredential,

        [Parameter()]
        [Boolean] $Force,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    if ($Force -and !$ProxyCredential)
    {
        throw $localizedData.ForceNeedsProxyCredentials
    }

    $laAgentComObject = Get-LAAgentCOMObject -Verbose
    if ($laAgentComObject)
    {   
        if ($laAgentComObject.ProxyUrl)
        {
            if ($Ensure -eq 'Present')
            {
                if ($laAgentComObject.ProxyUrl -ne $ProxyUrl)
                {
                    Write-Verbose -Message $localizedData.UpdateProxyURL
                    return $false
                }

                if ($ProxyCredential -and $Force)
                {
                    Write-Verbose -Message $localizedData.UpdateProxyCredential
                    return $false
                }

                Write-Verbose -Message $localizedData.ProxyNeedsNoUpdate
                return $true
            }
            else
            {
                Write-Verbose -Message $localizedData.RemoveProxy
                return $false
            }
        }
        else
        {
            if ($Ensure -eq 'Present')
            {
                Write-Verbose -Message $localizedData.AddProxyConfiguration
                return $false
            }
            else
            {
                Write-Verbose -Message $localizedData.NoProxyConfigNoAction
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
