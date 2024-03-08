# install
Param (
    $AWSToolsInstallerVerion = '1.0.2.5',
    $AWSToolsModulesVersion = '4.1.530'
)

Begin {
    $AWSModules = @{
        Name = @(
            "AWS.Tools.Account"
            "AWS.Tools.Common"
            "AWS.Tools.EC2"
            "AWS.Tools.EC2InstanceConnect"
            "AWS.Tools.IdentityManagement"
            "AWS.Tools.RDS"
            "AWS.Tools.S3"
            "AWS.Tools.SecurityToken"
            "AWS.Tools.SimpleSystemsManagement"
            "AWS.Tools.SSO"
            "AWS.Tools.SSOOIDC"
            "AWS.Tools.IdentityManagement"
            "AWS.Tools.ConfigService"
            "AWS.Tools.FSx"
            "AWS.Tools.ElasticLoadBalancing"
            "AWS.Tools.ElasticLoadBalancingV2"
            "AWS.Tools.CostExplorer"
            "AWS.Tools.CloudWatchLogs"
        )
        Cleanup = $false
        Force = $true
        MinimumVersion = $awsModulesVersion
    }
}
Process {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    $awsInstaller = Get-Module -Name AWS.Tools.Installer -ListAvailable -ErrorAction SilentlyContinue

    if ( !$awsInstaller ) {
        Install-Module -Name AWS.Tools.Installer -MinimumVersion $AWSToolsInstallerVerion -Scope CurrentUser -Force
    }

    Install-AWSToolsModule @AWSModules

    Write-warning "Install Complete. Restart Powershell to complete setup."
}
