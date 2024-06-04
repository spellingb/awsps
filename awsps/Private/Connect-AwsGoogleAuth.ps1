
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
        $ProfileName,

        [Parameter()]
        [switch]
        $UseContainer
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
            if ( $UseContainer ) {
                $imagename = 'cevoaustralia/aws-google-auth:latest'
                if ( Assert-Container -ImageName  $imagename) {
                    # 'docker run -it -v "{0}/.aws:/root/.aws" cevoaustralia/aws-google-auth --profile default'
                    $expression = 'docker run -it --platform linux/amd64 -v "{0}/.aws:/root/.aws" {1}' -f $HOME, $imagename
                    if ( $ProfileName ) {
                        $expression += ' --profile {0}' -f $ProfileName
                    }
                    Invoke-Expression $expression
                }
            } elseif ( Assert-AwsGoogleAuth ) {
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
