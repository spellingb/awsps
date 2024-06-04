Function Clear-AwsDefaultProfile {
    [CmdletBinding(ConfirmImpact='High',SupportsShouldProcess)]
    Param(
        [switch]
        $Force
    )
    Process {
        if ( $Force ) {
            Write-ModuleEnvironmentVariable -Name AWS_DEFAULT_PROFILE -Value $null
            Write-ModuleEnvironmentVariable -Name AWS_PROFILE -Value $null
        } else {
            if ( $PSCmdlet.ShouldProcess( "AWS_DEFAULT_PROFILE", "Clear value [$env:AWS_DEFAULT_PROFILE]?" )  -or $Force) {
                Write-ModuleEnvironmentVariable -Name AWS_DEFAULT_PROFILE -Value $null
            } else {
                Write-Warning "Skipping AWS_DEFAULT_PROFILE"
            }
            if ( $PSCmdlet.ShouldProcess( "AWS_PROFILE", "Clear Value [$env:AWS_PROFILE]" ) -or $Force ) {
                Write-ModuleEnvironmentVariable -Name AWS_PROFILE -Value $null
            } else {
                Write-Warning "Skipping AWS_PROFILE"
            }
        }
    }
}