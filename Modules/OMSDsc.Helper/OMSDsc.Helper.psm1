#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -filename OMSDsc.Helper.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -filename OMSDsc.Helper.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

#region enums
Add-Type -TypeDefinition @"
   public enum AzureCloudType
   {
      AzureCommercial = 0,
      AzureGovernment = 1
   }
"@
#endregion
function Get-LAAgent
{
    [CmdletBinding()]
    param (

    )

    Write-Verbose -Message $localizedData.CheckLAAgent
    $productDetail = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object { ($_.DisplayName -eq $localizedData.MMAProductName) -and ($_.Publisher -eq 'Microsoft Corporation') }
    if ($productDetail)
    {
        $laAgent = @{
            ProductName = $productDetail.DisplayName
            ProductVersion = $productDetail.DisplayVersion
            ProductId = [regex]::match($productDetail.PSChildName, '{(.*?)}').Groups[1].Value
        }
    }

    return $laAgent
}

function Get-LAAgentCOMObject
{ 
    param(
        [Parameter()]
        [string]$Filter = 'AgentConfigManager.MgmtSvcCfg'
    )
    
    Write-Verbose -Message $localizedData.CheckLAAgentComObject
    $objectList = Get-ChildItem HKLM:\Software\Classes -ErrorAction SilentlyContinue | 
                    Where-Object {
                        $_.PSChildName -match '^\w+\.\w+$' -and `
                        (Test-Path -Path "$($_.PSPath)\CLSID")
                    } | 
                    Select-Object -ExpandProperty PSChildName
 
    if ($objectList -contains $Filter)
    {
        try
        {
            Write-Verbose -Message $localizedData.InitializeComObject
            New-Object -ComObject $Filter
        }
        catch
        {
            throw $_
        }
    }
    else
    {
        throw $localizedData.COMObjectNotFound
    }
}

Export-ModuleMember -function *
