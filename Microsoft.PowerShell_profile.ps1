# Load all subdirectories
$psdir = "~\Documents\WindowsPowerShell\profile.d"
Get-ChildItem "${psdir}\*.ps1" | ForEach-Object{.$_} 

### useful vars
$bashrc='export PS1="\u@\h:\w\\$ "'
$gitlab="~\Documents\gitlab"
$devops="$gitlab\devops"
$application="$gitlab\application"

$github="~\Documents\github"
$shellStartupDate=$(Get-Date -UFormat "%A %d %B %T")

Function bashrc { 
  Set-Clipboard -value $bashrc
  Write-Output $bashrc 
}
Function gitlab { Set-Location $gitlab }
Function devops { Set-Location $devops }
Function application { Set-Location $application }
Function github { Set-Location $github }
Function startupDate { Write-Output $shellStartupDate}

Write-Output "Console loaded at $shellStartupDate"