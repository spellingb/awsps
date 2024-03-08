Function Clear-AwsSsoCache {
    [CmdletBinding(ConfirmImpact='High',SupportsShouldProcess)]
    Param(

    )
    Process {
        if ( $PSCmdlet.ShouldProcess( "$home/.aws/cli/cache", "Clear AWS Cache?" ) ) {
            Remove-Item "$home/.aws/cli/cache" -Recurse
        }
    }
}