
# Persist Credentials
if ( $env:AWS_PROFILE ) {
    Write-Verbose "Persistiong AWS Profile: $env:AWS_PROFILE"
    try {
        Set-AWSCredential -ProfileName $env:AWS_PROFILE -Scope Global -ErrorAction Stop
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
}

# set var location
$env:AWSPS_VAR_PATH = "$PSScriptRoot/Lib/vars.json"
$env:AWSPS_ENV_VAR_PATH = "$PSScriptRoot/Lib/envvars.json"


# Test AWS Cli Version
# aws cli v2.9.0 has enhancement for --sso-session that is mandatory
Write-Verbose "Testing AWS CLI Version is greater than 2.9.0"
$RequiredAwsCliVersion = '2.9.0'
if ( !( Get-Command aws -TotalCount 1 -ErrorAction SilentlyContinue ) ) {
    if ( $IsWindows ) {
        $listPath = '$env:PATH.split(";")'
    } else {
        $listPath = '$env:PATH.split(":")'
    }
    Write-Warning "AWS CLI Not found! Please Check the following:"
    Write-Warning "1. Check that the application is installed. Download: https://aws.amazon.com/cli/"
    Write-Warning "2. Check that the AWS CLI binary directory is in your environment PATH. --> To list your path, run: $listPath"

    throw "AWS CLI not found!"
}

$awsCli = Invoke-Expression "aws --version" | Select-String -Pattern "(aws-cli/\d{1,2}\.\d{1,2}\.\d{1,3})"
[version]$awsCliVersion = $awsCli.Matches.Value.Split('/')[1]
if ( $awsCliVersion -lt $RequiredAwsCliVersion ) {
    throw "AWS CLI version $awsCliVersion is less than the Required Version: $requiredAwsCliVersion"
}


#import functions in public and private directories
$PublicFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue )
foreach ($file in @($PublicFunctions + $PrivateFunctions )) {
    try {
        . $file.FullName
    }
    catch {
        $exception = ([System.ArgumentException]"Function not found")
        $errorId = "Load.Function"
        $errorCategory = 'ObjectNotFound'
        $errorTarget = $file
        $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *


# Import Variables
if ( Test-Path $env:AWSPS_VAR_PATH ) {
    Read-ModuleVarFile -Import -Scope Global
} else {
    New-Item -Path $env:AWSPS_VAR_PATH -Value '{}' -Force
}

if ( Test-Path $env:AWSPS_ENV_VAR_PATH ) {
    Read-ModuleEnvVarFile -Import
} else {
    $envvar_value = @{
        AWSPS_ENV_VAR_PATH = $env:AWSPS_ENV_VAR_PATH
        AWSPS_VAR_PATH = $env:AWSPS_VAR_PATH
    } | ConvertTo-Json
    New-Item -Path $env:AWSPS_ENV_VAR_PATH -Value $envvar_value -Force
}

# Export module Members
Export-ModuleMember  -Variable "AWSPS_*","ASA_"
# $var_datafile = Import-LocalizedData -BaseDirectory ./Lib -FileName variables.psd1
# foreach ( $kv in $var_datafile.GetEnumerator() ) {
#     Write-Verbose "Importing Variable: $($kv.Key)"
#     New-Variable -Name $kv.Key -Value $kv.Value -Scope Global -Force
# }

