# Get dependencies
import-module ActiveDirectory

# Get other scripts
. ($PSScriptRoot + '\check_windows_updates_functions.ps1')

# Get all the servers and sort them
Get-ADComputer -Filter "*" | Sort-Object Name | Set-Variable servers

$result = @()

# Loop the servers
foreach($server in $servers)
{
    
    
    try
    {
        # Invoke remote function
        Invoke-Command -ScriptBlock ${function:GetPendingUpdatesRemote} -ComputerName $server -ErrorAction Stop | Set-Variable remoteresult
        $result += $remoteresult
    }
    catch
    {
        # Catch error and store it
        $_.Exception
    }

}

$result | Select PSComputerName,Title,KB,Priority,RebootBehavior,IsDownloaded | Out-GridView
