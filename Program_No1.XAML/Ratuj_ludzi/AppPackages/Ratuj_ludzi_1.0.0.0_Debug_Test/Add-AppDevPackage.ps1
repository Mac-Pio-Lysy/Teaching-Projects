#
# Add-AppxDevPackage.ps1 is a PowerShell script designed to install app
# packages created by Visual Studio for developers.  To run this script from
# Explorer, right-click on its icon and choose "Run with PowerShell".
#
# Visual Studio supplies this script in the folder generated with its
# "Prepare Package" command.  The same folder will also contain the app
# package (a .appx file), the signing certificate (a .cer file), and a
# "Dependencies" subfolder containing all the framework packages used by the
# app.
#
# This script simplifies installing these packages by automating the
# following functions:
#   1. Find the app package and signing certificate in the script directory
#   2. Prompt the user to acquire a developer license and to install the
#      certificate if necessary
#   3. Find dependency packages that are applicable to the operating system's
#      CPU architecture
#   4. Install the package along with all applicable dependencies
#
# All command line parameters are reserved for use internally by the script.
# Users should launch this script from Explorer.
#

# .Link
# http://go.microsoft.com/fwlink/?LinkId=243053

param(
    [switch]$Force = $false,
    [switch]$GetDeveloperLicense = $false,
    [string]$CertificatePath = $null
)

$ErrorActionPreference = "Stop"

# The language resources for this script are placed in the
# "Add-AppDevPackage.resources" subfolder alongside the script.  Since the
# current working directory might not be the directory that contains the
# script, we need to create the full path of the resources directory to
# pass into Import-LocalizedData
$ScriptPath = $null
try
{
    $ScriptPath = (Get-Variable MyInvocation).Value.MyCommand.Path
    $ScriptDir = Split-Path -Parent $ScriptPath
}
catch {}

if (!$ScriptPath)
{
    PrintMessageAndExit $UiStrings.ErrorNoScriptPath $ErrorCodes.NoScriptPath
}

$LocalizedResourcePath = Join-Path $ScriptDir "Add-AppDevPackage.resources"
Import-LocalizedData -BindingVariable UiStrings -BaseDirectory $LocalizedResourcePath

$ErrorCodes = Data {
    ConvertFrom-StringData @'
    Success = 0
    NoScriptPath = 1
    NoPackageFound = 2
    ManyPackagesFound = 3
    NoCertificateFound = 4
    ManyCertificatesFound = 5
    BadCertificate = 6
    PackageUnsigned = 7
    CertificateMismatch = 8
    ForceElevate = 9
    LaunchAdminFailed = 10
    GetDeveloperLicenseFailed = 11
    InstallCertificateFailed = 12
    AddPackageFailed = 13
    ForceDeveloperLicense = 14
    CertUtilInstallFailed = 17
    CertIsCA = 18
    BannedEKU = 19
    NoBasicConstraints = 20
    NoCodeSigningEku = 21
    InstallCertificateCancelled = 22
    BannedKeyUsage = 23
    ExpiredCertificate = 24
'@
}

function PrintMessageAndExit($ErrorMessage, $ReturnCode)
{
    Write-Host $ErrorMessage
    if (!$Force)
    {
        Pause
    }
    exit $ReturnCode
}

#
# Warns the user about installing certificates, and presents a Yes/No prompt
# to confirm the action.  The default is set to No.
#
function ConfirmCertificateInstall
{
    $Answer = $host.UI.PromptForChoice(
                    "", 
                    $UiStrings.WarningInstallCert, 
                    [System.Management.Automation.Host.ChoiceDescription[]]@($UiStrings.PromptYesString, $UiStrings.PromptNoString), 
                    1)
    
    return $Answer -eq 0
}

#
# Validates whether a file is a valid certificate using CertUtil.
# This needs to be done before calling Get-PfxCertificate on the file, otherwise
# the user will get a cryptic "Password: " prompt for invalid certs.
#
function ValidateCertificateFormat($FilePath)
{
    # certutil -verify prints a lot of text that we don't need, so it's redirected to $null here
    certutil.exe -verify $FilePath > $null
    if ($LastExitCode -lt 0)
    {
        PrintMessageAndExit ($UiStrings.ErrorBadCertificate -f $FilePath, $LastExitCode) $ErrorCodes.BadCertificate
    }
    
    # Check if certificate is expired
    $cert = Get-PfxCertificate $FilePath
    if (($cert.NotBefore -gt (Get-Date)) -or ($cert.NotAfter -lt (Get-Date)))
    {
        PrintMessageAndExit ($UiStrings.ErrorExpiredCertificate -f $FilePath) $ErrorCodes.ExpiredCertificate
    }
}

