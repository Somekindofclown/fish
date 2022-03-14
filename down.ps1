# downloader for windows
function VersionCheck(){
    $Version =@("2012","2016","2019")
    foreach($x in $Version){if(((get-wmiobject win32_operatingsystem).name -match $x) -eq 'True'){Downloader($x)}}
}
    function Downloader($Role){
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, Ssl3"
        switch($Role){
            '2012'{
                    Invoke-WebRequest -Uri 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/03/windows8-rt-kb4012217-x64_96635071602f71b4fb2f1a202e99a5e21870bc93.msu' -Outfile $env:UserProfile\Desktop\eb.msu
                    Invoke-WebRequest -Uri 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/03/windows8.1-kb4012216-x64_cd5e0a62e602176f0078778548796e2d47cfa15b.msu' -Outfile $env:UserProfilie\Desktop\ebr28.msu
                    echo 'Eternal Blue Patch downloaded'
            }
            '2016'{
                    Invoke-WebRequest -Uri 'http://download.windowsupdate.com/c/msdownload/update/software/updt/2022/01/windows10.0-kb5010460-x64-ndp48_7622c06684946ecdcfab5854844a4621393bc13c.msu' -Outfile $env:UserProfile\Desktop\update.msu
                    echo 'Update downloaded'
            }
            '2019'{
                    Invoke-WebRequest -Uri 'http://download.windowsupdate.com/c/msdownload/update/software/updt/2022/02/windows10.0-kb5010427-x64_1ebd2aa1a2dd6de3070a7c09fa2b68817227e2d0.msu' -Outfile $env:UserProfile\Desktop\update.msu
                    echo 'Update downloaded'
            }
        }
        if((gwmi win32_computersystem).partofdomain -eq $true){
                    Invoke-WebRequest -Uri 'https://gist.github.com/mubix/fd0c89ec021f70023695/archive/02e3f0df13aa86da41f1587ad798ad3c5e7b3711.zip' -Outfile $env:UserProfile\Desktop\krbtgtkeyreset.zip
                    echo 'KRBTGT Reset script downloaded'
        }
    }
    function BasicDownload{
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, Ssl3"
        New-Item -Path $env:UserProfile\Desktop\SysinternalsSuite -ItemType Directory
        Invoke-WebRequest -Uri https://download.sysinternals.com/files/SysinternalsSuite.zip -Outfile $env:UserProfile\Desktop\SysinternalsSuite\SysinternalsSuite.zip
        echo 'SysinternalsSuite downloaded'
        Invoke-WebRequest -Uri https://download.mozilla.org/?product=firefox-stub"&"os=win"&"lang=en-US -Outfile $env:UserProfile\Desktop\firefox.exe
        echo 'Firefox downloaded'
        Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=839516 -Outfile $env:UserProfile\Desktop\wmf5r28.msu
        Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=839513 -Outfile $env:UserProfile\Desktop\wmf5.msu
        echo 'Windows Management Framework 5.1 downloaded'
        Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x86.msi' -Outfile $env:UserProfile\Desktop\PowerShell.msi
        echo 'PowerShell 7 downloaded'
        Invoke-WebRequest -Uri 'https://github.com/ION28/BLUESPAWN/releases/download/v0.5.1-alpha/BLUESPAWN-client-x64.exe' -Outfile $env:UserProfile\Desktop\bluespawn.exe
        echo 'Bluespawn Downloaded'
        Invoke-WebRequest -Uri 'https://download.splunk.com/products/universalforwarder/releases/8.2.4/windows/splunkforwarder-8.2.4-87e2dda940d1-x64-release.msi' -Outfile $env:UserProfile\Desktop\Splunk.msi
        echo 'Splunk forwarder downloaded'
        Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -Outfile $env:UserProfile\Desktop\msvcrd.exe
        echo 'C++ Redistributable downloaded'
        Invoke-WebRequest -Uri 'https://www.clamav.net/downloads/production/clamav-0.104.1.win.x64.msi' -Outfile $env:UserProfile\Desktop\vongole.msi
        echo 'ClamAV downloaded'
    }
VersionCheck
BasicDownload