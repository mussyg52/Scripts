[CmdletBinding(DefaultParameterSetName="usingSpreadsheet")]
param (
  # The VMWare env being built into is needed in both Parameter Sets
  [Parameter(ParameterSetName="spreadsheetSettings", Mandatory=$true)]
  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [ValidateSet('BRSAPP', 'systest', 'syst', 'BRSPP', 'pp', 'preprod', 'SCCOLD', 'SCC', 'prod', 'GIBOLD', 'GIB', 'CAN', ignorecase=$true)]
  [string]$vmwareEnv,

  # Parameter Set #1; providing all the information in a spreadsheet
  [Parameter(ParameterSetName="spreadsheetSettings", Mandatory=$true, Position=0)]
  [ValidateNotNullOrEmpty()]
  [string]$spreadsheetFileName,

#  [Parameter(ParameterSetName="spreadsheetSettings", Mandatory=$true)]
#  [ValidateSet('BRSAPP', 'BRSPP', 'SCC', 'GIB', 'CAN', ignorecase=$true)]
#  [string]$vmwareEnv,



  # Parameter Set #2; providing all the information on the command line
  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$serverName,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$serviceNowTicket,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$serverRoleDescription,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [ValidateSet('prod', 'pte', 'pp1', 'pp2', 'pp3', 'systest', 'dr', ignorecase=$true)]
  [string]$pxeEnvironment,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [ValidateSet('rhel5', 'rhel6', 'rhel7', '2012r1', '2012r2', ignorecase=$true)]
  [string]$pxeOS = "rhel6",

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [ValidateSet('basic-rh6', 'basic-rh6-e2', 'basic-rh6-link', 'basic-rh6-nogrow', 'basic-rh6-noupdate', 'basic-rh6-sharepath', 'basic-rh7', 'basic-rh7-vanilla', 'basic-2012r1', 'basic-2012r2', ignorecase=$true)]
  [string]$pxeKsConfFile = "basic-rh6",

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$pxeVmSize,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$pxeVmTypescript,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$ipMGMT,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$false)]
  [string]$ipFRONT,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$false)]
  [string]$ipBACK,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$hddSize,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$false)]
  [string]$hddSize2,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$numCpus,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$numCpuCores,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$ramSize,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$vmwareCluster,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$vmwareFolder,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$vmwareGuest,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [string]$vmwareStorage,

  [Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
  [ValidateSet("thin", "thick", ignorecase=$true)]
  [string]$vmwareDiskProvision = "thin"

#  ,[Parameter(ParameterSetName="commandLineSettings", Mandatory=$true)]
#  [string]$foo2
)
#
# NB command line validation functions are:
#	ValidateNotNullOrEmpty()
#	ValidateNotNull()
#	ValidateLength(1,8)
#	ValidateRange(10,99)
#	ValidateCount()
#	ValidateSet('Bob','Joe','Steve', ignorecase=$False)
#	ValidatePattern()
#	ValidateScript()

# Validate that the version of Powershell being used is modern enough
if ( [System.Version]$PSVersionTable.PSVersion -lt [System.Version]"4.0" )
{
  write-host "ERROR: you are running an older version of PowerShell, please update to at least v4.0"
  exit(1)
}
#else
#{
#  write-host "INFO: you are running a modern version of PowerShell"
#}

#if ($PSCmdlet.ParameterSetName -eq "spreadsheetSettings" )
#{
#  echo "hello"
#}

