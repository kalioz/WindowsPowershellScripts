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

#### cd_unix = cd <path> normal, cd default to home directory (accept spaces in name, cd path/to my/file)
Function cd_unix {
	if ( $args[0] ){
		Set-Location "$args"
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

### ssh using bash (WSL)
Function ssh {
    bash -c "ssh $args"
}

### touch function
Function touch {
    foreach ($path in $args){
        $null >> $path
    }
}

### Where function (Where-Object doesn't act as bash:where)
del alias:where -Force

### Utils

Function dnsresolve($hostname) {
	[System.Net.Dns]::GetHostAddresses($hostname)
}

Function ip(){
    $a=Get-NetIpAddress
    if (! $args[0]){
        # no args : display all active connexions
        #virtual first
        echo "Virtual"
        echo "-------"
        Foreach($interface in $a){
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and ($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")){
                echo "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
        echo ""
        #real after
        echo "Real"
        echo "----"
        Foreach($interface in $a){
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and !($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")){
                echo "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
        echo ""
        echo "External"
        echo "--------"
        echo "WebIp : $((curl 'https://api.ipify.org').Content)"
    }else{
        Foreach($interface in $a){
            if ($interface.AddressFamily -like "*IPv4*" -and $interface.InterfaceAlias -like "$($args[0])*"){
                echo "$($interface.InterfaceAlias) : $($interface.IPAddress) ($($interface.AddressState))"
            }
        }
    }
}

Function pwn_cisco {
	$c = Read-Host "This command will stop all cisco services. are you sure you want to proceed ? (y/n): "
	if (($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes')){
		Get-Service -DisplayName "*cisco*" | Stop-Service
	}
}