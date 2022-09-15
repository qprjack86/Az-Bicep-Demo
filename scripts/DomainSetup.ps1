Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "kailice.uk" `
-DomainNetbiosName "kailice" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\windows\SYSVOL" `
-Force:$true