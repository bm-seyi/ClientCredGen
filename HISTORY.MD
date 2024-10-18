# 0.0.1
First Development Version

# 0.0.2
Resolved issues with the encryption implementation.

## 0.0.3
Resolved issues with uploading into the database.

## 0.0.4
### Added
- Generation of a unique clientID using [guid]::NewGuid().
- Writing of client information (name, ID, and secret) to a local file in the user's Downloads folder (clientsecret.txt).
- New SQL command field added for inserting the ID into the database, updating the INSERT INTO query to include the new clientID.

### Fixed
- The encryption key generation process for the client secret was streamlined. The secret is now generated in hex format, simplifying the logic.
- Added error handling for missing .env file with an exit command if the file isn't found.

### Notes
- The script now uses PKCS7 padding for AES encryption, ensuring better compatibility with the encrypted data format.
- The change in the INSERT INTO command now requires an additional column (ID) to be handled in the database schema.
