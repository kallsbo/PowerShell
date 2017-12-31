#
# IIS AppPool Process Killer
#
# Kills the selected IIS AppPool worker processes
#
# Kristofer Källsbo 2017
#
Import-Module ServerManager
Add-WindowsFeature Web-Scripting-Tools
Import-Module WebAdministration

dir IIS:\AppPools\ | Out-GridView -Title 'Select apppool to restart' -PassThru | Set-Variable -Name selectedAppPool

foreach($worker in $selectedAppPool.workerProcesses.Collection)
{
    Stop-Process $worker.processId
}
