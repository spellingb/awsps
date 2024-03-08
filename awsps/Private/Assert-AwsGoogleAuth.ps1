Function Assert-AwsGoogleAuth {
    [CmdletBinding()]
    Param()
    Process {
        try {
            Get-Command -Name aws-google-auth -ErrorAction Stop | Out-Null
            return $true
        }
        catch {
            Write-Warning "[Assert] aws-google-auth not installed"
            Write-Warning "[Assert] Install using 'python3 -m pip install aws-google-auth'"
            Write-Warning "[Assert] Reference: https://github.com/cevoaustralia/aws-google-auth"
            return $false
        }
    }
}