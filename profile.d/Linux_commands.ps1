### cd : Change Directory

#### cdl = cd+ls
Function cdl {
	cd_unix $args[0]
	get-ChildItem
}


#### cdd = cd+ls ..
Function cdd {
	Set-Location ..
	get-ChildItem
}

#### cd_unix = cd <path> normal, cd default to home directory (accept spaces in name, cd path/to my/file)
Function cd_unix {
	if ( $args[0] ){
		Set-Location "$args"
	}else{
		Read-Host "press enter to go to home"
		Set-Location ~/
	}
}

Remove-Item alias:cd -Force
Set-Alias cd cd_unix

### SSH

#### ssh using bash (WSL)
Function ssh {
    bash -c "ssh $args"
}

### touch
Function touch {
    foreach ($path in $args){
        $null >> $path
    }
}

### Where function (Where-Object doesn't act as bash:where)
Remove-Item alias:where -Force

### Curl function (Invoke-WebRequest jsut doesn't do it justice)
Remove-Item alias:curl -Force

Function curl {
  bash -c "curl $args"
}

### printenv
Function printenv {
  Get-ChildItem Env:
}

### function base64 --decode
Function base64decode {
  $text=$args[0]
  $cmd="echo '$text' | base64 --decode"
  bash -c "$cmd"
}

### grep
Set-Alias grep Select-String