switch ($PSCmdlet.ParameterSetName)
{
  "spreadsheetSettings"
  {
    Write-Host "Spreadsheet is '${spreadsheetFileName}'"
    if ( !(Test-Path -Path $spreadsheetFileName) )
    {
      write-host "ERROR: spreadsheet '$($spreadsheetFileName)' does not exist"
      exit(1)
    }
  }

  "commandLineSettings"
  {
    # The code in CommonCode-Excel.ps1 builds a spreadsheet like this
    # so this is what we do to "emulate" it and allow the main code to 
    # work irrespective of whether the information comes from the command
    # line or from a spreadsheet

    $singleServer = @{} # hash table
    $vmDetail = @{} # hash table
    $vmDetail['Server Name'] = ${serverName};
    $vmDetail['Build'] = 'yes'; # constant to comply with what is in spreadsheet
    $vmDetail['Service Now'] = ${serviceNowTicket};
    $vmDetail['Server Role'] = ${serverRoleDescription};
    $vmDetail['PXE Env'] = ${pxeEnvironment};
    $vmDetail['PXE OS'] = ${pxeOS};
    $vmDetail['PXE Kickstart Configfile'] = ${pxeKsConfFile};
    $vmDetail['PXE vm size'] = ${pxeVmSize};
    $vmDetail['PXE typescript'] = ${pxeVmTypescript};
    $vmDetail['Eth0 (mgmt)'] =  ${ipMGMT};
    $vmDetail['Eth1 (front)'] = ${ipFRONT};
    $vmDetail['Eth2 (back)'] = ${ipBACK};
    $vmDetail['HDD Size (MB)'] = ${hddSize};
    $vmDetail['HDD2 Size (MB)'] = ${hddSize2};
    $vmDetail['CPUs'] = ${numCpus};
    $vmDetail['CPU Cores'] = ${numCpuCores};
    $vmDetail['RAM (MB)'] = ${ramSize};
    $vmDetail['VMware Cluster'] = ${vmwareCluster};
    $vmDetail['VMware Folder'] = ${vmwareFolder};
    $vmDetail['VMware Guest'] = ${vmwareGuest};
    $vmDetail['VMware storage'] = ${vmwareStorage};
    $vmDetail['Vmware Disk Provision'] = ${vmwareDiskProvision};
#$vmDetail | FL;
    $singleServer[$vmDetail['Server Name']] = $vmDetail;


#    foreach($x in $singleServer.GetEnumerator())
#    {
#      write-host "DEBUG: Hash Name is $($x.Name)";
#      Write-Host "DEBUG: Server name is $($x.Value['Server Name'])"
#      write-host "DEBUG: Build is $($x.Value['Build'])";
#      #$x.Value | FL
#      #$x.Value['Server Name'] | FL
#      #write-host "-------------"
#    }
  }
}

$CmdDir = Split-Path $MyInvocation.MyCommand.Path

# Load all the shared configuration and functions
. "$CmdDir\CommonCode-Global.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure


$currentUserDomain = $env:userdomain # e.g. WHGROUP
$currentUserName = $env:username # e.g. vgavin
$currentUserFullname = (Get-ADUser -Filter {SamAccountName -eq $currentUserName} |Select-Object name).name 

$vCentreUser = $currentUserDomain + '\' + $currentUserName
$vCentrePasswdEncrypted = Read-Host "Enter vCentre password for $($vCentreUser)" -AsSecureString
$vCentreUserPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($vCentrePasswdEncrypted))
#echo "vcentre password is '$vcentreUserPassword'"
#echo "vcentre user is '$vCentreUser'"

$global:ldapUser = $currentUserName
if ( $ldapMappings.containsKey($vCentreUser) )
{
  # There are a few accounts where the LDAP name doesn't match the AD name
  # these are catered for using a custom lookup table in CommonCode-Globals.ps1

  #echo "mapping exists"
  #echo $ldapMappings.Get_Item($vCentreUser)
  $ldapUser = $ldapMappings.Get_Item($vCentreUser)
}

$ldapPasswdEncrypted = Read-Host "Enter LDAP password for $($ldapUser)" -AsSecureString
$global:ldapUserPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ldapPasswdEncrypted))
#echo "ldap password is '$ldapUserPassword'"

switch ( $vmwareEnv.ToLower() )
{
  {($_ -eq 'brsapp') -or ($_ -eq 'systest') -or ($_ -eq 'syst')} # crappy syntax for multiple value match within a switch!
  {
    #$vCentre = "10.210.134.10" # brsapprevc01 -- retired
    $vCentre = "10.210.134.253" # brsprapvc01
  }

  {($_ -eq 'brspp') -or ($_ -eq 'pp') -or ($_ -eq 'preprod')} # crappy syntax for multiple value match within a switch!
  {
    #$vCentre = "10.201.226.15" # brsppvc01 -- retired
    $vCentre = "10.201.226.253" # brsppapvc01
  }

  {($_ -eq 'scc') -or ($_ -eq 'prod')} # crappy syntax for multiple value match within a switch!
  {
    #$vCentre = "10.120.134.10" # sc1wnprevc01 -- retired
    $vCentre = "10.120.134.253" # sc1prapvc01
  }

  'sccold'
  {
    $vCentre = "10.120.134.10" # sc1wnprevc01 -- retired
  }

  'gibold'
  {
    $vCentre = "10.180.138.10" # gibapprevc01 -- retired
  }

  'gib'
  {
    # $vCentre = "10.180.138.10" # gibapprevc01 -- retired
    $vCentre = "10.180.138.15" # gibprapvc01
  }

  'can'
  {
    #$vCentre = "10.220.138.10" # canapprevc01 -- retired
    $vCentre = "10.220.138.15" # canprapvc01
  }

  default
  {
    write-host "ERROR: invalid VMware environment setting of '$($vmwareEnv)'"
    exit(1)
  }
}





