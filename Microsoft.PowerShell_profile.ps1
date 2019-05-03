# Load all subdirectories
$psdir = "~\Documents\WindowsPowerShell\profile.d"
Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

### useful vars
$bashrc='export PS1="\u@\h:\w\\$ "'
$gitlab="~\Documents\gitlab"
$github="~\Documents\github"
$shellStartupDate=$(Get-Date -UFormat "%A %d %B %T")

Function bashrc { echo $bashrc }
Function gitlab { cd $gitlab }
Function github { cd $github }
Function startupDate { echo $shellStartupDate}

Echo "Console loaded at $shellStartupDate"