#
# Verify that the developer certificate meets the following restrictions:
#   - The certificate must contain a Basic Constraints extension, and its
#     Certificate Authority (CA) property must be false.
#   - The certificate's Key Usage extension must be either absent, or set to
#     only DigitalSignature.
#   - The certificate must contain an Extended Key Usage (EKU) extension with
#     Code Signing usage.
#   - The certificate must NOT contain any other EKU except Code Signing and
#     Lifetime Signing.
#
# These restrictions are enforced to decrease security risks that arise from
# trusting digital certificates.
#
function CheckCertificateRestrictions
{
    Set-Variable -Name BasicConstraintsExtensionOid -Value "2.5.29.19" -Option Constant
    Set-Variable -Name KeyUsageExtensionOid -Value "2.5.29.15" -Option Constant
    Set-Variable -Name EkuExtensionOid -Value "2.5.29.37" -Option Constant
    Set-Variable -Name CodeSigningEkuOid -Value "1.3.6.1.5.5.7.3.3" -Option Constant
    Set-Variable -Name LifetimeSigningEkuOid -Value "1.3.6.1.4.1.311.10.3.13" -Option Constant

    $CertificateExtensions = (Get-PfxCertificate $CertificatePath).Extensions
    $HasBasicConstraints = $false
    $HasCodeSigningEku = $false

    foreach ($Extension in $CertificateExtensions)
    {
        # Certificate must contain the Basic Constraints extension
        if ($Extension.oid.value -eq $BasicConstraintsExtensionOid)
        {
            # CA property must be false
            if ($Extension.CertificateAuthority)
            {
                PrintMessageAndExit $UiStrings.ErrorCertIsCA $ErrorCodes.CertIsCA
            }
            $HasBasicConstraints = $true
        }

        # If key usage is present, it must be set to digital signature
        elseif ($Extension.oid.value -eq $KeyUsageExtensionOid)
        {
            if ($Extension.KeyUsages -ne "DigitalSignature")
            {
                PrintMessageAndExit ($UiStrings.ErrorBannedKeyUsage -f $Extension.KeyUsages) $ErrorCodes.BannedKeyUsage
            }
        }

        elseif ($Extension.oid.value -eq $EkuExtensionOid)
        {
            # Certificate must contain the Code Signing EKU
            $EKUs = $Extension.EnhancedKeyUsages.Value
            if ($EKUs -contains $CodeSigningEkuOid)
            {
                $HasCodeSigningEKU = $True
            }

            # EKUs other than code signing and lifetime signing are not allowed
            foreach ($EKU in $EKUs)
            {
                if ($EKU -ne $CodeSigningEkuOid -and $EKU -ne $LifetimeSigningEkuOid)
                {
                    PrintMessageAndExit ($UiStrings.ErrorBannedEKU -f $EKU) $ErrorCodes.BannedEKU
                }
            }
        }
    }

    if (!$HasBasicConstraints)
    {
        PrintMessageAndExit $UiStrings.ErrorNoBasicConstraints $ErrorCodes.NoBasicConstraints
    }
    if (!$HasCodeSigningEKU)
    {
        PrintMessageAndExit $UiStrings.ErrorNoCodeSigningEku $ErrorCodes.NoCodeSigningEku
    }
}

#
# Performs operations that require administrative privileges:
#   - Prompt the user to obtain a developer license
#   - Install the developer certificate (if -Force is not specified, also prompts the user to confirm)
#
function DoElevatedOperations
{
    if ($GetDeveloperLicense)
    {
        Write-Host $UiStrings.GettingDeveloperLicense

        if ($Force)
        {
            PrintMessageAndExit $UiStrings.ErrorForceDeveloperLicense $ErrorCodes.ForceDeveloperLicense
        }
        try
        {
            Show-WindowsDeveloperLicenseRegistration
        }
        catch
        {
            $Error[0] # Dump details about the last error
            PrintMessageAndExit $UiStrings.ErrorGetDeveloperLicenseFailed $ErrorCodes.GetDeveloperLicenseFailed
        }
    }

    if ($CertificatePath)
    {
        Write-Host $UiStrings.InstallingCertificate

        # Make sure certificate format is valid and usage constraints are followed
        ValidateCertificateFormat $CertificatePath
        CheckCertificateRestrictions

        # If -Force is not specified, warn the user and get consent
        if ($Force -or (ConfirmCertificateInstall))
        {
            # Add cert to store
            certutil.exe -addstore TrustedPeople $CertificatePath
            if ($LastExitCode -lt 0)
            {
                PrintMessageAndExit ($UiStrings.ErrorCertUtilInstallFailed -f $LastExitCode) $ErrorCodes.CertUtilInstallFailed
            }
        }
        else
        {
            PrintMessageAndExit $UiStrings.ErrorInstallCertificateCancelled $ErrorCodes.InstallCertificateCancelled
        }
    }
}

