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

## 0.0.5
### Added
- Initialization Vector (IV) Storage: The IV is now written at the start of the memory stream, allowing it to be stored directly within the encrypted data. This change simplifies retrieval and decryption.
- Completion Notification: Added a console message to notify users when the script completes execution, improving user feedback.

### Removed
- Parameterized IV: Removed the option to parameterize the IV, as the corresponding column has been removed from the database.
- IV Column in SQL Query: Eliminated the IV column from the SQL query to reflect the updated database schema.

### Fixed
- Simplified CreateEncryptor Parameters: Removed unnecessary parameters from the CreateEncryptor method. AES Key and IV are now set directly through their respective properties, streamlining the encryption setup.
