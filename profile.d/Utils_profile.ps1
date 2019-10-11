## UTILS

## history completion time
# returns the completion time of a command launched in this powershell. you can find the command id with `history`
function history_completion_time {
    param (
        [int] $number
    )
  
    if (!($number)) {
        $number = (Get-History).Length
    }
    # verify number is valid
    if ($number -lt 1 -or $number -gt (Get-History).Length) {
        throw  "$number is not valid for current history"
    }
  
    return (Get-History)[$number - 1].EndExecutionTime - (Get-History)[$number - 1].StartExecutionTime
}

### ssh tunnel using plink (putty headless)
Function sshtunnel {
    $reboundserver = "<hostnameOrIp>"
    $reboundUser = "<user>"
    $reboundKey = "<path>"
	
    $mysqlserver = "<hostnameOrIp>"
	
    $localPort = 8306
    $mysqlserverport = 3306
    Write-Output "Starting SSH tunnel, listening on localhost:$localPort"
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

Function ip() {
    $a = Get-NetIpAddress
    if (! $args[0]) {
        # no args : display all active connexions
        #virtual first
        Write-Output "Virtual"
        Write-Output "-------"
        Foreach ($interface in $a) {
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and ($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")) {
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
        Write-Output ""
        #real after
        Write-Output "Real"
        Write-Output "----"
        Foreach ($interface in $a) {
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and !($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")) {
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress)"
            }
        }
    }
    else {
        Foreach ($interface in $a) {
            if ($interface.AddressFamily -like "*IPv4*" -and $interface.InterfaceAlias -like "$($args[0])*") {
                Write-Output "$($interface.InterfaceAlias) : $($interface.IPAddress) ($($interface.AddressState))"
            }
        }
    }
    Write-Output ""
    Write-Output "External"
    Write-Output "--------"
    Write-Output "WebIp : $((Invoke-WebRequest 'https://api.ipify.org').Content)"
}

Function ip2() {
    $collectionWithItems = New-Object System.Collections.ArrayList
    $a = Get-NetIpAddress
    if (! $args[0]) {
        # no args : display all active connexions
        #virtual first
        Foreach ($interface in $a) {
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and ($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")) {
                $temp = New-Object System.Object
                $temp | Add-Member -MemberType NoteProperty -Name "Type" -Value "Virtual"
                $temp | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($interface.InterfaceAlias)"
                $temp | Add-Member -MemberType NoteProperty -Name "Ip" -Value "$($interface.IPAddress)"
                $collectionWithItems.Add($temp) | Out-Null
            }
        }
    
        #real after
        Foreach ($interface in $a) {
            if ($interface.AddressState -like "*Preferred*" -and $interface.AddressFamily -like "*IPv4*" -and !($interface.InterfaceAlias -like "*VEthernet*" -or $interface.InterfaceAlias -like "*Virtual*")) {
                $temp = New-Object System.Object
                $temp | Add-Member -MemberType NoteProperty -Name "Type" -Value "Real"
                $temp | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($interface.InterfaceAlias)"
                $temp | Add-Member -MemberType NoteProperty -Name "Ip" -Value "$($interface.IPAddress)"
                $collectionWithItems.Add($temp) | Out-Null
            }
        }
    }
    else {
        Foreach ($interface in $a) {
            if ($interface.AddressFamily -like "*IPv4*" -and $interface.InterfaceAlias -like "$($args[0])*") {
                $temp = New-Object System.Object
                $temp | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($interface.InterfaceAlias)"
                $temp | Add-Member -MemberType NoteProperty -Name "Ip" -Value "$($interface.IPAddress)"
                $collectionWithItems.Add($temp) | Out-Null
            }
        }
    }
  
    $temp = New-Object System.Object
    $temp | Add-Member -MemberType NoteProperty -Name "Type" -Value "External"
    $temp | Add-Member -MemberType NoteProperty -Name "Name" -Value "WebIp (ipify)"
    $temp | Add-Member -MemberType NoteProperty -Name "Ip" -Value "$((Invoke-WebRequest 'https://api.ipify.org').Content)"
    $collectionWithItems.Add($temp) | Out-Null
  
    return $collectionWithItems
}

Function pwn_cisco {
    $c = Get-User-Permission "This command will stop all cisco services. are you sure you want to proceed ? (y/n): "
    if ($c) {
        Get-Service -DisplayName "*cisco*" | Stop-Service
    }
}

Function pwn_symantec {
    $c = Get-User-Permission "This command will stop all symantec services. are you sure you want to proceed ? (y/n): "
    if ($c) {
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


Function dos2unixr {
    wsl bash -c 'find . -type f -not -path "*node_modules*" -not -path "*/node_modules/*" -not -path "*.git*" -not -path "*/.git/*" -not -path "*.jpg" -not -path "*.png" -not -path "*.pdf" -exec dos2unix {} \;'
}

Set-Alias nano notepad++.exe
Set-Alias vi notepad++.exe