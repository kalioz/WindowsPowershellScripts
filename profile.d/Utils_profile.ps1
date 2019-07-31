## UTILS

### prompt
function prompt {
  # colors
  $ESC= [char]27
  $red = "$ESC[91m"
  $green = "$ESC[92m"
  $red_2 = "$ESC[31m"
  $green_2 = "$ESC[32m"
  $reset = "$ESC[0m"
  
  # arrows
  $up_arrow=[char]8593
  $down_arrow=[char]8595
  
  # if a command was executed before : print time of execution
  $blacklist=@("git","cd","ls")
  if ((history).length -gt 0 -and $False){
    $last_command = (history)[-1]
    $blacklisted = $False
    ForEach ($black in $blacklist){
      if ($last_command.CommandLine.StartsWith($black)){
        $blacklisted = $True
        break
      }
    }
    if (! $blacklisted){
      echo "$($last_command.StartExecutionTime.ToString('HH:mm:ss')) -> $($last_command.EndExecutionTime.ToString('HH:mm:ss')) ($([math]::Round(($last_command.EndExecutionTime - $last_command.StartExecutionTime).TotalSeconds, 3))s)"
    }
  }

  # date
  $output="${reset}PS $(Get-Date -UFormat '%R')"
  
  # location
  $location = $(get-location).Path
  if ($location.length -gt "$HOME/".length){
    $location = $location.replace("$HOME",'~')
  }
  if ( $location.Contains(" ") ){
    $output+=" `"$location`" "
  } else {
    $output+=" $location "
  }
  
  # git branch
  $G_BRANCH = git branch -vv 2>$null | Select-String -Pattern "\* (?<name>[^ ]+).*" 
  if ($?) {
    # fetch last updates if not done in more than 30 minutes
    $FETCH_HEAD="$(git rev-parse --show-toplevel)/.git/FETCH_HEAD"
    if (Get-Item $FETCH_HEAD | Select -Property LastWriteTime | %{$_.LastWriteTime.AddMinutes(120) -lt (Get-Date)}){
      git fetch > $null
      $G_BRANCH = git branch -vv 2>$null | Select-String -Pattern "\* (?<name>[^ ]+).*"
    }
    
    $current_branch = $G_BRANCH.matches.groups[1].value
    # find difference between current and up
    $ahead_match = $G_BRANCH.Line | Select-String -Pattern "ahead ([0-9]+)"
    $ahead=""
    if ($ahead_match.matches.groups.length -eq 2){
      $a=$ahead_match.matches.groups[1].value
      $ahead="${a}${up_arrow}"
    }
    
    $behind_match = $G_BRANCH.Line | Select-String -Pattern "behind ([0-9]+)"
    $behind=""
    if ($behind_match.matches.groups.length -eq 2){
      $b=$behind_match.matches.groups[1].value
      $behind="${b}${down_arrow}"
    }
    
    $gitdiff=""
    if ($behind.length -gt 0) {
      $gitdiff+= " ${red_2}${behind}${reset}"
    }
    if ($ahead.length -gt 0) {
      $gitdiff+= " ${green_2}${ahead}${reset}"
    }
    
    $default_branch = git symbolic-ref refs/remotes/origin/HEAD | %{$_ -replace "refs/remotes/origin/",""}
    if ("$default_branch" -eq "$current_branch") {
      $output+="[${red}${current_branch}${reset}${gitdiff}] "
    } else {
      $output+="[${green}${current_branch}${reset}${gitdiff}] "
    }
  }
  
  # end char
  $output+="$ "
  
  echo $output
}

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


### JMeter 
Function jmeter2 {
  Start-Job {
    Set-Location /tmp
    jmeter $args
  }
}

### Utils

Function dnsresolve($hostname) {
	[System.Net.Dns]::GetHostAddresses($hostname)
}

Function ip(){
    $a=Get-NetIpAddress
    if (! $args[0]){
        # no args : display all active connexions
        #virtual first
        Write-Output "Virtual"
        Write-Output "-------"
        Foreach($interface in $a){
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and ($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")){
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
        Write-Output ""
        #real after
        Write-Output "Real"
        Write-Output "----"
        Foreach($interface in $a){
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and !($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")){
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
    }else{
        Foreach($interface in $a){
            if ($interface.AddressFamily -like "*IPv4*" -and $interface.InterfaceAlias -like "$($args[0])*"){
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress) ($($interface.AddressState))"
            }
        }
    }
    Write-Output ""
    Write-Output "External"
    Write-Output "--------"
    Write-Output "WebIp : $((Invoke-WebRequest 'https://api.ipify.org').Content)"
}

Function pwn_cisco {
	$c = Get-User-Permission "This command will stop all cisco services. are you sure you want to proceed ? (y/n): "
	if ($c){
		Get-Service -DisplayName "*cisco*" | Stop-Service
	}
}

Function pwn_symantec {
	$c = Get-User-Permission "This command will stop all symantec services. are you sure you want to proceed ? (y/n): "
	if ($c){
		Get-Service -DisplayName "*symantec*" | Stop-Service
	}
}

Function Get-User-Permission {
    <#
    .DESCRIPTION
    asks for user confirmation and return a boolean.

    .PARAMETER message
    The message to display to the user. (default = "confirm ?")
    #>

    param (
        [string] $message = "confirm ? "
    )

    $c = Read-Host $message

    return ($c -eq 'y') -or ($c -eq 'Y') -or ($c -eq 'yes') -or ($c -eq 'o') -or ($c -eq 'O') -or ($c -eq 'oui')
}

Set-Alias nano notepad++.exe
Set-Alias vi notepad++.exe