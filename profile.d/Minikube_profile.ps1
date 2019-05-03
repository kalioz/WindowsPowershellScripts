## MINIKUBE

Function docker-env {
	minikube docker-env > $null 2>&1
	if (! $?){
		echo "starting minikube host"
		minikube start > $null
	}
	& minikube docker-env | Invoke-Expression
	echo "Docker environment set"
}

Function minirestart {
	$start=Get-Date
	minikube delete > $null
	echo "minikube deleted. recreating..."
	minikube start --memory 3500 
	echo "minikube recreated. setting environment"
	Start-Job -ScriptBlock {helm init} > $null
	docker-env
	$end=Get-Date
	$delay=$end-$start
	echo "finished ! took $($delay.Minutes)m$($delay.Seconds)s"
}

Function ministart {
	Start-Job -ScriptBlock {minikube start $args} > $null
}

Function ministop {
	Start-Job -ScriptBlock {minikube stop} > $null
}
