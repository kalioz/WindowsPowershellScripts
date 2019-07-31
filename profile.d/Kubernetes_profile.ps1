# Kubernetes shortcuts
Set-Alias kuebctl kubectl
Set-Alias kubetcl kubectl
Set-Alias kuebtcl kubectl
Set-Alias kubeclt kubectl
Set-Alias kb kubectl

Set-Alias heml helm

## Custom contexts quick-access

Function kbdev {
	if ( $args[0] ){
		kubectl config set-context aks-valo-dev --namespace $args[0]
	}
	kubectl config use-context aks-valo-dev
}

Function kbstg {
    if ( $args[0] ){
		kubectl config set-context aks-valo-stg --namespace $args[0]
	}
	kubectl config use-context aks-valo-stg
}

Function kbint {
    if ( $args[0] ){
		kubectl config set-context aks-valo-int --namespace $args[0]
	}
	kubectl config use-context aks-valo-int
}

Function kbtest {
    if ( $args[0] ){
		kubectl config set-context aks-valo-test --namespace $args[0]
	}
	kubectl config use-context aks-valo-test
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
    <#
    .DESCRIPTION
    Modify the current Kubernetes context to change the namespace.

    .PARAMETER namespace
    Selected namespace
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)] 
        [string] $namespace
    )
	kubectl config set-context $(kubectl config current-context) --namespace $namespace
}

### shortcut for kubectl get pods
Function kbp {
	kubectl get pods $args
}

Function kbpw {
    kubectl get pods -w $args
}

### shortcut for kb exec -it <podName>
Function kbexec {
    if ($args.Count -eq 1) {
      kubectl exec -it $args[0] bash
    } else {
      kubectl exec -it $args
    }
}

### better `kubectl get pods -w` = refresh the same display
Function kbp2 {
  $podName=""
  if ($args.Count -eq 1){
    $podName=$args[0]
  }
	Write-Output ""
	$startCursor=$host.UI.RawUI.CursorPosition
	$refresh=1
	$previousResult=$null
	Do {
        if ($podName.length -gt 0) {
            $result=$(kubectl get pods | Select-String -Pattern $podName)
        }else{
            $result=$(kubectl get pods $args)
        }
		# reset the cursor
		$host.UI.RawUI.CursorPosition=$startCursor
		# clean old result
		ForEach ($line in $previousResult){
			Write-Output $(" "*$line.length)
		}
        Write-Output ""
        Write-Output $(" "*50)
		$previousResult=$result
		#display new result
		$host.UI.RawUI.CursorPosition=$startCursor
		Write-Output $result
		Write-Output ""
		Write-Output $(Get-Date -UFormat "%A %d %B %T")
		Start-Sleep -Seconds $refresh
	} While(1)
}

### find pod using simple name
Function kbp_simple($name){
    $names= kubectl get pods --all-namespaces |  Select-String -Pattern "^[^ ]*[ ]+($name[^ ]*)" -AllMatches | % {$_.Matches.groups[1].Value}
    return $names
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
	$a=kubectl describe pod $args | Select-String -Pattern "Image:"
	$a=$($a -replace " " -replace "Image:")
    return $a
}

### Get pods with nodes
Function kbpnode {
    kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --sort-by='.spec.nodeName' $args
}

### Kubectl logs
Function kblogs {
    kubectl logs $args
}

Set-Alias kblog kblogs
Set-Alias kbl kblogs

#### Kubectl logs --tail 0 -f
Function kblf {
    kubectl logs --tail 0 -f $args
}

### Kubectl delete failings
Function kbdeletefailing {
  kubectl delete $(kubectl get pods --field-selector=status.phase=Failed --output name)
}