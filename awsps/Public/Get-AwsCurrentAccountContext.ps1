function Get-AwsCurrentAccountContext {

    [CmdletBinding()]
    [alias('awspwd')]
    Param(
    )

    try {
        $sts = Get-STSCallerIdentity -ErrorAction Stop
    }
    catch [System.InvalidOperationException] {
        if ( $_.Exception.InnerException.ParamName -match 'Options property cannot be empty: ClientName' ) {
            if ( ! ( Test-AwsCredential ) ) {
                Write-Warning "Credential Expired. Run Connect-AWS or refresh Credential manually."
                return $null
            }
        } else {
            Write-Warning $_.Exception.Message
        }

    } catch {
        Write-Warning "General Failure:`n$($_.Exception.Message)"
    }

    if ( $sts ) {
        Write-Verbose "[$($MyInvocation.MyCommand)] STS Credentials Found"

        $AwsCredential = Get-AWSCredential
        $region = $AwsCredential.Region

        if ( !$region ) {
            if ( $env:AWS_REGION ) {
                $region = $env:AWS_REGION
            } elseif ( ( Get-DefaultAWSRegion ) ) {
                $region = ( Get-DefaultAWSRegion ).Region
            }
        }

        $sts | Add-Member -NotePropertyName AccountName -NotePropertyValue $null -Force
        $sts | Add-Member -NotePropertyName Region -NotePropertyValue $AwsCredential.Region -Force

        try {
            $accountAlias = Get-IAMAccountAlias -ErrorAction Stop
        } catch {
            Write-Verbose "No IAM Account Alias"
        }

        if ( $accountAlias ) {
            $sts.AccountName = $accountAlias
            Write-Verbose "[$($MyInvocation.MyCommand)] Using IAM Account Alias For Accountname Property"
            return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)
        }

        $Account = Get-AwsSsoAccount -AccountID $sts.Account -ErrorAction Ignore -WarningAction Ignore
        if ( $Account ) {
            Write-Verbose "[$($MyInvocation.MyCommand)] Using AWS SSO Account Name for Accountname Property"
            $sts.AccountName = $Account.AccountName
            return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)
        }

        Write-Verbose "[$($MyInvocation.MyCommand)] Unable to resolve AccountName."
        return ($sts | Select-Object LoggedAt,Account,AccountName,Arn,Region)

    } else {
        Write-Warning "You can run sprofile -profilename <PROFILE_NAME> to set a default."
    }

}