#
# Checks whether the machine is missing a valid developer license.
#
function CheckIfNeedDeveloperLicense
{
    $Result = $true
    try
    {
        $Result = (Get-WindowsDeveloperLicense | Where-Object { $_.IsValid } | Measure-Object).Count -eq 0
    }
    catch {}

    return $Result
}

#
# Launches an elevated process running the current script to perform tasks
# that require administrative privileges.  This function waits until the
# elevated process terminates, and checks whether those tasks were successful.
#
function LaunchElevated
{
    # Set up command line arguments to the elevated process
    $RelaunchArgs = '-ExecutionPolicy Unrestricted -file "' + $ScriptPath + '"'

    if ($Force)
    {
        $RelaunchArgs += ' -Force'
    }
    if ($NeedDeveloperLicense)
    {
        $RelaunchArgs += ' -GetDeveloperLicense'
    }
    if ($NeedInstallCertificate)
    {
        $RelaunchArgs += ' -CertificatePath "' + $DeveloperCertificatePath.FullName + '"'
    }

    # Launch the process and wait for it to finish
    try
    {
        $AdminProcess = Start-Process "$PsHome\PowerShell.exe" -Verb RunAs -ArgumentList $RelaunchArgs -PassThru
    }
    catch
    {
        $Error[0] # Dump details about the last error
        PrintMessageAndExit $UiStrings.ErrorLaunchAdminFailed $ErrorCodes.LaunchAdminFailed
    }

    while (!($AdminProcess.HasExited))
    {
        Start-Sleep -Seconds 2
    }

    # Check if all elevated operations were successful
    if ($NeedDeveloperLicense)
    {
        if (CheckIfNeedDeveloperLicense)
        {
            PrintMessageAndExit $UiStrings.ErrorGetDeveloperLicenseFailed $ErrorCodes.GetDeveloperLicenseFailed
        }
        else
        {
            Write-Host $UiStrings.AcquireLicenseSuccessful
        }
    }
    if ($NeedInstallCertificate)
    {
        $Signature = Get-AuthenticodeSignature $DeveloperPackagePath -Verbose
        if ($Signature.Status -ne "Valid")
        {
            PrintMessageAndExit ($UiStrings.ErrorInstallCertificateFailed -f $Signature.Status) $ErrorCodes.InstallCertificateFailed
        }
        else
        {
            Write-Host $UiStrings.InstallCertificateSuccessful
        }
    }
}

#
# Finds all applicable dependency packages according to OS architecture, and
# installs the developer package with its dependencies.  The expected layout
# of dependencies is:
#
# <current dir>
#     \Dependencies
#         <Architecture neutral dependencies>.appx
#         \x86
#             <x86 dependencies>.appx
#         \x64
#             <x64 dependencies>.appx
#         \arm
#             <arm dependencies>.appx
#
function InstallPackageWithDependencies
{
    $DependencyPackagesDir = (Join-Path $ScriptDir "Dependencies")
    $DependencyPackages = @()
    if (Test-Path $DependencyPackagesDir)
    {
        # Get architecture-neutral dependencies
        $DependencyPackages += Get-ChildItem (Join-Path $DependencyPackagesDir "*.appx") | Where-Object { $_.Mode -NotMatch "d" }

        # Get architecture-specific dependencies
        if (($Env:Processor_Architecture -eq "x86" -or $Env:Processor_Architecture -eq "amd64") -and (Test-Path (Join-Path $DependencyPackagesDir "x86")))
        {
            $DependencyPackages += Get-ChildItem (Join-Path $DependencyPackagesDir "x86\*.appx") | Where-Object { $_.Mode -NotMatch "d" }
        }
        if (($Env:Processor_Architecture -eq "amd64") -and (Test-Path (Join-Path $DependencyPackagesDir "x64")))
        {
            $DependencyPackages += Get-ChildItem (Join-Path $DependencyPackagesDir "x64\*.appx") | Where-Object { $_.Mode -NotMatch "d" }
        }
        if (($Env:Processor_Architecture -eq "arm") -and (Test-Path (Join-Path $DependencyPackagesDir "arm")))
        {
            $DependencyPackages += Get-ChildItem (Join-Path $DependencyPackagesDir "arm\*.appx") | Where-Object { $_.Mode -NotMatch "d" }
        }
    }
    Write-Host $UiStrings.InstallingPackage

    $AddPackageSucceeded = $False
    try
    {
        if ($DependencyPackages.FullName.Count -gt 0)
        {
            Write-Host $UiStrings.DependenciesFound
            $DependencyPackages.FullName
            Add-AppxPackage -Path $DeveloperPackagePath.FullName -DependencyPath $DependencyPackages.FullName -ForceApplicationShutdown
        }
        else
        {
            Add-AppxPackage -Path $DeveloperPackagePath.FullName -ForceApplicationShutdown
        }
        $AddPackageSucceeded = $?
    }
    catch
    {
        $Error[0] # Dump details about the last error
    }

    if (!$AddPackageSucceeded)
    {
        if ($NeedInstallCertificate)
        {
            PrintMessageAndExit $UiStrings.ErrorAddPackageFailedWithCert $ErrorCodes.AddPackageFailed
        }
        else
        {
            PrintMessageAndExit $UiStrings.ErrorAddPackageFailed $ErrorCodes.AddPackageFailed
        }
    }
}

