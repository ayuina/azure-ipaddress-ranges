<# 
.SYNOPSIS 
    Azure IP address range helper
.PARAMETER cloud
    target cloud type
.PARAMETER service
    target name of service tag
.PARAMETER list
    list service tags
.PARAMETER ignoreCache
    ignore localy cached json
.NOTES 
    Created:  2019/06/28
.EXAMPLE
    .\azip.ps1 -list
    List service tags of Public Azure

.EXAMPLE
    .\azip.ps1 -cloud China -list
    List service tags of Azure China
    
.EXAMPLE
    .\azip.ps1 -service AzureCloud.japaneast 
    List ip address ranges used by JapaneEast region

.EXAMPLE
    .\azip.ps1 -cloud Germany -service AppService 
    List ip address ranges used by App Service in Azure Germany

.EXAMPLE
    .\azip.ps1 -cloud USGov -service AzureCLoud
    List ip address ranges used by All regions in US Goverment Cloud

#>

Param (
    [parameter(Mandatory=$false)]
    [string][ValidateSet("Public" , "USGov", "Germany", "China")]
    $cloud = "Public",
    [parameter(Mandatory=$false)]
    [string]
    $service = "AzureCloud",
    [parameter(Mandatory=$false)]
    [switch]
    $list = $false,
    [parameter(Mandatory=$false)]
    [switch]
    $ignoreCache = $false
)

function Main()
{
    if($list)
    {
        (Get-AzureServiceTag -cloud $cloud -ignoreCache $ignoreCache).Values | ForEach-Object {$_.id}
        return
    }

    $serviceTags = (Get-AzureServiceTag -cloud $cloud -ignoreCache $ignoreCache ).Values | Where-Object { $_.id -ieq $service }
    if($null -eq $serviceTags -or $serviceTags.length -eq 0)
    {
        Write-Warning "service $service is not found"
        return
    }

    Write-Verbose "service id       : $($serviceTags.id)"
    Write-Verbose "change number    : $($serviceTags.properties.changeNumber)"
    Write-Verbose "region           : $($serviceTags.properties.region)"
    Write-Verbose "platform         : $($serviceTags.properties.platform)"
    Write-Verbose "system service   : $($serviceTags.properties.systemService)"

    $serviceTags.properties.addressPrefixes | Write-Output
}

function Get-AzureServiceTag($cloud, $ignoreCache)
{
    $tempfile = "$env:Temp\{0:yyyyMMdd}_AzureServiceTags.$cloud.json" -f [DateTime]::Now 
    Write-Verbose "tempolary file will be $tempfile"

    if( ((Test-Path $tempfile) -eq $false) -or $ignoreCache )
    {
        Write-Verbose "Downloading $cloud service tags"
        $url = Get-AzureServiceTagDownloadUrl($cloud)
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $tempfile 
    }

    $content = (Get-Content -Path $tempfile | ConvertFrom-Json)
    Write-Verbose "cloud type : $($content.cloud), change number : $($content.changeNumber)"
    return $content
}

function Get-AzureServiceTagDownloadUrl($cloud)
{
    $map = @{ Public = 56519; China = 57062; USGov = 57063; Germany = 57064; }
    $id = $map[$cloud]
    $downloadpage = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=$id"
    $links = (Invoke-WebRequest -UseBasicParsing -Uri $downloadpage).Links `
        | Where-Object { ($_.href -match "ServiceTags") -and ($_.href.EndsWith("json")) }

    return $links[0].href
}


Main 

