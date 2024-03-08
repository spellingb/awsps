
function Connect-AwsGoogleAuth {
    [CmdletBinding(DefaultParameterSetName='none')]
    [alias('ccgauth')]
    param(
        [ValidateSet('aws-saml-auth','aws-google-auth')]
        $ConnectionMethod,
        $GoogleUserName,
        $GoogleIDPID,
        $GoogleSPID,
        $RoleArn,
        $RoleArnDuration,
        $Region,
        $Bg_Response = 'None',
        $ProfileName
    )
    Begin {

    }
    Process {
        if ( $ConnectionMethod -eq 'aws-saml-auth' ) {
            if ( Assert-AwsSamlAuth ) {
                Write-Verbose "[$($MyInvocation.MyCommand)] Starting SAML Connection"

                # aws-saml-auth --login-url $env:ASA_LOGIN_URL --region $env:AWS_DEFAULT_REGION --duration $env:AWSPS_GOOGLE_ROLE_DURATION --profile $env:AWS_DEFAULT_PROFILE --log debug

                # aws-saml-auth -h
            }
        }
        if ( $ConnectionMethod -eq 'aws-google-auth' ) {
            if ( Assert-AwsGoogleAuth ) {
                Write-Verbose "[$($MyInvocation.MyCommand)] Starting Google Legacy Connection ($ConnectionMethod)"
                $commandArgs = @(
                    "--disable-u2f",
                    "--region $Region",
                    "--username $GoogleUserName",
                    "--idp-id $GoogleIDPID",
                    "--sp-id $GoogleSPID",
                    "--duration $RoleArnDuration",
                    "--profile $ProfileName",
                    "--bg-response $Bg_Response",
                    "--role-arn $RoleArn"
                )
                if ( $DebugPreference -eq 'Continue' ) {
                    $commandArgs += "--log debug"
                    $commandArgs += "--save-failure-html"
                    $commandArgs += "--save-saml-flow"
                }
                try {
                    $expression = ($ConnectionMethod, ($commandArgs -join ' ')) -join ' '
                    Invoke-Expression $expression
                }
                catch {
                    Write-Warning $($_.Exception | Out-String)
                }
            }
        }
    }
}


