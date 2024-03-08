Function Assert-AwsSamlAuth {
    [CmdletBinding()]
    Param()
    Process {
        try {
            Get-Command -Name aws-saml-auth -ErrorAction Stop | Out-Null
            return $true
        }
        catch {
            Write-Warning "[Assert] aws-saml-auth not installed"
            Write-Warning "[Assert] Install using 'python3 -m pip install aws-saml-auth'"
            Write-Warning "[Assert] Reference: https://github.com/ekreative/aws-saml-auth"
            return $false
        }
    }
}