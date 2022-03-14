function RollCall(){
	$RoleCheck =@("DNS","AD","DHCP","IIS")
	foreach($x in $RoleCheck){if(Get-WindowsFeature | where Installed | %{out-string -InputObject $_.Name} | ?{$_ -match $x}){FirewallRoles($x);if($x -eq 'AD'){$AD=$true}}}
	if((get-service | select-object Name, Status | %{$_.Name -match 'MSExchangeServiceHost'}) -eq 'True'){FirewallRoles('Exchange')}
	if(-Not $AD){if((gwmi win32_computersystem).partofdomain -eq $true){FirewallRoles('AD')}}}
function Documentation(){
}
function FirewallRoles($Role){
	$AD =@('88','135','138','139','389','445','464','636','3268','3269')
	$DHCP =@('647')
	$DHCPUDP =@('67','547','647','847')
	$DNS =@('53')
	$Exchange =@('25','143','993','110','995','587')
	$Ftp =@()
	$IIS =@('80','443','444','81','135','465','102','691')
	switch($Role){
		'AD'{foreach($x in $AD){New-NetFirewallrule -DisplayName "AD Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'DHCP'{foreach($x in $DHCP){New-NetFirewallrule -DisplayName "DHCP Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								    New-NetFirewallrule -DisplayName "DHCP Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow}
			   foreach($x in $DHCPUDP){New-NetFirewallrule -DisplayName "DHCP Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
									   New-NetFirewallrule -DisplayName "DHCP Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'DNS'{foreach($x in $DNS){New-NetFirewallrule -DisplayName "DNS Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'Exchange'{foreach($x in $Exchange){New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'IIS'{foreach($x in $IIS){New-NetFirewallrule -DisplayName "IIS Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "IIS Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
											New-NetFirewallrule -DisplayName "IIS Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "IIS Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
	}
}
function FirewallInit(){	
	Set-NetFirewallProfile -Enabled True
	(New-Object -ComObject HNetCfg.FwPolicy2).RestoreLocalFirewallDefaults()
	$BasicRules =@('53','80','443','8089','123')
	$BasicRulesUDP =@('53','123')
	foreach($x in $BasicRules){New-NetFirewallrule -DisplayName "Basic Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow}
	foreach($x in $BasicRulesUDP){New-NetFirewallrule -DisplayName "Basic Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow
								  New-NetFirewallrule -DisplayName "Basic Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow}
	$SecurityBlocks =@('3389','22','5300')
	$SecRangeBlocks =@('1-24','26-52','54-66','68-79','81-87','89-101','103-109','111-122','124-134','136-137','140-142','144-388','390-442','444','446-463','465-546','548-586','588-635','637-646','648-690','692-846','848-992','994','996-1023','8081-8088','8090-49151')
	foreach($x in $SecurityBlocks){New-NetFirewallrule -DisplayName "Block Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x" -Direction Outbound -LocalPort $x -Protocol TCP - Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Block}
	foreach($x in $SecRangeBlocks){
		New-NetFirewallrule -DisplayName "Block Range $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Block}
}
function BlockWall(){
}
function LogManager(){
}
function EventMonitor(){
}
FirewallInit
RollCall
