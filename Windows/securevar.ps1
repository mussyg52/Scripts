$ldapPasswdEncrypted = Read-Host "Enter LDAP password for $($ldapUser)" -AsSecureString
$global:ldapUserPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ldapPasswdEncrypted))
echo "ldap password is '$ldapPasswordEncrypted'"
