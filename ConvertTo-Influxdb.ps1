param(
	[Parameter(Mandatory=$True)]
	[ValidateScript({Test-Path $_})] 
	[string]$Path,
	[Parameter(Mandatory=$True)]
	[string]$Database
)

$Csv = Import-Csv -Path $Path

$Header = $Csv | Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name'

$MeasurementColumn = 'name'
$TimeColumn = 'time'
$TagColumnsArray = @()
$ValueColumnsArray = @()

foreach($Line in $Csv) {
	foreach($Column in $Header) {
		if($Line.$Column -ne $null -and $Column -ne $MeasurementColumn -and $Column -ne $TimeColumn) {
			try {
				[double]$Double = $Line.$Column
				if($ValueColumnsArray -notcontains $Column) {
					$ValueColumnsArray += $Column
				}
			} catch {
				if($TagColumnsArray -notcontains $Column) {
					$TagColumnsArray += $Column
				}
			}
		}
	}
}

foreach($Tag in $TagColumnsArray) {
	if($ValueColumnsArray -contains $Tag) {
		$ValueColumnsArray = $ValueColumnsArray | Where-Object {$_ -ne $Tag}
	}
}

if($Database) {
	"# DML"
	"# CONTEXT-DATABASE: $Database"
	"# CONTEXT-RETENTION-POLICY: autogen"
}

foreach($Line in $Csv) {
	$TagsString = ''
	$ValuesString = ''
	
	foreach($Column in $Header) {
		if($Line.$Column -ne $null -and $Column -ne $MeasurementColumn -and $Column -ne $TimeColumn) {
			if(-not [string]::IsNullOrEmpty($Line.$Column)) {
				if($ValueColumnsArray -contains $Column) {
					$ValuesString = $ValuesString,$Column,'=',$Line.$Column,',' -join ''
				}
				if($TagColumnsArray -contains $Column) {
					$TagsString = $TagsString,$Column,'=',$Line.$Column,',' -join ''
				}
			}
		}
	}
	
	$ValuesString = $ValuesString.Substring(0,$ValuesString.Length-1)
	$TagsString = $TagsString.Substring(0,$TagsString.Length-1)
	
	$Output = $Line.$MeasurementColumn,$TagsString -join ','
	$Output,$ValuesString,$Line.$TimeColumn -join ' '
}
