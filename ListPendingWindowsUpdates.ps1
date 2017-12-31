function GetPendingUpdatesRemote
{ 
    try 
    { 
        #Create Session COM object 
        $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",'localhost'))
    } 
    catch
    { 
        # Catch error and return it
        return $_.Exception
    }

    # Store result
    $retval = @()

    # Configure Session COM Object 
    $updatesearcher = $updatesession.CreateUpdateSearcher() 
  
    # Configure Searcher object to look for Updates awaiting installation 
    $searchresult = $updatesearcher.Search("IsInstalled=0")

    # Verify if Updates need installed 
    if ($searchresult.Updates.Count -gt 0) 
    { 
        # Updates are waiting to be installed. Cache the count to make the For loop run faster 
        $count = $searchresult.Updates.Count
                          
        # Loop through updates available for installation 
        for ($i=0; $i -lt $count; $i++)
        { 
            # Create object holding update 
            $update = $searchresult.Updates.Item($i) 
            
            # Create temp object   
            $temp = "" | Select Title,KB,Priority,RebootBehavior,IsDownloaded 
            $temp.Title = $update.Title
            $temp.KB = ('KB' + $update.KBArticleIDs)
            
            # Get priority
            $temp.Priority = switch ($update.DownloadPriority)
            {
                1 {'Low'}
                2 {'Normal'}
                3 {'High'}
            }

            # Get reboot behaivor
            $temp.RebootBehavior = switch ($update.InstallationBehavior.RebootBehavior)
            {
                0 {'NeverReboots'}
                1 {'AlwaysRequiresReboot'}
                2 {'CanRequestReboot'}
            }
            
            # Verify that update has been downloaded 
            if ($update.IsDownLoaded -eq "True") 
            {  
                $temp.IsDownloaded = $true
            } 
            else
            { 
                $temp.IsDownloaded = $false
            } 

            $retval += $temp
        } 
                  
    }
        
    return $retval
}

# Get dependencies
import-module ActiveDirectory

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
