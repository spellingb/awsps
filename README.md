# AWSPS

holds aws ps wrapper module and accompanying scripts

## Usage

### Initilize Google SSO

``` powershell
$splat = @{
    GoogleIDPID = 'Abc123de4'
    GoogleSPID = '123456789012'
    GoogleRoleArn = 'arn:aws:iam::123456789012:role/MyRole'
    GoogleRoleDuration = '28800'
    ProfileName = 'default'
    Region = 'us-east-1'
    GoogleConnectionMethod = 'aws-google-auth'
    GoogleUserName = 'john.doe@google.com'
}
Initialize-AwsPs @splat

```

### Connect to AWS Environment

``` powershell
    # Assuming you setup defaults with `Initialize-AwsPs` then you do not need to specify parameters
    Connect-AwsSso

```


### Set Profile

``` powershell
    Set-AwsDefaultProfile -ProfileName MyProfile2
    # or
    sprofile MyProfile2
```

### Get Current Working Account

``` powershell
    Get-CurrentAccountContext
    # or
    awspwd
```
