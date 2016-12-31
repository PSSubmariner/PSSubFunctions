<#
	.SYNOPSIS
		Removes a share from modern and legacy servers
	
	.DESCRIPTION
		When provided a share, it will remove the share using whatever method is necessary.
	
	.PARAMETER ShareName
		This should be the UNC path of the share to be removed. 
	
	.EXAMPLE
		PS C:\> Remove-PSSubShare -ShareName '\\servername\sharename'
	
	.NOTES
		This function will be part of the PSSubFileTools Module
#>
function Remove-PSSubShare
{
	[CmdletBinding(ConfirmImpact = 'Medium')]
	[OutputType([NullString])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[string]$ShareName
	)
	#$ShareName should be in the form \\servername\sharename
	#Capture the servername 
	$Server = $($ShareName.Split('\'))[2]
	Write-Verbose "Server: $Server"
	$Share = $($ShareName.Split('\'))[3]
	Write-Verbose "Share: $Share"
	#TODO: Added Test-Connection for server test
	If (Get-CimInstance -ComputerName $Server -ClassName 'Win32_Share' -Filter "Name = '$Share'")
	{
		Write-Verbose "Using Remove-SMBShare to delete $Share share from $Server"
		try { $session = New-CimSession -ComputerName $Server } #end Try CIMSession
		catch { Write-Warning -Message "Unable to establish CIM Session" } #end Catch CIMSession
		try
		{
			#TODO: Assumes that $session was established. Need to added check.
			Remove-SmbShare -ErrorAction Stop -Name "$Share" -CimSession $session
			return $true
		} #end Try Remove-SMBShare
		catch
		{
			Write-Warning "Unable to use Remove-SMBShare against $Server"
			try
			{
				Write-Verbose -Message "Attempting removal using CIM"
				If ($shared = Get-CimInstance -ComputerName $Server -ClassName 'Win32_Share' -Filter "Name = '$Share'")
				{
					Write-Verbose "Deleting $Share from $Server using CIM"
					$shared | Remove-CimInstance -ErrorAction Stop
					return $true
				} #end If CIMShareRemoval
				else
				{
					Write-Error -Message "I failed to establish a CIM connection to share but Try didn't throw (no ErrorAction defined)"
					#TODO: Handle the error in a better fashion
				} #end Else CIMShareRemoval
			} #end Try CIMShareRemoval
			catch
			{
				Write-Warning -Message "Failed with CIM. Removing the share with CIM over DCOM"
				$legacyServer = New-CimSession -ComputerName $Server -SessionOption (New-CimSessionOption -Protocol Dcom)
				If ($shared = Get-CimInstance -CimSession $legacyServer -ClassName 'Win32_Share' -Filter "Name = '$Share'")
				{
					Write-Verbose -Message "LegacyServer connection established over DCOM. Removing share."
					$shared | Remove-CimInstance
					return $true
				} #end If CIMLegacyShareRemoval
				else
				{
					Write-Error -Message "I failed to establish a CIM connection through CIMSession to share but Try didn't throw (no ErrorAction defined)"
					return $false
				} #end Else CIMLegacyShareRemoval
			} #end Catch CIMShareRemoval
		} #end Catch Remove-SMBShare
	} #end If CIMInstance
	else
	{
		Write-Warning -Message "CIM session did not work. Try Legacy connection"
		try
		{
			$legacyServer = New-CimSession -ComputerName $Server -SessionOption (New-CimSessionOption -Protocol Dcom) -ErrorAction Stop
			If ($shared = Get-CimInstance -CimSession $legacyServer -ClassName 'Win32_Share' -Filter "Name = '$Share'" -ErrorAction Stop)
			{
				Write-Verbose "Deleting $Share from $Server using CIM with DCOM"
				$shared | Remove-CimInstance -ErrorAction Stop
				return $true
			} #end If LegacyConnection
		} #end Try LegacyConnection
		catch
		{
			Write-Error -Message "I have no clue why this failed"
			return $false
		} #end Catch LegacyConnection
	} #end Else CIMInstance
} #end Function Remove-PSSubShare
#Remove-PSSubShare -ShareName '\\servername\sharename$' -Verbose
