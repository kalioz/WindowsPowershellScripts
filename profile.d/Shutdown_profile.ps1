Function RestartAt {
  <#
  .DESCRIPTION
  Restarts the computer at the given time
  
  .PARAMETER time
  Specifies the time to restart the computer (by default : current time)
  
  .PARAMETER date
  Specifies the date to restart the computer (by default : current day)
  
  .EXAMPLE
  RestartAt -time 15:20 -date 04/06/2019
  
  .EXAMPLE
  RestartAt -date 04/06/2019
  
  .EXAMPLE
  RestartAt -time 15:20
  
  .EXAMPLE
  RestartAt 15:20
  
  .NOTES
  minimum restart delay is 60 seconds
  #>

  param (
    [Parameter(Mandatory=$false, Position=0)] 
    $time = $(Get-Date -UFormat "%H:%M"),
    $date = $(Get-Date -UFormat "%d/%m/%Y")
  )
  
  $now = Get-Date
  $futur = [datetime]::ParseExact("$date $time", "g", $null)
  $delaySeconds = [math]::floor((($futur - $now).TotalSeconds, 60 | Measure -Max).Maximum)
  
  echo "Restarting in $delaySeconds seconds; use shutdown -a to stop this"
  
  shutdown -r -t $delaySeconds
}