# Load all the Excel shared config and functions
. "$CmdDir\CommonCode-Excel.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure

# Load all the PuTTY shared config and functions
. "$CmdDir\CommonCode-Putty.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure

# Load all the Folders/Directory shared config and functions
. "$CmdDir\CommonCode-Folders.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure

# Load all the TCP/IP v4 Common Internet Data Representation shared config and functions
. "$CmdDir\CommonCode-IP4-CIDR.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure

# Load all the VMWare shared config and functions
. "$CmdDir\CommonCode-VMware.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure

# Load all the Rundeck shared config and functions
. "$CmdDir\CommonCode-Rundeck.ps1"; if ( $SharedScriptConfigExit ) { exit } # abort on failure


# Validate that the version of PowerCLI being used is modern enough
$PC_Version = Get-PowerCLIVersion
# Write-host "INFO: major='$($PC_Version.Major)', minor='$($PC_Version.Minor)', build='$($PC_Version.Build)'" 

# Build a version string that can be used by the "System.Version" module for comparison.
#
# The provided string in $PC_Version.UserFriendlyVersion isn't parseable ('VMware vSphere PowerCLI 5.8 Release 1 build 2057893')

$PowerCLI_Version = "$($PC_Version.Major).$($PC_Version.Minor).$($PC_Version.Build)" 

if ( [System.Version]$PowerCLI_Version -lt [System.Version]"5.8" )
{
  write-host "ERROR: you are running an older version of PowerCLI, please update to at least v5.8"
  exit(1)
}






#------------------------------------------------------------------------------
## Load some additional settings based upon the vCentre being used for this work
$buildServerAddress, $pxe_server_gateway = getVmwareSettings($vCentre)

#------------------------------------------------------------------------------
# check that the PuTTY/Plink key has been stored so that connections don't hang
# waiting for a Y/N response to the "shall I save" question
# NB doesn't return if the key hasn't been stored
puttyCheckHostKeyLoaded $buildServerAddress
write-host "INFO: key check for $buildServerAddress passed"

#------------------------------------------------------------------------------
# TODO: PXE config directory is hard coded in this check and in CommonCode-VMware.ps1, should it be a constant defined in one place???
# Check that the pxelinux.cfg folder is writeable
# Note, allow ServerOps access to directory using 'setfacl -m g:ServerOps:rwx /tftpboot/pxelinux.cfg'

#write-host "DEBUG: build server is $buildServerAddress"
#write-host "DEBUG: ldap user is $ldapUser"
#write-host "DEBUG: ldap password is $ldapUserPassword"
$writeTestStatus = plink -remoteHost $buildServerAddress -login $ldapUser -passwd $ldapUserPassword -command 'test -w /tftpboot/pxelinux.cfg ; echo $?' | Out-String

# value of 0 means writeable, value of 1 means read-only
if ( $writeTestStatus.trim() -ne '0' )
{
  write-host "ERROR: PXE config directory on '$($buildServerAddress)' cannot be written to"
  write-host "Try 'setfacl -m g:ServerOps:rwx /tftpboot/pxelinux.cfg' on the server"

  write-host ""
  write-host "Response from remote server was '$writeTestStatus'"
  write-host "Expected response was '0'"
  exit 1
}
else
{
  write-host "INFO: PXE config directory on '$($buildServerAddress)' is writeable"
}


#------------------------------------------------------------------------------
# Connect to the vCentre so that the VMs can be built
write-host "Connecting to vCentre Server $vCentre" -foreground DarkGreen
try
{
  # Need "ErrorAction Stop" so that try/catch works!
  # "WarningAction 0" is to suppress warnings about certificates etc
  Connect-viserver	$vCentre			`
  			-user $vCentreUser		`
			-password $vCentreUserPassword	`
			-WarningAction 0		`
			-ErrorAction Stop | Out-Null
}
catch
{
  write-host "Failed to connect to '${vCentre}' as '${vCentreUser}'"
  exit 1
}

