# ClientCredGen

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Installation](#installation)
   - [Prerequisites](#prerequisites)
4. [RoadMap](#RoadMap)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [License](#license)
8. [Contact](#contact)

## Introduction
This project provides a secure solution for generating and storing client credentials in the database, specifically for use with the TMS API.

## Features
- **Environment File Handling**: Reads the connection string and encryption key from a `.env` file located in the project root.

- **IV Generation**: Utilizes OpenSSL to securely generate a 16-byte initialization vector (IV) for encryption.

- **Client Secret Generation**: Creates a secure 32-byte client secret using base64 encoding, then formats it for safe storage by replacing unsafe characters.

- **AES Encryption**: Encrypts the generated client secret using AES-256 encryption, with a dynamically generated encryption key and IV.

- **Asynchronous SQL Execution**: Executes database commands asynchronously for improved performance.

## RoadMap
- Implement encryption for sensitive data in memory

## Installation

### Prerequisites
- **PowerShell 7**: Make sure PowerShell 7 or a newer version is installed on your machine.
- **.NET 8**: Ensure .NET 8 or a later version is installed on your system.


## Usage
To start the project, execute the Generator.ps1 script.

## Configuration
To run this project, add the following environment variables to a `.env` file stored in the root directory:

    ```
    connString = "your connection string"
    Encryption__Key = "your encryption key"
    ```

## License
This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.

## Contact
If you have any questions or need further assistance, feel free to reach out via email:

- **Email**: seyiadeyemi34@outlook.com
