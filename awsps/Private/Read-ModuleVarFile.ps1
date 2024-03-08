Function Read-ModuleVarFile {
    [CmdletBinding(DefaultParameterSetName='none')]
    Param(
        [Parameter(ParameterSetName='import')]
        [switch]
        $Import,
        [Parameter(ParameterSetName='import')]
        [ValidateSet('Local','Script','Global')]
        $Scope = 'Local'
    )
    Begin {
        $return = @{}
    }
    Process {
        if ( !$env:AWSPS_VAR_PATH ) {
            throw "Module Path not defined."
        }
        if ( ! ( Test-Path $env:AWSPS_VAR_PATH ) ) {
            throw "Module Variable config not found at destination '$env:AWSPS_VAR_PATH'. Re-Import module to create a new one."
        }
        Get-Content $env:AWSPS_VAR_PATH | ConvertFrom-Json | ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                $return[$_.Name] = $_.Value
            }
        }
        if ( $Import ) {
            foreach ( $kv in $return.GetEnumerator() ) {
                New-Variable -Name $kv.Key -Value $kv.Value -Force -Scope $Scope
            }
        }
        return $return
    }
}