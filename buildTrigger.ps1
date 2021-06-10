$username = 'geetika'
$token = '11a3a8cd0cd4ffb07c684cd757ada9e988'
$prevcommit = '0460ebd5f920394392508ca0a9b2f98640fa7315'
$latestcommit = '9d4807eafddc518a23e86497b08cc6f2f280872d'

# The header is the username and password concatenated together
$pair = "$($username):$($token)"
# The combined credentials are converted to Base 64
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
# The base 64 credentials are then prefixed with "Basic"
$basicAuthValue = "Basic $encodedCreds"
# This is passed in the "Authorization" header
$Headers = @{
    Authorization = $basicAuthValue
}
# Make a request to get a crumb. This will be returned as JSON
$json = Invoke-WebRequest -Uri 'http://localhost:8080/crumbIssuer/api/json' -Headers $Headers
# Parse the JSON so we can get the value we need
$parsedJson = $json | ConvertFrom-Json
# See the value of the crumb
Write-Host "The Jenkins crumb is $($parsedJson.crumb)"

# Extract the crumb filed from the returned json, and assign it to the "Jenkins-Crumb" header
$BuildHeaders = @{
    "Jenkins-Crumb" = $parsedJson.crumb
    Authorization = $basicAuthValue
}
Invoke-WebRequest -Uri "http://localhost:8080/job/SFDXsfpowerscript/buildWithParameters?PreviousCommitId=$prevcommit&LatestCommitId=$latestcommit" -Headers $BuildHeaders -Method Post
