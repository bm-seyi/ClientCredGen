$ClientName = (Read-Host -Prompt "Please Enter Client Name").ToUpper()

$EnvFilePath = Join-Path $PWD "\.env"
Write-Host $EnvFilePath

if (Test-Path $EnvFilePath -PathType Leaf) 
{
    $connString = (Get-Content -Path $EnvFilePath -TotalCount 1).Substring(12, 76)
    $encryptionKey = (Get-Content -Path $EnvFilePath -TotalCount 2)[-1].Substring(17, 64)
} 
else 
{
    Write-Host "Unable to locate .env in root"
}
    
    
$IV = openssl.exe rand -base64 16 

$clientSecret = (openssl.exe rand -base64 32 | Out-String).TrimEnd('=') -replace '\+', '-' -replace '/', '_' 

$aes = [System.Security.Cryptography.Aes]::Create()

$aes.KeySize = 256

Write-Host (Get-Content -Path $EnvFilePath -TotalCount 2)[-1].Substring(17, 64)

$encryptor = $aes.CreateEncryptor([System.Convert]::FromHexString((ConvertFrom-SecureString -SecureString $encryptionKey)), [System.Text.Encoding]::UTF8.GetBytes($IV))

$memoryStream = New-Object -TypeName IO.MemoryStream
$cryptoStream = New-Object -TypeName Security.Cryptography.CryptoStream -ArgumentList @($memoryStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$streamWriter = New-Object -TypeName System.IO -ArgumentList @($cryptoStream)
$streamWriter.Write((ConvertFrom-SecureString -SecureString $clientSecret))

Write-Host $memoryStream.ToArray()

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.OpenAsync() | Out-Null

$command = $connection.CreateCommand()
$command.CommandText = @"
INSERT INTO [dbo].[Clients] ([name], [secret], [iv])  VALUES ([],[],[])
"@


$executeTask = $command.ExecuteNonQueryAsync()

$executeTask.Wait()


