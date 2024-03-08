# private
Function Set-ProfileEnvironmentVariable {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        $Value,

        [Parameter()]
        [ValidateSet('User','System')]
        $Scope = 'User'
    )
    Process {
        switch ( $Scope ) {
            'User' {
                $profilePath = $PROFILE.CurrentUserAllHosts
            }
            'System' {
                $profilePath = $PROFILE.AllUsersAllHosts
            }
        }
        if ( ! ( Test-Path $profilePath ) ) {
            New-Item $profilePath -Force
        }

        $profileContent = ( Get-Content $profilePath )

        $matchString = "^\`$env\:$Name(\=|.+=).+"

        if ( $profileContent -match $matchString ) {
            ($profileContent -replace $matchString , "`$env:$Name = '$Value'") | Set-Content $profilePath
        } else {
            Add-Content -Value "`$env:$Name = '$Value'" -Force -Path $profilePath
            Add-Content -Value "Write-Verbose `"```$env:$Name = '`$env:$Name'`"" -Path $profilePath
        }
        # Test code to replace verbose line segment
        # $match_verbose_line = '\"\`\$env\:{0}.+\=.+\$env:{0}.+' -f $Name
        # if ( $profileContent -match $match_verbose_line ) {
        #     ( $profileContent -replace $match_verbose_line, "`"```$env:$Name = '`$env:$Name'`"") | Set-Content
        # }
    }
}


