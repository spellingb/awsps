
function Initialize-AwsPs {
    [CmdletBinding(DefaultParameterSetName='none')]
    [alias('initaws')]
    param(
        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleIDPID,

        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleSPID,

        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleRoleArn,

        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleRoleDuration,

        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleConnectionMethod,

        [Parameter(Mandatory,ParameterSetName='gauth')]
        [string]
        $GoogleUserName,

        [Parameter(ParameterSetName='gauth')]
        [string]
        $GoogleHttpRedirectPort = '4589',

        [Parameter(ParameterSetName='gauth')]
        [string]
        $OPSecretPath,

        [Parameter(ParameterSetName='gauth')]
        [bool]
        $UseContainer,

        $ProfileName = 'default',

        $Region = 'us-east-1'

    )
    Begin {

    }
    Process {
        if ( $ProfileName ) {
            Write-ModuleEnvironmentVariable -Name AWS_DEFAULT_PROFILE -Value $ProfileName
            Write-ModuleEnvironmentVariable -Name AWS_PROFILE -Value $ProfileName
        }

        if ( $Region ) {
            Write-ModuleEnvironmentVariable -Name AWS_DEFAULT_REGION -Value $Region
            Write-ModuleEnvironmentVariable -Name AWS_REGION -Value $Region
            Set-DefaultAWSRegion -Scope Global -Region $Region
        }

        if ( $PSCmdlet.ParameterSetName -eq 'none' ) {

        }

        if ( $PSCmdlet.ParameterSetName -eq 'gauth' ) {
            # Set Env Vars
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_SPID -Value $GoogleSPID
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_IDPID -Value $GoogleIDPID
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_ROLE_ARN -Value $GoogleRoleArn
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_ROLE_DURATION -Value $GoogleRoleDuration
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_HTTP_REDIRECT_PORT -Value $GoogleHttpRedirectPort
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_USER_NAME -Value $GoogleUserName
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_CONNECTION_METHOD -Value $GoogleConnectionMethod
            Write-ModuleEnvironmentVariable -Name AWSPS_AUTH_TYPE -Value 'gsso'
            Write-ModuleEnvironmentVariable -Name ASA_LOGIN_URL -Value "https://accounts.google.com/o/saml2/initsso?idpid=$env:AWSPS_GOOGLE_IDPID&spid=$env:AWSPS_GOOGLE_SPID&forceauthn=false"
            Write-ModuleEnvironmentVariable -Name AWSPS_OP_PATH -Value $OPSecretPath
            Write-ModuleEnvironmentVariable -Name AWSPS_GOOGLE_CONNECTION_METHOD_USE_CONTAINER -Value $UseContainer
            Connect-AwsSso
        }
    }
}