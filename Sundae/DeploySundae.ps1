### build prokject first!
### Much of the functionality is in the PoshSSDTBuidlDeploy Module, available publicly on GitHub https://github.com/RichieBzzzt/PoshSSDTBuildDeploy
<#
$connString = "Data Source=(localdb)\MSSQLLocalDB;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=True"
$workingFolder = "C:\Users\usr\source\repos\Sundae\Sundae\bin\Debug"
$databaseName = "Sundae"
$dacpacPath = "C:\Users\usr\source\repos\Sundae\Sundae\bin\Debug\Sundae.dacpac"
$pubProfile = "C:\Users\usr\source\repos\Sundae\Sundae\bin\Debug\Sundae.publish.xml"
$domain = "domain or machine name"
So command would look like
 . C:\Users\usr\source\repos\Sundae\Sundae\DeploySundae.ps1 -connectionString $connString -WorkingFolder $workingFolder -DatabaseName $databaseName -DacpacPath $dacpacPath -PublishProfile $pubProfile -getSqlCmdVars -domain $domain -Verbose
#>

[cmdletbinding()]
param (
	[parameter(Mandatory = $true)] $connectionString,
	[parameter(Mandatory = $true)] $WorkingFolder,
	[parameter(Mandatory = $true)] [string] $DatabaseName,
	[parameter(Mandatory = $true)] [string] $DacpacPath,
	[parameter(Mandatory = $true)] [string] $PublishProfile,
	[parameter(Mandatory = $true)] [switch] $getSqlCmdVars,
	[parameter(Mandatory = $true)] [string] $domain

)

Set-Variable -Name "domain" -Value $domain -Scope Global

try {
	Find-Module -Name "PoshSSDTBuildDeploy"
	Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module PoshSSDTBuildDeploy -Force -Scope CurrentUser
}
catch {
	Write-Host "No PoshSSDTBuildDeploy, Installing from PSGallery."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module PoshSSDTBuildDeploy -Force -Scope CurrentUser
}
finally {
	Write-Host "Importing PoshSSDTBuildDeploy."
	Import-Module PoshSSDTBuildDeploy -Force
}

$dacFxFolder = Install-MicrosoftDataToolsMSBuild -WorkingFolder $WorkingFolder 

$dacFX = Join-Path -Path $dacFxFolder -ChildPath "\Microsoft.SqlServer.Dac.dll"
New-Item -ItemType Directory -Force -Path "$WorkingFolder\deployScripts"

$PublishParams = @{
        dacfxPath                = $dacFX
        dacpac                   = (Resolve-Path $DacpacPath)
        publishXml               = (Resolve-Path $PublishProfile)
		targetConnectionString   = $connectionString
		targetDatabaseName       = $databaseName
		scriptPath				 = $WorkingFolder
		GenerateDeploymentReport = $true
		GenerateDeploymentScript  =$true
	}

if ($PSBoundParameters.ContainsKey('getSqlCmdVars') -eq $true) {
	$PublishParams.Add("GetSqlCmdVars", $true)
}

	Publish-DatabaseDeployment  @PublishParams