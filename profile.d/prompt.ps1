### prompt

function prompt_settings_new_object {

  $output = New-Object -TypeName psobject

  $output | Add-Member -MemberType NoteProperty -Name "last_command_status" -Value $True
  $output | Add-Member -MemberType NoteProperty -Name "last_command_time" -Value $False
  $output | Add-Member -MemberType NoteProperty -Name "newline" -Value $False
  $output | Add-Member -MemberType NoteProperty -Name "git" -Value $True
  $output | Add-Member -MemberType NoteProperty -Name "date" -Value $True
  $output | Add-Member -MemberType NoteProperty -Name "date_color" -Value $True
  $output | Add-Member -MemberType NoteProperty -Name "path" -Value $True
  $output | Add-Member -MemberType NoteProperty -Name "kubernetes" -Value $False
  $output | Add-Member -MemberType NoteProperty -Name "history_length" -Value $True

  return $output
}

$PROMPT_SETTINGS = prompt_settings_new_object
function prompt_settings {
  return $PROMPT_SETTINGS
}

function ps_simple {
  $PROMPT_SETTINGS.kubernetes=$False
  $PROMPT_SETTINGS.git=$False
}

function ps_kuber {
  $PROMPT_SETTINGS.kubernetes=$True
  $PROMPT_SETTINGS.git=$False
}

function ps_git {
  $PROMPT_SETTINGS.kubernetes=$False
  $PROMPT_SETTINGS.git=$True
}

function prompt {
  #last command success - keep in first position
  $last_command_success = $?
  
  # allow or disallow components (default)
  $last_command_status = $False  # show the first characters in red if the last command failed
  $last_command_time   = $False # TODO
  $newline             = $False # add a newline at the end of the prompt
  $git                 = $False  # git repertory info - will perform `git fetch` at regular intervals to get last infos
  $date                = $False  # show the date
  $path                = $True  # show the path
  $kubernetes          = $False # display kubernetes info
  $history_length      = $False  # show history position
  
  if ($PROMPT_SETTINGS) {
    $last_command_status = $PROMPT_SETTINGS.last_command_status  # show the first characters in red if the last command failed
    $last_command_time   = $PROMPT_SETTINGS.last_command_time # TODO
    $newline             = $PROMPT_SETTINGS.newline # add a newline at the end of the prompt
    $git                 = $PROMPT_SETTINGS.git  # git repertory info - will perform `git fetch` at regular intervals to get last infos
    $date                = $PROMPT_SETTINGS.date  # show the date
    $path                = $PROMPT_SETTINGS.path  # show the path
    $kubernetes          = $PROMPT_SETTINGS.kubernetes # display kubernetes info
    $history_length      = $PROMPT_SETTINGS.history_length  # show history position
    $date_color          = $PROMPT_SETTINGS.date_color # color the hour in function of the hour
  }

  # colors
  $ESC= [char]27
  $red = "$ESC[91m"
  $green = "$ESC[92m"
  $red_2 = "$ESC[31m"
  $green_2 = "$ESC[32m"
  $blue = "$ESC[94m"
  $blue_2 = "$ESC[34m"
  $cyan = "$ESC[96m"
  $grey = "$ESC[90m"
  $grey_2 = "$ESC[37m"
  $reset = "$ESC[0m"
  
  # ASCII chars
  $up_arrow=[char]8593
  $down_arrow=[char]8595
  $check_mark=[char]10004
  $cross_mark=[char]10006
  
  $output = ""
  
  # history # for quick access
  if ($history_length) {
    $h = (history).length +1
    $output+= "${grey}${h}${reset}."
  }
  
  # last command success 
  if ($last_command_success){
    # $last_command_status = "${reset}${green}${check_mark}${reset}"
    $output+="${reset}${green}PS${reset}" # use PS to reduce colors on the prompt
  } else {
    $output+="${reset}${red}${cross_mark}${reset}"
  }
  
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
  if ($date){
    if ($date_color){
      $hour = $(Get-Date -UFormat '%H')
      if ($hour -ge 18 -or ($hour -ge 12 -and $hour -lt 14)){
        $output+= "${reset}${red} $(Get-Date -UFormat '%R')${reset}"
      } else {
        $output+="${reset} $(Get-Date -UFormat '%R')"
      }
    }else{
      $output+="${reset} $(Get-Date -UFormat '%R')"
    }
  }
  
  # location
  if ($path){
    $location = $(get-location).Path
    if ($location.length -gt "$HOME/".length){
      $location = $location.replace("$HOME",'~')
    }
    if ( $location.Contains(" ") ){
      $output+=" `"$location`" "
    } else {
      $output+=" $location "
    }
  }
  
  # kubernetes
  if ($kubernetes) {
    $output+=prompt_kubernetes
  }
  
  # git branch
  if ($git) {
    $output+= prompt_git
  }
  # end char
  if ($newline) {
    $output+="`n"
  }
  $output+='$ '
  
  echo $output
}

function prompt_kubernetes {
  $kube_config=(kubectl config view --minify --output "jsonpath={['..context.cluster', '..context.namespace']}").Split(" ")
  $cluster=$kube_config[0]
  $namespace=$kube_config[1]
  $color_cluster=$blue_2
  $color_ns=$blue
  
  if ($cluster -like "*prd*" -or $cluster -like "*prod*"){
    $color_cluster=$red
  }
  if ($namespace -eq "kube-system"){
    $color_ns=$red
  }
  if ($namespace -eq "default"){
    $color_ns=$red_2
  }
  
  return "${reset}[${color_cluster}${cluster}${reset} ${color_ns}${namespace}${reset}]"
}

function prompt_git {
  $output=""
  $GIT_ROOT = git rev-parse --show-toplevel
  if ($?) {
    # fetch last updates if not done in more than 30 minutes
    $FETCH_HEAD="${GIT_ROOT}/.git/FETCH_HEAD"
    if (Get-Item $FETCH_HEAD | Select -Property LastWriteTime | %{$_.LastWriteTime.AddMinutes(120) -lt (Get-Date)}){
      start-job {git fetch} > $null
    }
    
    $G_BRANCH = git branch -vv 2>$null | Select-String -Pattern "\* (?<name>[^ ]+).*"
    
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
  return $output
}