$var =  Get-AzAdUser -DisplayName 'Diether Pastulero'

$rand = Get-Random -Minimum 20 -Maximum 10000
 
$prefix = 'cloud-resume-'

$rgname = $prefix + $rand

New-AzDeployment -TemplateFile main.bicep -Location 'australiaeast' -objectId $var.id -rgName $rgname