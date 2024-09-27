$ClientName = (Read-Host -Prompt "Please Enter Client Name").ToUpper() -replace ' ', "_"

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

$encryptedIV = [System.Convert]::FromBase64String($IV)

$encryptor = $aes.CreateEncryptor([System.Convert]::FromHexString($encryptionKey), $encryptedIV)

$memoryStream = New-Object System.IO.MemoryStream

$cryptoStream = New-Object System.Security.Cryptography.CryptoStream ($memoryStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$streamWriter = New-Object System.IO.StreamWriter $cryptoStream
$streamWriter.Write($clientSecret)
$streamWriter.Flush()
$cryptoStream.FlushFinalBlock()
$encryptedBytes = $memoryStream.ToArray()

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connString 
$connectionAsync = $connection.OpenAsync()
$connectionAsync.GetAwaiter().GetResult()

$command = $connection.CreateCommand()
$command.CommandText = @"
INSERT INTO [dbo].[Clients] ([name], [secret], [iv])  VALUES (@Value1, @Value2, @Value3)
"@

$command.Parameters.Add("@Value1", [System.Data.SqlDbType]::VarChar).Value = $ClientName
$command.Parameters.Add("@Value2", [System.Data.SqlDbType]::VarBinary).Value = $encryptedBytes
$command.Parameters.Add("@Value3", [System.Data.SqlDbType]::VarBinary).Value = $encryptedIV

$executeTask = $command.ExecuteNonQueryAsync()
$executeTask.GetAwaiter().GetResult()


