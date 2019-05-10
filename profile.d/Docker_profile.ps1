Function dockerpushacr($localimage, $distantimage) {
	$acrName=acrvalodev
	
	if (! $distantimage){
		$distantimage=$localimage
	}
	
	az acr login --name $acrName
	
	docker tag $localimage $acrName.azurecr.io/$distantimage
	echo "Image taged : $localimage > $acrName.azurecr.io/$distantimage"
	
	echo ">> docker push $acrName.azurecr.io/$distantimage"
	$c = Read-Host "Confirm push? (y/n): "
	if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')){
		docker push $acrName.azurecr.io/$distantimage
	}else{
		echo "did not push image"
	}
}

Function dockertagsavailable($image) {
    curl "https://registry.hub.docker.com/v1/repositories/${image}/tags" | Select-Object -Expand Content | ConvertFrom-Json
}
