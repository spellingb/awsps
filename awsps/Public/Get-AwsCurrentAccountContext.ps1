function Get-AwsCurrentAccountContext {

    [CmdletBinding()]
    [alias('awspwd')]
    Param(
    )
    Begin {
        $return = [PSCustomObject]@{
            Account = ''
            Accountname = ''
            Arn = ''
            Region = ''
            Expired = $false
            LoggedAt = ''
        }
    }
    process {
        #Get the default credential being used
        try {
            $AwsCredential = Get-AWSCredential
        }
        catch {
            Write-Warning $_
        }

        try {
            $sts = Get-STSCallerIdentity -ErrorAction Stop

            # try to match a name to an account id
            try {
                $return.Accountname = Get-IAMAccountAlias -ErrorAction Stop
            } catch {
                Write-Verbose "No IAM Account Alias"
            }

            if ( !$return.Accountname ) {

            }

        }
        catch [System.InvalidOperationException] {
            $return.Expired = $true
            if ( $_.Exception.InnerException.InnerException ) {
                $exception = $_.Exception.InnerException.InnerException
                $message = 'Statuscode: {0} Reason: {1}' -f $exception.StatusCode, $exception.Message
                Write-Warning $message
            }

            if ( $_.Exception.InnerException.ParamName -match 'Options property cannot be empty: ClientName' ) {
                if ( ! ( Test-AwsCredential ) ) {
                    Write-Warning "Credential Expired. Run Connect-AWS or refresh Credential manually."
                }
            } else {
                Write-Warning $_.Exception.Message
            }

        } catch {
            $return.Expired = $true
            Write-Warning "General Failure:`n$($_.Exception.Message)"
        }

        $return.Region = $AwsCredential.Region

        if ( !$return.Region  ) {
            if ( $env:AWS_REGION ) {
                $return.Region  = $env:AWS_REGION
            } elseif ( ( Get-DefaultAWSRegion ) ) {
                $return.Region  = ( Get-DefaultAWSRegion ).Region
            }
        }

        if ( $sts ) {
            Write-Verbose "[$($MyInvocation.MyCommand)] STS Credentials Found"
            $return.Arn = $sts.Arn
            $return.Account = $sts.Account
            $return.LoggedAt = $sts.LoggedAt

            # if ( $accountAlias ) {
            #     $sts.AccountName = $accountAlias
            #     Write-Verbose "[$($MyInvocation.MyCommand)] Using IAM Account Alias For Accountname Property"
            #     return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)
            # }

            # $Account = Get-AwsSsoAccount -AccountID $sts.Account -ErrorAction Ignore -WarningAction Ignore
            # if ( $Account ) {
            #     Write-Verbose "[$($MyInvocation.MyCommand)] Using AWS SSO Account Name for Accountname Property"
            #     $sts.AccountName = $Account.AccountName
            #     return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)
            # }

            # Write-Verbose "[$($MyInvocation.MyCommand)] Unable to resolve AccountName."
            # return ( New-Object psobject -Property ([ordered]@{
            #     Account = ''
            #     Accountname = ''
            #     Arn = ''
            #     Region = ''
            #     LoggedAt = ''
            # }) )
            # return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)
            return $return
        } else {
            Write-Warning "You can run sprofile -profilename <PROFILE_NAME> to set a default."
        }
    }
}