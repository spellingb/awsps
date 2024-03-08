Function Clear-AwsDefaultProfile {
    [CmdletBinding(ConfirmImpact='High',SupportsShouldProcess)]
    Param(
        [switch]
        $Force
    )
    Process {
        if ( $PSCmdlet.ShouldProcess( "AWS_DEFAULT_PROFILE", "Clear AWS Profile Variable?" )  -or $Force) {
            Write-ModuleEnvironmentVariable -Name AWS_DEFAULT_PROFILE -Value $null
        }
        if ( $PSCmdlet.ShouldProcess( "AWS_PROFILE", "Clear AWS Profile Variable?" ) -or $Force ) {
            Write-ModuleEnvironmentVariable -Name AWS_PROFILE -Value $null
        }
    }
}