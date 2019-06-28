# Azure IP address and Service tags helper script

## How to use

See powershell script

or

```pwsh
PS > help azip.ps1
```

## Specification

Azure Service tags and IP address ranges can be download from :

- [Public Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=56519)
- [China Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=57062)
- [US Goverment Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=57063)
- [Germany Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=57064)

This script downloads json file from confirmation pages with web scraping like below.

![scraping.png](./scraping.png)

and save and re-use downloaded json daily.
If you want to clear cache, check the path with Verbose option.

```pwsh
PS > .\azip.ps1 -verbose  -service dummy

VERBOSE: tempolary file will be C:\Users\ayumu\AppData\Local\Temp\20190628_AzureServiceTags.Public.json
VERBOSE: cloud type : Public, change number : 78
WARNING: service dummy is not found
```