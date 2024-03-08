Function Write-ModuleVariable {
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
        if ( !$env:AWSPS_VAR_PATH ) {
            throw "Variable Path not defined. Run Initialize-AwsPs."
        }
        if ( ! ( Test-Path $env:AWSPS_VAR_PATH ) ) {
            throw "Module Variable config not found at destination '$env:AWSPS_VAR_PATH'. Re-Import module to create a new one."
        }
        if ( $Name ) {
            $variable_hash = Read-ModuleVarFile
            $variable_hash[$Name] = $Value
        } else {
            $variable_hash = @{}
        }
        $variable_hash | ConvertTo-Json | Set-Content -Path $env:AWSPS_VAR_PATH -Force -PassThru | ForEach-Object { Write-Verbose "[$($MyInvocation.MyCommand)] $_" }

        Read-ModuleVarFile -Import -Scope Global | Out-Null

        if ( $Passthru ) {
            Get-Variable -Name $Name
        }
    }
}