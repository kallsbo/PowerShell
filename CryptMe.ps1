<#
.SYNOPSIS
  Encrypts or decrypts sensitive data like a API keyas the specified user.
  Decryption always run as the current user.
  Written by Kristofer Källsbo 2019
.PARAMETER PlainText
  Text to encrypt as the specified user.
.PARAMETER OutputFile
  File to output the encrypted information to.
.PARAMETER InputFile
  File to decrypt. If present all other parameters are ignored.
#>
[CmdletBinding()]
param (
    [string]$PlainText,
    [string]$OutputFile,
    [string]$InputFile
)

# Check if we have input and the file exists
if($PSBoundParameters.Keys.Contains('InputFile'))
{
    # Check that file exists
    if(!(Test-Path $InputFile -PathType Leaf)) { throw "Error: Input file not found!" };
    # Read file contents
    $filePass = ConvertTo-SecureString (Get-Content -Path $InputFile);
    # Decrypt the file and return it
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($filePass);
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR);
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR);

    return $UnsecurePassword;
}

# Check that we have text passed
if($PSBoundParameters.Keys.Contains('PlainText') -and $PSBoundParameters.Keys.Contains('OutputFile'))
{
    # Ask for credentials
    $cred = Get-Credential -Message 'Login as service account to encrypt';
    # Encrypt string with that credentials
    $encJob = Start-Job -ScriptBlock { Param($inputTxt); ConvertTo-SecureString $inputTxt -AsPlainText -Force | ConvertFrom-SecureString; } -ArgumentList $PlainText -Credential $cred;
    Wait-Job $encJob;
    $secPassword = Receive-Job -Job $encJob;
    # Write to output file
    $secPassword | Out-File -FilePath $OutputFile;
}
else
{
    throw "Error: Missing parameter!";
}

