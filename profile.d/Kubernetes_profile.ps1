# Kubernetes shortcuts
Set-Alias kuebctl kubectl
Set-Alias kubetcl kubectl
Set-Alias kuebtcl kubectl
Set-Alias kubeclt kubectl
Set-Alias kb kubectl

## Custom contexts quick-access

Function kbdev {
	if ( $args[0] ){
		kubectl config set-context aks-valo-dev --namespace $args[0]
	}
	kubectl config use-context aks-valo-dev
}

Function kbmini {
	if ( $args[0] ){
		kubectl config set-context minikube --namespace $args[0]
	}
	kubectl config use-context minikube
}

## kubectl utils

### change namespace
Function kbns {
	kubectl config set-context $(kubectl config current-context) --namespace $args[0]
}

### shortcut for kubectl get pods -w
Function kbp {
	kubectl get pods -w $args
}

### better `kubectl get pods -w` = refresh the same environment
Function kbp2 {
	echo ""
	$startCursor=$host.UI.RawUI.CursorPosition
	$refresh=1
	$previousResult=$null
	Do {
		$result=$(kubectl get pods $args)
		# reset the cursor
		$host.UI.RawUI.CursorPosition=$startCursor
		# clean old result
		ForEach ($line in $previousResult){
			$a=" "*$line.length
			echo $a
		}
		$previousResult=$result
		#display new result
		$host.UI.RawUI.CursorPosition=$startCursor
		echo $result
		echo ""
		echo $(Get-Date -UFormat "%A %d %B %T")
		Start-Sleep -Seconds $refresh
	} While(1)
}

### get or change current context
Function kbctx($config, $namespace) {
	if ($config){
		if ($namespace){
			kubectl config set-context $config --namespace $namespace
		}
		kubectl config use-context $config
	}else{
		kubectl config get-contexts $(kubectl config current-context)
	}
}

### get images used in a pod
Function kbimage {
	$a=kubectl describe pod $args |Select-String -Pattern "Image:"
	$a -replace " "
}