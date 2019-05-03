## UTILS

### cd - Change Directory

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

#### cd_unix = cd <path> normal, cd default to home directory
Function cd_unix {
    if ( $args[0] ){
        Set-Location $args[0]
    }else{
        $c = Read-Host "press enter to go to home"
        Set-Location ~/
    }
}

del alias:cd -Force
Set-Alias cd cd_unix

### ssh tunnel using plink (putty headless)
Function sshtunnel {
	$reboundserver="<hostnameOrIp>"
	$reboundUser="<user>"
	$reboundKey="<path>"
	
	$mysqlserver="<hostnameOrIp>"
	
	$localPort=8306
	$mysqlserverport=3306
    echo "Starting SSH tunnel, listening on localhost:$localPort"
	plink.exe -ssh ${reboundUser}@${reboundserver} -i $reboundKey -L ${localPort}:${mysqlserver}:${mysqlserverport} -N
}

### Utils

Function dnsresolve($hostname) {
    [System.Net.Dns]::GetHostAddresses($hostname)
}

Function pwn_cisco {
    $c = Read-Host "This command will stop all cisco services. are you sure you want to proceed ? (y/n): "
    if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')){
        Get-Service -DisplayName "*cisco*" | Stop-Service
    }
}