function Connect-AwsSso {
    [cmdletbinding(DefaultParameterSetName='none')]
    [alias('csso')]
    param (
        [Parameter()]
        [ValidateSet('gsso','awssso')]
        $ConnectionMethod,

        [Parameter(ParameterSetName='profile', Position=0)]
        $ProfileName,

        $Region
    )
    Process {
        if ( !$ConnectionMethod ) {
            $ConnectionMethod = $env:AWSPS_AUTH_TYPE
        }

        if ( $ConnectionMethod -eq 'gsso' ) {
            $splat = @{
                ConnectionMethod = $env:AWSPS_GOOGLE_CONNECTION_METHOD
                GoogleUserName = $env:AWSPS_GOOGLE_USER_NAME
                GoogleIDPID = $env:AWSPS_GOOGLE_IDPID
                GoogleSPID = $env:AWSPS_GOOGLE_SPID
                RoleArn = $env:AWSPS_GOOGLE_ROLE_ARN
                RoleArnDuration = $env:AWSPS_GOOGLE_ROLE_DURATION
                Region = $env:AWS_REGION
                Bg_Response = 'None'
                ProfileName = $env:AWS_PROFILE
            }
            if ( $ProfileName ) {
                $splat['ProfileName'] = $ProfileName
            }

            if ( $Region ) {
                $splat['Region'] = $Region
            }

            Connect-AwsGoogleAuth @splat
        }
        if ( $ConnectionMethod -eq 'awssso' ) {
            # aws sso workflow
        }
    }
}