#------------------------------------------------------------------------------
# Load a list of servers to build from an Excel spreadsheet
if ($PSCmdlet.ParameterSetName -eq "spreadsheetSettings" )
{
  $serversToBuild = detailsFromExcel $spreadsheetFileName
}
elseif ($PSCmdlet.ParameterSetName -eq "commandLineSettings" )
{
  $serversToBuild = $singleServer
}
else
{
  Write-Host "ERROR: unexpected parameter set, aborting";
  exit(1);
}

#Get-VirtualPortGroup | FT
#Get-VDPortgroup | FT
#exit

#------------------------------------------------------------------------------
write-host "`n`nINFO: finding servers to build`n`n"
foreach($x in $serversToBuild.GetEnumerator())
{
  if ( $x.Value['Build'] -ne 'yes' )
  {
    write-host "INFO: BUILD is '$($x.Value['Build'])"
    write-host "INFO: $($x.Name) is flagged to not be built, skipping"
    continue
  }

  if ( $x.Name.Contains(".") )
  {
    Write-Host "`n`nERROR: hostname '$($x.Name)' contains a dot indicating an FQDN, please use short names only, skipping...`n`n";
    continue
  }

  # TODO: build the "create_vm" command from the contents of the 
  write-host "Building '$($x.Name)': $($x.Value['Service Now'])"
  #$x.Value | FT ;# use this top dump all the values out

  $VM_NIC = @{}
#  if ( $x.Value.ContainsKey('Eth0 (mgmt)') )
#  {
#    write-host "DEBUG: String length is $($x.Value['Eth0 (mgmt)'].length)"
#  }


  $x.Value['Rundeck - FQDN'] = '';
  if ( $x.Value.ContainsKey('Eth0 (mgmt)') -and $x.Value['Eth0 (mgmt)'].length -gt 0 )
  {
    #write-host "DEBUG: found management network"
    $VM_NIC['mgmt'] = $x.Value['Eth0 (mgmt)']

    # if there are two interfaces then this is the management interface
    # if there isn't a second interface then this is the app interface
    if ( $x.Value.ContainsKey('Eth1 (front)') -and $x.Value['Eth1 (front)'].length -gt 0 )
    {
      $fqhostname = "$($x.Name).mgmt.$($x.Value['PXE Env']).williamhill.plc"
    }
    else
    {
      $fqhostname = "$($x.Name).$($x.Value['PXE Env']).williamhill.plc"
    }

    $x.Value['Rundeck - FQDN'] = $fqhostname;

    write-host "INFO: Checking $($fqhostname) in DNS..."
    $dnsResult = checkDns $fqhostname $VM_NIC['mgmt']
    if ( -not $dnsResult )
    {
      # ignore this server
      $x.Value['Build'] = 'no'

      write-host "ERROR: ignoring this server, try rebuilding after the DNS issue has been resolved"
      continue
    }
  }

  if ( $x.Value.ContainsKey('Eth1 (front)') -and $x.Value['Eth1 (front)'].length -gt 0 )
  {
    #write-host "DEBUG: found front network"
    $VM_NIC['front'] = $x.Value['Eth1 (front)']

    $fqhostname = "$($x.Name).$($x.Value['PXE Env']).williamhill.plc"

    if ( $x.Value['Rundeck - FQDN'].length -eq 0 )
    {
      $x.Value['Rundeck - FQDN'] = $fqhostname;
    }


    write-host "INFO: Checking $($fqhostname) in DNS..."
    $dnsResult = checkDns $fqhostname $VM_NIC['front']
    if ( -not $dnsResult )
    {
      # ignore this server
      $x.Value['Build'] = 'no'

      write-host "ERROR: ignoring this server, try rebuilding after the DNS issue has been resolved"
      continue
    }
  }

  if ( $x.Value.ContainsKey('Eth2 (back)') -and $x.Value['Eth2 (back)'].length -gt 0 )
  {
    #write-host "DEBUG: found back network"
    $VM_NIC['back'] = $x.Value['Eth2 (back)']

    $fqhostname = "$($x.Name).back.$($x.Value['PXE Env']).williamhill.plc"
    write-host "INFO: Checking $($fqhostname) in DNS..."
    $dnsResult = checkDns $fqhostname $VM_NIC['back']
    if ( -not $dnsResult )
    {
      # ignore this server
      $x.Value['Build'] = 'no'

      write-host "ERROR: ignoring this server, try rebuilding after the DNS issue has been resolved"
      continue
    }
  }

  #write-host "DEBUG: NIC settings are:"; $VM_NIC | FT

  if ( $x.Value['Rundeck - Add'] -eq 'yes' )
  {
    write-host "INFO: Checking for presence in Rundeck..."
 
    #write-host "DEBUG: FQDN is : '$($x.Value['Rundeck - FQDN'])'"; 
    if ( $x.Value['Rundeck - FQDN'].length -eq 0 )
    {
      write-host "ERROR: Rundeck check failed, '$($x.Name)' can't work out the FQDN"

      # ignore this server
      $x.Value['Build'] = 'no'

      write-host "ERROR: ignoring this server, try rebuilding after the FQDN issue has been resolved"
      continue
    }

    $rundeckResult = rundeck_check $x.Name $fqhostname $x.Value
    if ( $rundeckResult[0] -ne 0 )
    {
      write-host "ERROR: Rundeck check failed, '$($x.Name)' or '$($VM_NIC['mgmt'])' are already registered, error message was"
      write-host $rundeckResult[1]


      # ignore this server
      $x.Value['Build'] = 'no'

      write-host "ERROR: ignoring this server, try rebuilding after the rundeck issue has been resolved"
      continue
    }
  }


  try
  {
    create_vm	-virtualMachineName 		$x.Value['Server Name']		`
  		-virtualMachineDescription	$x.Value['Server Role']		`
  		-virtualMachineNetwork		$VM_NIC			`
  		-numberOfCpus			$x.Value['CPUs']		`
  		-numberOfCpuCores		$x.Value['CPU Cores']		`
  		-memoryInMegabytes		$x.Value['RAM (MB)']			`
  		-diskSpaceInMegabytes		$x.Value['HDD Size (MB)']		`
  		-diskType			$x.Value['Vmware Disk Provision']		`
  		-guestOperatingSystem		$x.Value['VMware Guest']		`
  		-dataStore			$x.Value['VMware storage']			`
  		-vcentreFolder			$x.Value['VMware Folder']			`
  		-vcentreClusterName		$x.Value['VMware Cluster']		`
  		-pxeEnvironment			$x.Value['PXE Env']		`
  		-pxeOperatingSystem		$x.Value['PXE OS']			`
  		-pxeKickstartConfigFile		$x.Value['PXE Kickstart Configfile']		`
  		-pxeBuildServer			$buildServerAddress	`
  		-ldapUserName			$ldapUser		`
  		-ldapUserPassword		$ldapUserPassword	`
  		-serviceNowTicket		$x.Value['Service Now']
  }
  Catch
  {
    Write-Host "ERROR: create VM failed" -ForegroundColor Red
    Write-Host $_.Exception | Format-List
    exit(1);
  }


# The problem with the VMWareGuestHarden script is that it waits for manual
# confirmation that it is okay to proceed by using the read-host cmdlet.
# Which means we cannot pipe the response to it :-(
#
# I can use SendKeys() to feed the response to the current window but that
# means this script would have to be running in a separate thread and the
# harden script running in the foreground.
# Which is a bit tricky to set create and co-ordinate
#
#	$wshell = New-Object -ComObject wscript.shell;
#	$wshell.SendKeys('helo');
# 
# So for the moment, just leave it to the user to type OK
# OR edit the script and remove the prompt

  # Harden the VM before we start it up for the first time
  write-host "INFO: hardening $($x.Name)"
  & $CmdDir\VMwareGuestHarden_v2.3.ps1 $x.Value['Server Name'].Trim()
  #.\VMwareGuestHarden_v2.3.ps1 $x.Value['Server Name'].Trim()

  # TODO: start the VM if the pxelinux.cfg file has been created OK
  write-host "Power On of the  VM $VM_name initiated"  -foreground yellow
  Start-VM -VM $x.Value['Server Name'] -confirm:$false -RunAsync

# TODO: finish off the post build stage, re-trunking server and updating VMware tools
# need a way to know that build has finished (see test6c.ps1 for current attempts)
#new  postBuild_ReconfigureVM	-virtualMachineName 		$x.Value['Server Name']		`
#new  				-virtualMachineNetwork		$VM_NIC	

}


# Now all the servers have been created and powered on we need to wait for the
# PXE build to complete.
#
# When it has finished we need to re-trunk the first NIC so that it is on the
# correct network, rather than on the BUILD network
#
# Unfortunately there isn't an easy way to work out when the PXE build has
# completed.
# You can't ping the server coz ETH1 is disconnected and ETH0 is on the build network
# Best I can think of is to submit some VMCLI client requests to see if ...???

Disconnect-VIServer -Confirm:$False
