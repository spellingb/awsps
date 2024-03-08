Function Write-ModuleEnvironmentVariable {
    [CmdletBinding()]
    Param(
        [Parameter()]
        $Name,

        [Parameter()]
        [AllowNull()]
        $Value,

        [Switch]
        $Passthru
    )
    Begin{
        Write-Verbose "[$($MyInvocation.MyCommand)] Beginning function"
    }
    Process {
        if ( !$env:AWSPS_ENV_VAR_PATH ) {
            throw "Variable Path not defined. Run Initialize-AwsPs."
        }
        if ( ! ( Test-Path $env:AWSPS_ENV_VAR_PATH ) ) {
            throw "Module Variable config not found at destination '$env:AWSPS_ENV_VAR_PATH'. Re-Import module to create a new one."
        }
        if ( $Name ) {
            $variable_hash = Read-ModuleEnvVarFile
            $variable_hash[$Name] = $Value
        } else {
            $variable_hash = @{}
        }
        $variable_hash | ConvertTo-Json | Set-Content -Path $env:AWSPS_ENV_VAR_PATH -Force -PassThru | ForEach-Object { Write-Verbose "[$($MyInvocation.MyCommand)] $_" }

        Read-ModuleEnvVarFile -Import | Out-Null

        if ( $Passthru ) {
            try {
                Get-Item -Path "Env:$Name" -ErrorAction Stop
            }
            catch [System.Management.Automation.ItemNotFoundException] {
                Write-Warning "Variable Env:$Name Not found."
            }
            catch {
                throw $_
            }
        }
    }
}