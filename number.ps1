#enumeration
$GetDate = Get-Date
$nl = [Environment]::NewLine
function Enumeration(){
    $filter = ('netstat -anob | Select-String -Pattern Established', 'netstat -anob | Select-String -Pattern Listening', 'Get-Process', 'Get-Service | format-list Name, Status',"get-scheduledtask | findstr Ready", "get-scheduledtask | findstr Running",
                "get-addomain", "get-aduser -filter *", 
                "net user",'search-ADAccount -LockedOut',"Get-ADGroup -Filter *", "Get-ADComputer -filter *", 
                'Get-GPO -all | select DisplayName, gpostatus', 'get-executionpolicy', "rendom /list", "wmic qfe list brief",
                "wmic startup get caption,command,location", "ls 'C:\Program Files'", "ls 'C:\Program Files (x86)'",
                "wmic product get Caption,InstallDate,Vendor","get-windowsfeature | where Installed","gwmi win32_computersystem","gwmi win32_operatingsystem","get-childitem -Path C:\ -Recurse")
    foreach($x in $filter){
        PrintFormatting('1')
        PrintFormatting(-join 'Running',$x, $nl)
        try
        {
            PrintFormatting(Invoke-expression($x))
        }
        catch
        {
            PrintFormatting('Error')
        }
    }
}
function PrintFormatting($OtP){
    $loc = "$env:UserProfile\Desktop\Output.txt"
    if($otp -eq '1'){
        echo "##############################" >> $loc
        echo "$GetDate" >> $loc
    }
    else{
        echo $OtP >> $loc
        echo $nl >> $loc
    }
    #echo "##############################" >> $loc
}
Enumeration