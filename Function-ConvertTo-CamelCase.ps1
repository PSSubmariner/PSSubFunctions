<#
.Synopsis
   Converts supplied text into CamelCase
.DESCRIPTION
   Checks supplied text for the existence of spaces. If they exist, it will convert to Title Case and then replace spaces to create CamelCase
.EXAMPLE
   ConvertTo-Camelcase -TextString 'This is a sentence'

   This command will convert the provided text string to 'ThisIsASentence'
.EXAMPLE
   $CamelCase = ConvertTo-CamelCase 'Another value to convert'

   Converts value to 'AnotherValueToConvert'

.EXAMPLE
	ConvertTo-CamelCase -TextString 'Somethingelse'

    It will not convert this to 'SomethingElse' because I have no way to know that this is two words currently.
#>
function ConvertTo-CamelCase
{
	[CmdletBinding()]
	[OutputType([string])]
	Param
	(
		# String to convert to CamelCase
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[string[]]$TextString
	)
	
	Begin
	{
	}
	Process
	{
		Write-Verbose "CTCC:StartingValue: $TextString"
		foreach ($String in $TextString)
		{
			Write-Verbose "CTCC:Value of String to process: $String"
			If ($String.Contains(" "))
			{
				Write-Verbose "CTCC:String has space(s): '$String'"
				$TextInfo = (Get-Culture).TextInfo
				#                $TitleCase = $TextInfo.ToTitleCase($String.ToLower())
				#                Write-Verbose "CTCC:Title Case String: '$TitleCase'"
				#                $CamelCase = $TitleCase.Replace(" ","")
				#                Write-Verbose "CTCC:CamelCase String: '$CamelCase'"
				$String = $TextInfo.ToTitleCase($String.ToLower()).Replace(" ", "")
				Write-Verbose "CTCC:OneStepCamelCase String: '$String'"
				Write-Output $String
			}
			else
			{
				Write-Output $String
			} #end If String has space
		} #end ForEach TextString
	} #end Process
	End
	{
	}
}