Function Read-ModuleEnvVarFile {
    [CmdletBinding()]
    Param(
        [Switch]
        $Import
    )
    Begin {
        $return = @{}
    }
    Process {
        if ( !$env:AWSPS_ENV_VAR_PATH ) {
            throw "Module Path not defined."
        }
        if ( ! ( Test-Path $env:AWSPS_ENV_VAR_PATH ) ) {
            throw "Module Variable config not found at destination '$env:AWSPS_ENV_VAR_PATH'. Re-Import module to create a new one."
        }
        Get-Content $env:AWSPS_ENV_VAR_PATH | ConvertFrom-Json | ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                $return[$_.Name] = $_.Value
            }
        }
        if ( $Import ) {
            foreach ( $kv in $return.GetEnumerator() ) {
                if ( $null -eq $kv.Value ) {
                    continue
                }
                New-Item -Path "Env:/" -Name $kv.Key -Value $kv.Value -Force
            }
        }
        return $return
    }
}