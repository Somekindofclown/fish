#!/bin/bash

iptables -F
iptables -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP


iptables -A INPUT -p tcp ! --syn -m state --state NEW -m limit --limit 1/min -j LOG --log-prefix "SYN packet flood: "
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

iptables -A INPUT -f -m limit --limit 1/min -j LOG --log-prefix "Fragmented packet: "
iptables -A INPUT -f -j DROP

iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/min -j LOG --log-prefix "XMAS packet: "
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/min -j LOG --log-prefix "NULL packet: "
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

iptables -A INPUT -p icmp -m limit --limit 1/minute -j LOG --log-prefix "ICMP Flood: "
iptables -A INPUT -p icmp -m limit --limit 3/sec -j ACCEPT
iptables -A OUTPUT -p icmp -m limit --limit 3/sec -j ACCEPT

iptables -A FORWARD -f -m limit --limit 1/min -j LOG --log-prefix "Hacked Client "
iptables -A FORWARD -p tcp --dport 31337:31340 --sport 31337:31340 -j DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#felt cute, might delete later
iptables -A INPUT -m state --state established,related -j ACCEPT
iptables -A OUTPUT -m state --state established,related -j ACCEPT

splunkip="172.20.241.20"

windows2016="172.20.240.10"
DebianDNS="172.20.240.20"

ubuntuWkst="172.20.242.20"
UbuntuWeb="172.20.242.10"
windows2012="172.20.242.200"

CentOS7ecomm="172.20.241.30"
fedorawebmail="172.20.241.40"

PaloAlto="172.20.242.150" 


iptables -A OUTPUT -p udp --dport 53 -m state --state new -j ACCEPT

for forwarderserver in $windowsAD $windows2016 $DebianDNS $UbuntuWeb $fedorawebmail $CentOS7ecomm $ubuntuWkst $PaloAlto
do

iptables -A INPUT -p udp --dport 12821 -d $forwarderserver -m state --state new -j ACCEPT

done

iptables -A OUTPUT -p udp --dport 123 -d $DebianDNS -m state --state new -j ACCEPT


iptables -A INPUT -p tcp --dport 8000 -m state --state new -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8000 -m state --state new -j ACCEPT

iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Output-Dropped: " --log-level 4
iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix "Input-Dropped: " --log-level 4
iptables -A FORWARD -m limit --limit 2/min -j LOG --log-prefix "Forward-Dropped: " --log-level 4

iptables-save > /etc/sysconfig/iptables
iptables-save > /opt/iptables

echo kern.warning	/var/log/iptables.log >> /etc/rsyslog.conf

cd /var/log/
touch iptables.log

