function Set-AwsDefaultProfile {

    [CmdletBinding()]
    [alias('sprofile')]
    param (
        [Parameter(Position=0, Mandatory)]
        [alias('-profile','p')]
        $ProfileName,

        [Alias('awsRegion')]
        $Region,

        [switch]
        $Persistent
    )
    Process {
        $AwsCredential = Get-AWSCredential -ProfileName $ProfileName

        if ( $AwsCredential ) {
            Remove-Item env:\AWS_PROFILE -ErrorAction Ignore
            $env:AWS_PROFILE = $ProfileName

            if ( $Persistent ) {
                Write-ModuleEnvironmentVariable -Name AWS_PROFILE -Value $env:AWS_PROFILE
            }

            Set-AWSCredential -ProfileName $env:AWS_PROFILE -Scope Global

            if ( $Region ) {
                $env:AWS_REGION = $Region
                Set-DefaultAWSRegion -Scope Global -Region $Region
            } elseif ( $AwsCredential.Region ) {
                $env:AWS_REGION = $AwsCredential.Region
            }

            Get-AwsCurrentAccountContext
        } else {
            Write-Warning "$ProfileName No Profile found."
        }
        }



}