function Connect-AwsSso {
    [cmdletbinding(DefaultParameterSetName='none')]
    [alias('csso')]
    param (
        [Parameter()]
        [ValidateSet('gsso','awssso', 'gsts')]
        $ConnectionMethod,

        [Parameter(ParameterSetName='profile', Position=0)]
        $ProfileName,

        $Region
    )
    Process {
        #ensure all vars are imported
        Read-ModuleVarFile -Import -Scope Global | Out-Null
        Read-ModuleEnvVarFile -Import | Out-Null
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

            if ( $env:AWSPS_OP_PATH ) {
                Invoke-Expression "op read $env:AWSPS_OP_PATH" | Set-Clipboard
                Write-Verbose -Verbose "Google Auth Secret saved to clipboard"
            }

            if ( $env:AWSPS_GOOGLE_CONNECTION_METHOD_USE_CONTAINER ) {
                Connect-AwsGoogleAuth @splat -UseContainer
            } else {
                Connect-AwsGoogleAuth @splat
            }
        }
        if ( $ConnectionMethod -eq 'awssso' ) {
            # aws sso workflow
        }
        if ( $ConnectionMethod -eq 'gsts' ) {
            rm -rf "$home/Library/Caches/gsts"
            gsts --idp-id=C03qd0gl5 --sp-id=270946040622 --aws-role-arn=arn:aws:iam::093056686911:role/GoogleApps --username=brandon.spell@cloudticity.com --playwright-engine-executable-path='/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge' --aws-region=us-east-1 --clean --force

            Get-AwsCurrentAccountContext
        }
    }
}