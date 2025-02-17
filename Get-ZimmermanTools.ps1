<#
.SYNOPSIS
    This script will discover and download all available programs from https://ericzimmerman.github.io and download them to $Dest
.DESCRIPTION
    A file will also be created in $Dest that tracks the SHA-1 of each file, so rerunning the script will only download new versions. To redownload, remove lines from or delete the CSV file created under $Dest and rerun.
.PARAMETER Dest
    The path you want to save the programs to.
.EXAMPLE
    C:\PS> Get-ZimmermanTools.ps1 -Dest c:\tools
    Downloads/extracts and saves details about programs to c:\tools directory.
.NOTES
    Author: Eric Zimmerman
    Date:   January 22, 2019    
#>

[Cmdletbinding()]
# Where to extract the files to
Param
(
    [Parameter()]
    [string]$Dest= (Resolve-Path ".") #Where to save programs to	
)


function Write-Color {
    <#
	.SYNOPSIS
        Write-Color is a wrapper around Write-Host.
        It provides:
        - Easy manipulation of colors,
        - Logging output to file (log)
        - Nice formatting options out of the box.
	.DESCRIPTION
        Author: przemyslaw.klys at evotec.pl
        Project website: https://evotec.xyz/hub/scripts/Write-Color-ps1/
        Project support: https://github.com/EvotecIT/PSWriteColor
        Original idea: Josh (https://stackoverflow.com/users/81769/josh)
	.EXAMPLE
    Write-Color -Text "Red ", "Green ", "Yellow " -Color Red,Green,Yellow
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
					"Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
                    "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan -StartTab 3 -LinesBefore 1 -LinesAfter 1
    .EXAMPLE
	Write-Color "1. ", "Option 1" -Color Yellow, Green
	Write-Color "2. ", "Option 2" -Color Yellow, Green
	Write-Color "3. ", "Option 3" -Color Yellow, Green
	Write-Color "4. ", "Option 4" -Color Yellow, Green
	Write-Color "9. ", "Press 9 to exit" -Color Yellow, Gray -LinesBefore 1
    .EXAMPLE
	Write-Color -LinesBefore 2 -Text "This little ","message is ", "written to log ", "file as well." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt" -TimeFormat "yyyy-MM-dd HH:mm:ss"
	Write-Color -Text "This can get ","handy if ", "want to display things, and log actions to file ", "at the same time." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt"
    .EXAMPLE
    # Added in 0.5
    Write-Color -T "My text", " is ", "all colorful" -C Yellow, Red, Green -B Green, Green, Yellow
    wc -t "my text" -c yellow -b green
    wc -text "my text" -c red
    .NOTES
        CHANGELOG
        Version 0.5 (25th April 2018)
        -----------
        - Added backgroundcolor
        - Added aliases T/B/C to shorter code
        - Added alias to function (can be used with "WC")
        - Fixes to module publishing
        Version 0.4.0-0.4.9 (25th April 2018)
        -------------------
        - Published as module
        - Fixed small issues
        Version 0.31 (20th April 2018)
        ------------
        - Added Try/Catch for Write-Output (might need some additional work)
        - Small change to parameters
        Version 0.3 (9th April 2018)
        -----------
        - Added -ShowTime
        - Added -NoNewLine
        - Added function description
        - Changed some formatting
        Version 0.2
        -----------
        - Added logging to file
        Version 0.1
        -----------
        - First draft
        Additional Notes:
        - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx
    #>
    [alias('Write-Colour')]
    [CmdletBinding()]
    param (
        [alias ('T')] [String[]]$Text,
        [alias ('C', 'ForegroundColor', 'FGC')] [ConsoleColor[]]$Color = [ConsoleColor]::White,
        [alias ('B', 'BGC')] [ConsoleColor[]]$BackGroundColor = $null,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $LinesBefore = 0,
        [int] $LinesAfter = 0,
        [int] $StartSpaces = 0,
        [alias ('L')] [string] $LogFile = '',
        [Alias('DateFormat', 'TimeFormat')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [alias ('LogTimeStamp')][bool] $LogTime = $true,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf7', 'utf32', 'ascii', 'default', 'oem')][string]$Encoding = 'Unicode',
        [switch] $ShowTime,
        [switch] $NoNewLine
    )
    $DefaultColor = $Color[0]
    if ($null -ne $BackGroundColor -and $BackGroundColor.Count -ne $Color.Count) { Write-Error "Colors, BackGroundColors parameters count doesn't match. Terminated." ; return }
    #if ($Text.Count -eq 0) { return }
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host -Object "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host -Object "`t" -NoNewLine } }  # Add TABS before text
    if ($StartSpaces -ne 0) {  for ($i = 0; $i -lt $StartSpaces; $i++) { Write-Host -Object ' ' -NoNewLine } }  # Add SPACES before text
    if ($ShowTime) { Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))]" -NoNewline} # Add Time before output
    if ($Text.Count -ne 0) {
        if ($Color.Count -ge $Text.Count) {
            # the real deal coloring
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
            }
        } else {
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackGroundColor[0] -NoNewLine }
            }
        }
    }
    if ($NoNewLine -eq $true) { Write-Host -NoNewline } else { Write-Host } # Support for no new line
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host -Object "`n" -NoNewline } }  # Add empty line after
    if ($Text.Count -ne 0 -and $LogFile -ne "") {
        # Save to file
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        try {
            if ($LogTime) {
                Write-Output -InputObject "[$([datetime]::Now.ToString($DateTimeFormat))]$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            } else {
                Write-Output -InputObject "$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            }
        } catch {
            $_.Exception
        }
    }
}

Write-Color -LinesBefore 1 "This script will discover and download all available programs" -BackgroundColor Blue
Write-Color "from https://ericzimmerman.github.io and download them to $Dest" -BackgroundColor Blue -LinesAfter 1
Write-Color "A file will also be created in $Dest that tracks the SHA-1 of each file,"
Write-Color "so rerunning the script will only download new versions."
Write-Color -LinesBefore 1 -Text "To redownload, remove lines from or delete the CSV file created under $Dest and rerun. Enjoy!" -LinesAfter 1

$TestColor = (Get-Host).ui.rawui.ForegroundColor
if ($TestColor -eq -1) 
{
    $defaultColor = [ConsoleColor]::Gray
} else {
    $defaultColor = $TestColor
}

$newInstall = $false

if(!(Test-Path -Path $Dest ))
{
    Write-Color -Text "* ", "$Dest does not exist. Creating..." -Color Green,$defaultColor
    New-Item -ItemType directory -Path $Dest > $null

    $newInstall = $true
}

$URL = "https://raw.githubusercontent.com/EricZimmerman/ericzimmerman.github.io/master/index.md"

$WebKeyCollection = @()

$localDetailsFile = Join-Path $Dest -ChildPath "!!!RemoteFileDetails.csv"

if (Test-Path -Path $localDetailsFile)
{
    Write-Color -Text "* ", "Loading local details from '$Dest'..." -Color Green,$defaultColor
    $LocalKeyCollection = Import-Csv -Path $localDetailsFile
}

$toDownload = @()

#Get zips
$progressPreference = 'silentlyContinue'
$PageContent = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content
$progressPreference = 'Continue'

$regex = [regex] '(?i)\b(https)://[-A-Z0-9+&@#/%?=~_|$!:,.;]*[A-Z0-9+&@#/%=~_|$].(zip|txt)'
$matchdetails = $regex.Match($PageContent)

Write-Color -Text "* ", "Getting available programs..." -Color Green,$defaultColor
$progressPreference = 'silentlyContinue'
while ($matchdetails.Success) {
    $headers = (Invoke-WebRequest -Uri $matchdetails.Value -UseBasicParsing -Method Head).Headers

    $getUrl = $matchdetails.Value
    $sha = $headers["x-bz-content-sha1"]
    $name = $headers["x-bz-file-name"]
    $size = $headers["Content-Length"]

    $details = @{            
        Name     = [string]$name            
        SHA1     = [string]$sha                 
        URL      = [string]$getUrl
        Size     = [string]$size
        }                           

    $webKeyCollection += New-Object PSObject -Property $details  

    $matchdetails = $matchdetails.NextMatch()
} 
$progressPreference = 'Continue'

Foreach ($webKey in $webKeyCollection)
{
    if ($newInstall)
    {
        $toDownload+= $webKey
        continue    
    }

    $localFile = $LocalKeyCollection | Where-Object {$_.Name -eq $webKey.Name}

    if ($null -eq $localFile -or $localFile.SHA1 -ne $webKey.SHA1)
    {
        #Needs to be downloaded since SHA is different or it doesnt exist
        $toDownload+= $webKey
    }
}

if ($toDownload.Count -eq 0)
{
    Write-Color -LinesBefore 1 -Text "* ", "All files current. Exiting." -Color Green,Blue -LinesAfter 1
    return
}

$downloadedOK = @()

$destFile = ""
$name = ""

$i=0
$dlCount= $toDownload.Count
Write-Color -Text "* ", "Files to download: $dlCount" -Color Green,$defaultColor
foreach($td in $toDownload)
{
    $p = [math]::round( ($i/$toDownload.Count) *100, 2 )

    #Write-Host ($td | Format-Table | Out-String)
    
    try 
    {
        $dUrl = $td.URL
        $size = $td.Size
        $name = $td.Name

	Write-Progress -Activity "Updating programs...." -Status "$p% Complete" -PercentComplete $p -CurrentOperation "Downloading $name" 
	$destFile = [IO.Path]::Combine($Dest, $name)

        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing

	Write-Color -Text "* ", "Downloaded $name (Size: $size)" -Color Green,Blue
    
        $downloadedOK += $td

	if ( $name.endswith("zip") )  
	{
	    Expand-Archive -Path $destFile -DestinationPath $Dest -Force
	}      
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        Write-Color -Text "* ", "Error downloading $name ($ErrorMessage). Wait for the run to finish and try again by repeating the command" -Color Green,Red
    }
    finally 
    {
        $progressPreference = 'Continue'
	if ( $name.endswith("zip") )  
	{
	    remove-item -Path $destFile
	} 
        
    }
    $i+=1
}

#Write-Host ($webKeyCollection | Format-Table | Out-String)

#Downloaded ok contains new stuff, but we need to account for existing stuff too
foreach($webItems in $webKeyCollection)
{
    #Check what we have locally to see if it also contains what is in the web collection
    $localFile = $LocalKeyCollection | Where-Object {$_.SHA1 -eq $webItems.SHA1}

    #if its not null, we have a local file match against what is on the website, so its ok
    
    if ($null -ne $localFile)
    {
        #consider it downloaded since SHAs match
        $downloadedOK+=$webItems
    }
}


Write-Color -LinesBefore 1 -Text "* ", "Saving downloaded version information to $localDetailsFile" -Color Green,$defaultColor -LinesAfter 1

$downloadedOK | export-csv -Path  $localDetailsFile


# SIG # Begin signature block
# MIIN9QYJKoZIhvcNAQcCoIIN5jCCDeICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUS7Fg9gbIgCzbGDPeK81cZ1M2
# ZjmgggssMIIFRDCCBCygAwIBAgIQJCElLwM8LqlKqXuJPg7XgDANBgkqhkiG9w0B
# AQsFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEj
# MCEGA1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNpZ25pbmcgQ0EwHhcNMTcwMTI0MDAw
# MDAwWhcNMjAwMTI0MjM1OTU5WjCBjDELMAkGA1UEBhMCVVMxDTALBgNVBBEMBDQ2
# NTAxCzAJBgNVBAgMAklOMQ8wDQYDVQQHDAZCUkVNRU4xGDAWBgNVBAkMDzgzNjkg
# Rk9SVFVORSBTVDEaMBgGA1UECgwRRXJpYyBSLiBaaW1tZXJtYW4xGjAYBgNVBAMM
# EUVyaWMgUi4gWmltbWVybWFuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEAs50rqyiMFnB6xpHDXJ+ukpwiWsyGK6W+BhU/brQ2AqaFLYiHMtJikjPu1P4o
# hbjPmDsAATHPhIHjO4ShFtf57Ia0PGUX57pZs9+UswzZXycY+1+OlGZhjZxq0/hX
# K5Hnb7bnLsDXl9DDtIX+/IzFifOr78AAqLmcOTvw51Mis5gMkRhFueWNaCZoCqA3
# ZG+9saF7R7sX6V0ARJJvOB636/Slf30BnmQ/AUu38+P/R8QIfmFkd1JYLFTAiexS
# 7oU2feSl3Ip7BjFbRBURM/s6n4IAl4RfxIwMIZZXK9SDQ/l6YVtwFjajTN1Nt/8p
# ElgOPYQWnVyXcHD6pjlb/7CLDQIDAQABo4IBrjCCAaowHwYDVR0jBBgwFoAUKZFg
# /4pN+uv5pmq4z/nmS71JzhIwHQYDVR0OBBYEFMU70XOGztmOZSxCzT1WXicMtytC
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMBEGCWCGSAGG+EIBAQQEAwIEEDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgED
# AjArMCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9S
# U0FDb2RlU2lnbmluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPgYIKwYBBQUHMAKG
# Mmh0dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNvZGVTaWduaW5nQ0Eu
# Y3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wHwYDVR0R
# BBgwFoEUZXJpY0BtaWtlc3RhbW1lci5jb20wDQYJKoZIhvcNAQELBQADggEBAA37
# Gw1WfRao+cnwJr720XgyyArQKP7YbXogH7bQ/H+ZNxIBD4QctWKvyYkCWqBxOEJN
# PoCiE4UuTBP/qDZLCi5PaLmd6/ppw9vKw2iL/AezEmlqHPrixu37xTsqRKgImkBI
# Oa0mbk/OqzBd0Vb0ahkeKzvMNICgx6Csk/GKaF9vYJ8lVokp1hW8r6Q9AYWXGVQ7
# 1JJYw1QgK+uOo9rnnSN2UQIjmftN79zg1Noe9qgMqp3GFPm9QrYUdCveAbfNCYgk
# Ju4dx/ngzQXFeCnJ6qQKHUziDrW8Hs8H5ISRY0x2gdSJ+zwrPhIJvd93KtfVTeM0
# F1k7wmOzTdsmnBqUN3YwggXgMIIDyKADAgECAhAufIfMDpNKUv6U/Ry3zTSvMA0G
# CSqGSIb3DQEBDAUAMIGFMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBN
# YW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0Eg
# TGltaXRlZDErMCkGA1UEAxMiQ09NT0RPIFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhv
# cml0eTAeFw0xMzA1MDkwMDAwMDBaFw0yODA1MDgyMzU5NTlaMH0xCzAJBgNVBAYT
# AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZv
# cmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSMwIQYDVQQDExpDT01PRE8g
# UlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAKaYkGN3kTR/itHd6WcxEevMHv0xHbO5Ylc/k7xb458eJDIRJ2u8UZGnz56e
# JbNfgagYDx0eIDAO+2F7hgmz4/2iaJ0cLJ2/cuPkdaDlNSOOyYruGgxkx9hCoXu1
# UgNLOrCOI0tLY+AilDd71XmQChQYUSzm/sES8Bw/YWEKjKLc9sMwqs0oGHVIwXla
# CM27jFWM99R2kDozRlBzmFz0hUprD4DdXta9/akvwCX1+XjXjV8QwkRVPJA8MUbL
# cK4HqQrjr8EBb5AaI+JfONvGCF1Hs4NB8C4ANxS5Eqp5klLNhw972GIppH4wvRu1
# jHK0SPLj6CH5XkxieYsCBp9/1QsCAwEAAaOCAVEwggFNMB8GA1UdIwQYMBaAFLuv
# fgI9+qbxPISOre44mOzZMjLUMB0GA1UdDgQWBBQpkWD/ik366/mmarjP+eZLvUnO
# EjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAK
# BggrBgEFBQcDAzARBgNVHSAECjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBBoD+gPYY7
# aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQ2VydGlmaWNhdGlvbkF1
# dGhvcml0eS5jcmwwcQYIKwYBBQUHAQEEZTBjMDsGCCsGAQUFBzAChi9odHRwOi8v
# Y3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FBZGRUcnVzdENBLmNydDAkBggrBgEF
# BQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUAA4IC
# AQACPwI5w+74yjuJ3gxtTbHxTpJPr8I4LATMxWMRqwljr6ui1wI/zG8Zwz3WGgiU
# /yXYqYinKxAa4JuxByIaURw61OHpCb/mJHSvHnsWMW4j71RRLVIC4nUIBUzxt1Hh
# UQDGh/Zs7hBEdldq8d9YayGqSdR8N069/7Z1VEAYNldnEc1PAuT+89r8dRfb7Lf3
# ZQkjSR9DV4PqfiB3YchN8rtlTaj3hUUHr3ppJ2WQKUCL33s6UTmMqB9wea1tQiCi
# zwxsA4xMzXMHlOdajjoEuqKhfB/LYzoVp9QVG6dSRzKp9L9kR9GqH1NOMjBzwm+3
# eIKdXP9Gu2siHYgL+BuqNKb8jPXdf2WMjDFXMdA27Eehz8uLqO8cGFjFBnfKS5tR
# r0wISnqP4qNS4o6OzCbkstjlOMKo7caBnDVrqVhhSgqXtEtCtlWdvpnncG1Z+G0q
# DH8ZYF8MmohsMKxSCZAWG/8rndvQIMqJ6ih+Mo4Z33tIMx7XZfiuyfiDFJN2fWTQ
# js6+NX3/cjFNn569HmwvqI8MBlD7jCezdsn05tfDNOKMhyGGYf6/VXThIXcDCmhs
# u+TJqebPWSXrfOxFDnlmaOgizbjvmIVNlhE8CYrQf7woKBP7aspUjZJczcJlmAae
# zkhb1LU3k0ZBfAfdz/pD77pnYf99SeC7MH1cgOPmFjlLpzGCAjMwggIvAgEBMIGR
# MH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
# BgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSMwIQYD
# VQQDExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQQIQJCElLwM8LqlKqXuJPg7X
# gDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUJau3W/W7a17dzb1D1a6jMvwWd8YwDQYJKoZIhvcN
# AQEBBQAEggEAWmr0RBPqdQ0YnMUMmbnfoaF8dT2tOHm4QhFu4N/D7kYxa+dXZ4mT
# Bzetckvrlz5MSHrs3+E0G+I7BFHF/+jrsQ55dzDfAXPxt+YfopOQPjirCFBFJgTV
# WakyCR/hzRUKg/Oce1VMfmY88Vzvgq8AjYXhq0LfRDkVJ6I8uT3UynUTho+IVG4m
# Es09G/loKl7o26xn7PV3BSCLjd/r0muMsrzrx/+cWEafQ1598R4gl6t+5UCccHy0
# mvWXh2M91vZNZUErHnTEhhFohZKFDbW5zn9CiBLwbYD5CmGWKPR53aBn/xV3M4+7
# X6kRPxpvUrhY4KI7anRDwsKPpZf1tN2XNA==
# SIG # End signature block
