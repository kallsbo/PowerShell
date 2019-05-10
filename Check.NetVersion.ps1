# Get .net version
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version | Set-Variable versions

# Get .net core version
$props = @{ PSChildName = '.Net core'
            Version = (dir (Get-Command dotnet).Path.Replace('dotnet.exe', 'shared\Microsoft.NETCore.App')).Name
    };
$versions += (New-Object -TypeName psobject -Property $props);

# Displat result
$versions | Select-Object -Property @{N='.Net';E={$_.PSChildName}}, Version   
