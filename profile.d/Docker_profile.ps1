Function DockerPushACR {
    <#
    .DESCRIPTION
    push a local image to the selected Azure Container Registry
    
    .PARAMETER localImage
    Specifies the name of the local image, tag included.
    
    .PARAMETER distantImage
    Specifies the name of the image on the ACR, tag included (default = localImage)

    .PARAMETER acr
    Specifies the name of the ACR (default = acrvalodev)

    .PARAMETER acrLogin
    Force the login to the ACR (default = false)

    .PARAMETER y
    If present, doesn't require confirmation to push to acr.
    #>

    param (
        $localImage,
        $distantImage = $localImage,
        $acr = "acrvalodev",
        [switch] $acrLogin = $false,
        [switch] $y = $false
    )
    
    $di = "${acr}.azurecr.io/$distantImage"
  
    docker tag $localImage $di
    Write-Output "Image locally taged : $localImage > $di"
    
    if ($y -eq $false) {
        Write-Output ">> docker push $acr.azurecr.io/$distantImage"
        $c = Read-Host "Confirm push? (y/n): "
    }
    if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')) {
        Write-Output "docker push $di"
        if ($acrLogin) {
            az acr login --name $acr
        }
        docker push $di
    }
    else {
        Write-Output "did not push image"
    }
}

Function dockerDownloadAndPushAcr($image) {
    docker pull $image

    $acrName = "acrvalodev"
    $prefix = "helm"
  
    docker tag $image acrvalodev.azurecr.io/helm/$image
    echo "Image taged : $image > $acrName.azurecr.io/helm/$image"
	
    echo ">> docker push $acrName.azurecr.io/helm/$image"
    $c = Read-Host "Confirm push? (y/n): "
    if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')) {
        docker push acrvalodev.azurecr.io/helm/$image
    }
    else {
        echo "did not push image"
    }
}

Function dockertagsavailable($image) {
    curl "https://registry.hub.docker.com/v1/repositories/${image}/tags" | Select-Object -Expand Content | ConvertFrom-Json
}

Function dockerClean() {
    <#
    .DESCRIPTION
    Remove all containers and images from docker
    #>

    # delete all containers
    docker rm $(docker ps -a -q) -f
    
    # delete all images
    docker rmi $(docker images -q) -f
}

Function docker-env {
    <#
    .DESCRIPTION
    Set the docker environment.

    .PARAMETER engine
    Select the engine (minikube | docker-machine) to use. (default = docker-machine)
    If the engine isn't turning, will prompt to start.
    #>

    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $engine = "docker-machine"
    )

    if ($engine = = "docker-machine") {
        docker-env-dockerMachine
    }
    if ($engine = = "Minikube") {
        # docker-env-Minikube is specified in Minikube_profile.ps1
        docker-env-Minikube
    }
}

Function docker-env-dockerMachine {
    <#
    .DESCRIPTION
    Set the docker environment for the engine docker-machine
    #>

    # check for engine running 
    if ($(docker-machine status) -eq "Stopped") {
        $c = Read-Host "docker-machine is not running. Start ?"
        if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')) {
            docker-machine.exe start
        }
        else {
            return $null;
        }
    }

    # set environment
    & docker-machine.exe env | Invoke-Expression
    Write-Output "Docker Environment Set - Docker-Machine"
}

$dockershared = "C:\Users\cloisele\Documents\docker_shared"
Function dockerShared() { Set-Location $dockershared; }