#
# Main script logic when the user launches the script without parameters.
#
function DoStandardOperations
{
    # List all .appx files in the script directory
    $PackagePath = Get-ChildItem (Join-Path $ScriptDir "*.appx") | Where-Object { $_.Mode -NotMatch "d" }
    $PackageCount = ($PackagePath | Measure-Object).Count

    # List all .appxbundle files in the script directory
    $BundlePath = Get-ChildItem (Join-Path $ScriptDir "*.appxbundle") | Where-Object { $_.Mode -NotMatch "d" }
    $BundleCount = ($BundlePath | Measure-Object).Count

    # List all .eappx files in the script directory
    $EncryptedPackagePath = Get-ChildItem (Join-Path $ScriptDir "*.eappx") | Where-Object { $_.Mode -NotMatch "d" }
    $EncryptedPackageCount = ($EncryptedPackagePath | Measure-Object).Count

    # List all .eappxbundle files in the script directory
    $EncryptedBundlePath = Get-ChildItem (Join-Path $ScriptDir "*.eappxbundle") | Where-Object { $_.Mode -NotMatch "d" }
    $EncryptedBundleCount = ($EncryptedBundlePath | Measure-Object).Count

    $NumberOfPackagesAndBundles = $PackageCount + $BundleCount + $EncryptedPackageCount + $EncryptedBundleCount

    # There must be exactly 1 package/bundle
    if ($NumberOfPackagesAndBundles -lt 1)
    {
        PrintMessageAndExit $UiStrings.ErrorNoPackageFound $ErrorCodes.NoPackageFound
    }
    elseif ($NumberOfPackagesAndBundles -gt 1)
    {
        PrintMessageAndExit $UiStrings.ErrorManyPackagesFound $ErrorCodes.ManyPackagesFound
    }

    if ($PackageCount -eq 1)
    {
        $DeveloperPackagePath = $PackagePath
        Write-Host ($UiStrings.PackageFound -f $DeveloperPackagePath.FullName)
    }
    elseif ($BundleCount -eq 1)
    {
        $DeveloperPackagePath = $BundlePath
        Write-Host ($UiStrings.BundleFound -f $DeveloperPackagePath.FullName)
    }
    elseif ($EncryptedPackageCount -eq 1)
    {
        $DeveloperPackagePath = $EncryptedPackagePath
        Write-Host ($UiStrings.EncryptedPackageFound -f $DeveloperPackagePath.FullName)
    }
    elseif ($EncryptedBundleCount -eq 1)
    {
        $DeveloperPackagePath = $EncryptedBundlePath
        Write-Host ($UiStrings.EncryptedBundleFound -f $DeveloperPackagePath.FullName)
    }
    
    # The package must be signed
    $PackageSignature = Get-AuthenticodeSignature $DeveloperPackagePath
    $PackageCertificate = $PackageSignature.SignerCertificate
    if (!$PackageCertificate)
    {
        PrintMessageAndExit $UiStrings.ErrorPackageUnsigned $ErrorCodes.PackageUnsigned
    }

    # Test if the package signature is trusted.  If not, the corresponding certificate
    # needs to be present in the current directory and needs to be installed.
    $NeedInstallCertificate = ($PackageSignature.Status -ne "Valid")

    if ($NeedInstallCertificate)
    {
        # List all .cer files in the script directory
        $DeveloperCertificatePath = Get-ChildItem (Join-Path $ScriptDir "*.cer") | Where-Object { $_.Mode -NotMatch "d" }
        $DeveloperCertificateCount = ($DeveloperCertificatePath | Measure-Object).Count

        # There must be exactly 1 certificate
        if ($DeveloperCertificateCount -lt 1)
        {
            PrintMessageAndExit $UiStrings.ErrorNoCertificateFound $ErrorCodes.NoCertificateFound
        }
        elseif ($DeveloperCertificateCount -gt 1)
        {
            PrintMessageAndExit $UiStrings.ErrorManyCertificatesFound $ErrorCodes.ManyCertificatesFound
        }

        Write-Host ($UiStrings.CertificateFound -f $DeveloperCertificatePath.FullName)

        # The .cer file must have the format of a valid certificate
        ValidateCertificateFormat $DeveloperCertificatePath

        # The package signature must match the certificate file
        if ($PackageCertificate -ne (Get-PfxCertificate $DeveloperCertificatePath))
        {
            PrintMessageAndExit $UiStrings.ErrorCertificateMismatch $ErrorCodes.CertificateMismatch
        }
    }

    $NeedDeveloperLicense = CheckIfNeedDeveloperLicense

    # Relaunch the script elevated with the necessary parameters if needed
    if ($NeedDeveloperLicense -or $NeedInstallCertificate)
    {
        Write-Host $UiStrings.ElevateActions
        if ($NeedDeveloperLicense)
        {
            Write-Host $UiStrings.ElevateActionDevLicense
        }
        if ($NeedInstallCertificate)
        {
            Write-Host $UiStrings.ElevateActionCertificate
        }

        $IsAlreadyElevated = ([Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value -contains "S-1-5-32-544")
        if ($IsAlreadyElevated)
        {
            if ($Force -and $NeedDeveloperLicense)
            {
                PrintMessageAndExit $UiStrings.ErrorForceDeveloperLicense $ErrorCodes.ForceDeveloperLicense
            }
            if ($Force -and $NeedInstallCertificate)
            {
                Write-Warning $UiStrings.WarningInstallCert
            }
        }
        else
        {
            if ($Force)
            {
                PrintMessageAndExit $UiStrings.ErrorForceElevate $ErrorCodes.ForceElevate
            }
            else
            {
                Write-Host $UiStrings.ElevateActionsContinue
                Pause
            }
        }

        LaunchElevated
    }

    InstallPackageWithDependencies
}

#
# Main script entry point
#
if ($GetDeveloperLicense -or $CertificatePath)
{
    DoElevatedOperations
}
else
{
    DoStandardOperations
    PrintMessageAndExit $UiStrings.Success $ErrorCodes.Success
}

# SIG # Begin signature block
# MIIhzAYJKoZIhvcNAQcCoIIhvTCCIbkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAnYmBUpv/sjF9s
# UpSJeaz8bsgho4m0HYf/wsPXcJL9raCCC1YwggTeMIIDxqADAgECAhMzAAABzLVb
# QhcHYBMRAAAAAAHMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMTcwOTEyMTgwNzA2WhcNMTgwOTEyMTgwNzA2WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCpkHWajIMyG+isxN7HWH5SZZnnaBLtBXRLEpiJMDY/cSmbclWZF6E+H3v0HvLo
# hCALULWOtm+3EjbVybEjYo5+Qi7pDLBgdmiHLEjUkxt8N5VlUIdpp9Apb4hl4pnC
# MAyXYLAap4sKZFjds1GyrnH2V08otBfl1mCwK4Z5KCtZ9Bu+XDn0tM38OzmQaRl/
# Z0xLO7qfWVUaBj/spPvlkKr+nungSu5JMg8xScKSzfkHNMcrADAQ/RDKGewkY+rd
# rYqT9caaCJQiz0KjQKdtzCxd1fFBx5N1yi9+K25guWjyqjBFNfnvkuF1JIlAXJ6m
# CZM33hi8CbRtRZpCwrlzMHGLAgMBAAGjggFdMIIBWTAfBgNVHSUEGDAWBgorBgEE
# AYI3PQYBBggrBgEFBQcDAzAdBgNVHQ4EFgQUWVXEgo8svduWnjnVL9Gj/TICsn8w
# NAYDVR0RBC0wK6QpMCcxDTALBgNVBAsTBE1PUFIxFjAUBgNVBAUTDTIzMDg2NSsy
# NDI0MDYwHwYDVR0jBBgwFoAU5vxfe7siAFjkck619CF0IzLm76wwVgYDVR0fBE8w
# TTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVj
# dHMvTWljQ29kU2lnUENBXzIwMTAtMDctMDYuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
# BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9N
# aWNDb2RTaWdQQ0FfMjAxMC0wNy0wNi5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEA0ZPuJ7HuV62ZGYwja2MQzDn3VRhyWDvxqbfO4MqWMFFTzJjw
# ElMYK+gamKQJtQHRI0ahePf/Zc5OWx5gLnN+sAl6SufXfXcCf9HFEYmwPzLthrfz
# EAnbjhHTVh30hVcCKf7quFG/Q+58VJ8fuZ3J4AwMThjQOPePqnDwKhu08ythe3CK
# Fu8799o79p+eLqW/hGUJJTmx0iAJ2rjZD+QnfUqDAXXsgnfQuaBDK6Y+pR71SwN0
# JYijYGIlzY069pEKGwO9Z0LJo6uak/16Wu5R1vmGbkznAFgsQ9P6RMgDHp/vxMzh
# zbDJ6/pdCNpHgVcRJ25xwcZPfkQIrxzuq5UOozCCBnAwggRYoAMCAQICCmEMUkwA
# AAAAAAMwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRl
# IEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwNjIwNDAxN1oXDTI1MDcwNjIwNTAxN1ow
# fjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMf
# TWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAOkOZFB5Z7XE4/0JAEyelKz3VmjqRNjPxVhPqaV2fG1F
# utM5krSkHvn5ZYLkF9KP/UScCOhlk84sVYS/fQjjLiuoQSsYt6JLbklMaxUH3tHS
# wokecZTNtX9LtK8I2MyI1msXlDqTziY/7Ob+NJhX1R1dSfayKi7VhbtZP/iQtCuD
# dMorsztG4/BGScEXZlTJHL0dxFViV3L4Z7klIDTeXaallV6rKIDN1bKe5QO1Y9Oy
# FMjByIomCll/B+z/Du2AEjVMEqa+Ulv1ptrgiwtId9aFR9UQucboqu6Lai0FXGDG
# tCpbnCMcX0XjGhQebzfLGTOAaolNo2pmY3iT1TDPlR8CAwEAAaOCAeMwggHfMBAG
# CSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTm/F97uyIAWORyTrX0IXQjMubvrDAZ
# BgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
# BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8E
# TzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
# dWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBM
# MEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRz
# L01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBnQYDVR0gBIGVMIGSMIGPBgkr
# BgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABl
# AGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJ
# KoZIhvcNAQELBQADggIBABp071dPKXvEFoV4uFDTIvwJnayCl/g0/yosl5US5eS/
# z7+TyOM0qduBuNweAL7SNW+v5X95lXflAtTx69jNTh4bYaLCWiMa8IyoYlFFZwjj
# Pzwek/gwhRfIOUCm1w6zISnlpaFpjCKTzHSY56FHQ/JTrMAPMGl//tIlIG1vYdPf
# B9XZcgAsaYZ2PVHbpjlIyTdhbQfdUxnLp9Zhwr/ig6sP4GubldZ9KFGwiUpRpJps
# yLcfShoOaanX3MF+0Ulwqratu3JHYxf6ptaipobsqBBEm2O2smmJBsdGhnoYP+jF
# HSHVe/kCIy3FQcu/HUzIFu+xnH/8IktJim4V46Z/dlvRU3mRhZ3V0ts9czXzPK5U
# slJHasCqE5XSjhHamWdeMoz7N4XR3HWFnIfGWleFwr/dDY+Mmy3rtO7PJ9O1Xmn6
# pBYEAackZ3PPTU+23gVWl3r36VJN9HcFT4XG2Avxju1CCdENduMjVngiJja+yrGM
# bqod5IXaRzNij6TJkTNfcR5Ar5hlySLoQiElihwtYNk3iUGJKhYP12E8lGhgUu/W
# R5mggEDuFYF3PpzgUxgaUB04lZseZjMTJzkXeIc2zk7DX7L1PUdTtuDl2wthPSrX
# kizON1o+QEIxpB8QCMJWnL8kXVECnWp50hfT2sGUjgd7JXFEqwZq5tTG3yOalnXF
# MYIVzDCCFcgCAQEwgZUwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMAIT
# MwAAAcy1W0IXB2ATEQAAAAABzDANBglghkgBZQMEAgEFAKCBwjAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgzqwaCX0QjcEocY9opGCsXU79tW/zLu1Bm6otXPLysWIw
# VgYKKwYBBAGCNwIBDDFIMEagLIAqAEEAZABkAC0AQQBwAHAARABlAHYAUABhAGMA
# awBhAGcAZQAuAHAAcwAxoRaAFGh0dHA6Ly9taWNyb3NvZnQuY29tMA0GCSqGSIb3
# DQEBAQUABIIBAFcndnQlRHOfKMcusesyIOnXq6VZSQ37nv5Hj+7OQh5ynYO8Hhhp
# J9ekfx4E+nhm9NuRZ0WzFm1Ups+QApGVj53wdIGYCeC8+a4wztaWCi6XCqda/DtQ
# VUU7r458+/1GGQPAlNVvpEoAAwd34Sjf2PH8ZgCOEGFI/8+D8NNZthSGmzKyUjW2
# NKS4JVuu5/wBuJ8kauHfNmkUgfDiFCA3OVHAEoZeIL4QoDiAXL6TL6rJobVVvaYc
# AtyGReTSjXb1YtGt/v8ueKnCDilkfCiUPCThba6PBNpB13TZo9Ys+vxs9V48fkTw
# QZfUxALs0bSceM1oocVJ69/GBwQH08mDVRuhghNCMIITPgYKKwYBBAGCNwMDATGC
# Ey4wghMqBgkqhkiG9w0BBwKgghMbMIITFwIBAzEPMA0GCWCGSAFlAwQCAQUAMIIB
# OQYLKoZIhvcNAQkQAQSgggEoBIIBJDCCASACAQEGCisGAQQBhFkKAwEwMTANBglg
# hkgBZQMEAgEFAAQgGY2BBegSvni/9ayUWJVzK0fChTbwkjUB7gcLBtHsoNQCBlp7
# NxjovBgTMjAxODAyMjIwOTM0NDcuMzMzWjAEgAIB9KCBuKSBtTCBsjELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoGA1UECxMDQU9DMScwJQYD
# VQQLEx5uQ2lwaGVyIERTRSBFU046NkJGNi0yRDUyLTkyQzExJTAjBgNVBAMTHE1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wggg7JMIIGcTCCBFmgAwIBAgIKYQmB
# KgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
# dGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1
# WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77Xxo
# SyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/xYIiEVEMM1024
# OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+BVLHPk0yS
# wcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3wV3WsvYpC
# TUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw2k4GkbaICDXoeByw6ZnN
# POcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHiMBAG
# CSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7fEYbxTNoWoVtVTAZ
# BgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
# BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8E
# TzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
# dWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBM
# MEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRz
# L01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/BIGVMIGSMIGP
# BgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0A
# TABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0w
# DQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+zwXi
# qf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtRgkQS+7lTjMz0YBKKdsxA
# QEGb3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl
# 2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon/VWvL/625Y4zu2Jf
# mttXQOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLh
# nPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/fmNZJQ96LjlXdqJx
# qgaKD4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/n
# MQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d9LiFAR6A+xuJ
# KlQ5slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffIrE7aKLixqduWsqdCosnP
# GUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV42neV8HR
# 3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+NR4Iuto229Nfj950
# iEkSMIIE2TCCA8GgAwIBAgITMwAAAKS9PcWWMx6JSwAAAAAApDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0xNjA5MDcxNzU2
# NTBaFw0xODA5MDcxNzU2NTBaMIGyMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMQwwCgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVT
# Tjo2QkY2LTJENTItOTJDMTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALArl8SblsYh
# NGrlxOUyti378z8/jRkWrGm/BuprGgWEKBQrfb1T31cfzER+taxp+Y14GtNomYZV
# kLrTLTKqnAgSfJSIJpK9pnoJfPdjNtaKE8EpLpZ3zYBESCfEx0acY+FTxac4C421
# uxIpTm3BmXxB4CoBKFdQ/5Airb9YJDTPTzGVrpaH0nqE5JXbNWWad08AhSDTTeeV
# xsECepF1sKTVyP3C2iJpun1io2+EiNEA6V5bre/BFtJjIV/+UJWi7Dfa6pozVJca
# R33Oy+xS3b21Bdpm1ZhTXdv054Agk9juyDUG6R7/H4eAk3cIitLNQA7iNUc3v6kK
# R25h/XVDmpcCAwEAAaOCARswggEXMB0GA1UdDgQWBBQubm5pcI6REi+/eiAMxbYB
# 1ILyxDAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBN
# MEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
# cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoG
# CCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
# Y1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQApmfYMdgYss4ZLVyNu4Okr
# UDNODGVyXH9m87X6/swTGoI3xkcsQU4DQ1NsIGF9PEuJ3ewL1eJUm6Xfhs2h+V0b
# z9aagNVUDPJTmFifnZKHzXWX+C0+ljcmaBEKs1JvyK0ZYsa4lDTn0GyhKr9m1UZ8
# NuzTJlAPCLfp7QDy8Z8grAQydMeOrspg4YPM4OGi0JH2c7mbmD4rGE8KXb7jZa1u
# PFfhliihYAoZFsWeXlfCLVe8mAcEhtE6iP0jg2wujNNcAscCupRhqRZoB42gxupY
# HcvQdfRdb4XPjBAzSSF4Izkq7J6rr5ZJHQfVs9kkfhGvs8Ui0SnNK2GpDbctG0hV
# oYIDczCCAlsCAQEwgeKhgbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xDDAKBgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
# RVNOOjZCRjYtMkQ1Mi05MkMxMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAGGBl/eii7PvRlJDm4l9hsD3P8B0
# oIHBMIG+pIG7MIG4MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MQwwCgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgTlRTIEVTTjozMjFBLTYx
# M0YtNDA2NTErMCkGA1UEAxMiTWljcm9zb2Z0IFRpbWUgU291cmNlIE1hc3RlciBD
# bG9jazANBgkqhkiG9w0BAQUFAAIFAN45CU8wIhgPMjAxODAyMjIwOTE4MDdaGA8y
# MDE4MDIyMzA5MTgwN1owczA5BgorBgEEAYRZCgQBMSswKTAKAgUA3jkJTwIBADAG
# AgEAAgEpMAcCAQACAhhkMAoCBQDeOlrPAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwG
# CisGAQQBhFkKAwGgCjAIAgEAAgMHoSChCjAIAgEAAgMehIAwDQYJKoZIhvcNAQEF
# BQADggEBAB498g392fHm4B4m1G2VUO1/Wh3eLpDJhfo6Vn+Xldpx/bpKz9EnHzIi
# 50D0H0zeQZhFalHL25DtGCHzH+Pm2ag9FwJxv3P5m8D60HsvuoQTPeMIj7OppPM0
# 6FVzOc/pnI4bxY/wttwGCkUdxjOaFVZUcRZ/OLRJLjFFw91l6ptrrWsxiw4T++TC
# XfvMajza8EeJsM1n0k9011KLqpwrnteMMYoPsKowArE6MiFFAUv3Rd7raee91wx0
# vclKFLodvGVfX9zWXBQfRBg1RA0yluS701yH3BohuleRqgoawtlw1aueJxH1zB92
# 0H/VStNNJkKA58f8cNmVYVItQnsNOYsxggL1MIIC8QIBATCBkzB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAKS9PcWWMx6JSwAAAAAApDANBglghkgB
# ZQMEAgEFAKCCATIwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3
# DQEJBDEiBCBd2tVKbBCo2jaWAD/6qUMf8lxebCXiQoO6xRMhkraE1DCB4gYLKoZI
# hvcNAQkQAgwxgdIwgc8wgcwwgbEEFGGBl/eii7PvRlJDm4l9hsD3P8B0MIGYMIGA
# pH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAACkvT3FljMeiUsA
# AAAAAKQwFgQUbs0P2GaKktru0s8/+Sl4YrldlbMwDQYJKoZIhvcNAQELBQAEggEA
# odNgK7QdjB0EVuRxe5uSNs6yAxgShZh0QCXzqaSsBn/0V22HCcTx074m3JlxlQwU
# nUboIfH6YgFYE6v97jidMphZISRgHHRU9C5qd9LKXcAnlsMb1YGR2ErYK/9GhjB5
# cQoEEQVo35M6G8bUPejSNUZjwNR+HeeO9HrtAmtoMgjv4r96LDHfDCDEdwG5mvVu
# ic/npUwqyPiqcyyb1Ikdl9OyoAwQCroKMVoODuziVNpqP/FWOlBR2blEmW2zq6Qz
# YH6M+rF/h5TukOfAey13BpYXY1Nxhz3XPJZeA4xzFNXS2U+2XDt0f5kLbX5I8Zy2
# TyWUDUd1dn5QoPXMem3LTQ==
# SIG # End signature block
