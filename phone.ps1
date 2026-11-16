# عنوان الجوال هو بوابة شبكة الواي فاي
$ip = (Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
    Select-Object -First 1).IPv4DefaultGateway.NextHop

Write-Host "Connecting to $ip ..."
adb connect "${ip}:5555"
adb devices