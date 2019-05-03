# Load all subdirectories
$psdir = "~\Documents\WindowsPowerShell\profile.d"
Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

### useful vars
$bashrc='export PS1="\u@\h:\w\\$ "'
Function bashrc {
    echo $bashrc
}


$gitlab="~\Documents\gitlab"
$github="~\Documents\github"

Function gitlab { cd $gitlab }
Function github { cd $github }