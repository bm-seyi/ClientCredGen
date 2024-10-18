$ClientName = (Read-Host -Prompt "Please Enter Client Name").ToUpper()

if (-not ($ClientName -match "^[a-zA-Z ]+$"))
{
    Write-Host "Input can only contain letters and spaces. Please try again."
    exit
}

$ClientName = $ClientName -replace " ", "_"

$EnvFilePath = Join-Path $PWD "\.env"

if (Test-Path $EnvFilePath -PathType Leaf) 
{
    $connString = (Get-Content -Path $EnvFilePath -TotalCount 1).Substring(12, 76)
    $encryptionKey = (Get-Content -Path $EnvFilePath -TotalCount 2)[-1].Substring(17, 64)
} 
else 
{
    Write-Host "Unable to locate .env in root"
    exit
}
    
$IV = openssl.exe rand -base64 16 
$clientSecret = openssl.exe rand -hex 32 | Out-String
$clientID = [guid]::NewGuid()

$downloadFile = [System.Environment]::GetFolderPath("UserProfile") + "\Downloads\clientsecret.txt"
Set-Content -Path $downloadFile -Value "Client Name: $ClientName`nID: $clientID`nClient Secret: $clientSecret"

$aes = [System.Security.Cryptography.Aes]::Create()

$aes.KeySize = 256
$aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

$encryptedIV = [System.Convert]::FromBase64String($IV)

$encryptor = $aes.CreateEncryptor([System.Convert]::FromHexString($encryptionKey), $encryptedIV)

# Encrypt the plaintext
$memoryStream = New-Object System.IO.MemoryStream
$cryptoStream = New-Object System.Security.Cryptography.CryptoStream($memoryStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$streamWriter = New-Object System.IO.StreamWriter($cryptoStream)

# Write plaintext to the stream
$streamWriter.Write($clientSecret)
$streamWriter.Close()  # This also closes cryptoStream and memoryStream

# Get encrypted data
$encryptedBytes = $memoryStream.ToArray()

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connString 
$connectionAsync = $connection.OpenAsync()
$connectionAsync.GetAwaiter().GetResult()

$command = $connection.CreateCommand()
$command.CommandText = @"
INSERT INTO [dbo].[Clients] ([ID], [name], [secret], [iv])  VALUES (@Value1, @Value2, @Value3, @Value4)
"@

$command.Parameters.Add("@Value1", [System.Data.SqlDbType]::UniqueIdentifier).Value = [guid]::Parse($clientID)
$command.Parameters.Add("@Value2", [System.Data.SqlDbType]::VarChar).Value = $ClientName
$command.Parameters.Add("@Value3", [System.Data.SqlDbType]::VarBinary).Value = $encryptedBytes
$command.Parameters.Add("@Value4", [System.Data.SqlDbType]::VarBinary).Value = $encryptedIV

$executeTask = $command.ExecuteNonQueryAsync()
$executeTask.GetAwaiter().GetResult()


