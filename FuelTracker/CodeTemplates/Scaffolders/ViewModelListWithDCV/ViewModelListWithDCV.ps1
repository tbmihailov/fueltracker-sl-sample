[T4Scaffolding.Scaffolder(Description = "Generates ViewModel that Lists entities of a given type using DomainCollectionView")][CmdletBinding()]
param(        
	[string]$ModelType,
	[string]$PrimaryKeyName,
	[string]$ViewModelName,
	[string]$DomainContextName,
	[string]$Namespace,
	[Array]$RelatedEntities,
	[string]$DefaultNamespace,
	[string]$OutputFolder,
	[string]$Area,
	[string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

if(!$Namespace)
{
	$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value
	$namespace = $namespace + ".ViewModels"
}

if(!$DefaultNamespace)
{
	$defaultNamespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value;
}

if ($ModelType) {
	$foundModelType = Get-ProjectType $ModelType -Project $Project
	if (!$foundModelType) { return }
}

if ($foundModelType) 
{ 
	if(!$RelatedEntities)	
	{
		$relatedEntities = [Array](Get-RelatedEntities $foundModelType.FullName -Project $project) 
	}
}
if (!$relatedEntities) { $relatedEntities = @() }

if($PrimaryKeyName)
{
	$primaryKeyName = $PrimaryKeyName
}
else
{
	$primaryKeyName = $foundModelType.Name+"Id";
	#$primaryKeyName = [string](Get-PrimaryKey $foundModelType.FullName -Project $Project)
}

$modelTypeNamePlural = [string](Get-PluralizedWord $foundModelType.Name);
if(!$modelTypeNamePlural)
{
	$modelTypeNamePlural = $foundModelType.Name + "s";
}

if($ViewModelName)
{
	$viewModelName = $ViewModelName
}
else
{
	$viewModelName = $modelTypeNamePlural + "ListViewModel"
}

if($DomainContextName)
{
	$domainContextName = $DomainContextName
}
else
{
	$domainContextName = $defaultNamespace+"DomainContext";
}

if($OutputFolder)
{
	$outputFolder = $OutputFolder
}
else
{
	$outputFolder = "ViewModels"
}

$outputPath = $outputFolder+ "\" + $viewModelName  # The filename extension will be added based on the template's <#@ Output Extension="..." #> directive


#if ($Area) {
#	$areaPath = Join-Path Areas $Area
#	if (-not (Get-ProjectItem $areaPath -Project $Project)) {
#		Write-Error "Cannot find area '$Area'. Make sure it exists already."
#		return
#	}
#	$outputPath = Join-Path $areaPath $outputPath
#}

# Prepare all the parameter values to pass to the template, then invoke the template with those values
#$repositoryName = $foundModelType.Name + "Repository"
#$defaultNamespace = [string](Get-Project $Project).Properties.Item("DefaultNamespace").Value
#$modelTypeNamespace = [T4Scaffolding.Namespaces]::GetNamespace($foundModelType.FullName)
#$controllerNamespace = [T4Scaffolding.Namespaces]::Normalize($defaultNamespace + "." + [System.IO.Path]::GetDirectoryName($outputPath).Replace([System.IO.Path]::DirectorySeparatorChar, "."))
$areaNamespace = if ($Area) { [T4Scaffolding.Namespaces]::Normalize($defaultNamespace + ".Areas.$Area") } else { $defaultNamespace }
#$dbContextNamespace = $foundDbContextType.Namespace.FullName
#$repositoriesNamespace = [T4Scaffolding.Namespaces]::Normalize($areaNamespace + ".Models")
#$modelTypePluralized = Get-PluralizedWord $foundModelType.Name
#$relatedEntities = [Array](Get-RelatedEntities $foundModelType.FullName -Project $project)
#if (!$relatedEntities) { $relatedEntities = @() }


Add-ProjectItemViaTemplate $outputPath -Template ViewModelListWithDCVTemplate `
	-Model @{ 
			ModelType = $foundModelType; 
			PrimaryKeyName = $primaryKeyName;
			ViewModelName = $viewModelName;
			Namespace = $namespace;
			DefaultNamespace = $defaultNamespace;
			DomainContextName = $domainContextName; 
			ModelTypeNamePlural = $modelTypeNamePlural; 
			ExampleValue = "Hello, world!"; 
			RelatedEntities = $relatedEntities} `
	-SuccessMessage "Added ViewModel output at {0}" `
	-TemplateFolders $TemplateFolders -Project $Project -CodeLanguage $CodeLanguage -Force:$Force