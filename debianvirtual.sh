#!/bin/bash

iptables -X
iptables -F

# Default drop all
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# Accept all loopback packets
iptables -A INPUT -i lo -j ACCEPT

# If SYN packet flood packet attack
iptables -A INPUT -p tcp ! --syn -m state --state NEW -m limit --limit 1/min -j LOG --log-prefix "SYN packet flood: "
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# If fragmented packet attack
iptables -A INPUT -f -m limit --limit 1/min -j LOG --log-prefix "Fragmented packet: "
iptables -A INPUT -f -j DROP

# If Xmax packet attack
iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/min -j LOG --log-prefix "XMAS packet: "
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# If NULL packet attack
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/min -j LOG --log-prefix "NULL packet: "
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# If ICMP flood attack
iptables -A INPUT -p icmp -m limit --limit 3/sec -j ACCEPT
iptables -A INPUT -p icmp -m limit --limit 1/minute -j LOG --log-prefix "ICMP Flood: "

# Accept all established and related connections
iptables -A INPUT -m state --state established,related -j ACCEPT

# HTTP & HTTPS
iptables -A INPUT -p tcp --dport 80 -m state --state new -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state new -j ACCEPT

iptables -A FORWARD -f -m limit --limit 1/min -j LOG --log-prefix "Hacked Client "
iptables -A FORWARD -p tcp --dport 31337:31340 --sport 31337:31340 -j DROP

# Accept all loopback packets
iptables -A OUTPUT -o lo -j ACCEPT

# LOGS
iptables -A OUTPUT -f -m limit --limit 1/min -j LOG --log-prefix "Hacked Client "
iptables -A OUTPUT -p tcp --dport 31337:31340 --sport 31337:31340 -j DROP

iptables -A OUTPUT -m state --state established,related -j ACCEPT

# HTTP & HTTPS
iptables -A OUTPUT -p tcp --dport 80 -m state --state new -j ACCEPT 
iptables -A OUTPUT -p tcp --dport 443 -m state --state new -j ACCEPT

# DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# NTP
iptables -A OUPTUT -p udp --dport 123 -m state --state new -j ACCEPT

# Splunk
iptables -A OUTPUT -p udp --dport 12821 -d 172.20.241.20 -m state --state new -j ACCEPT

# Pinging
iptables -A OUTPUT -p icmp -m limit --limit 2/sec -j ACCEPT

#iptables -A OUTPUT -p tcp --dport 8000 -d 172.20.241.20 -m state --state new -j ACCEPT
#iptables -A INPUT -p tcp --dport 8000 -d 172.20.241.20 -m state --state new -j ACCEPT

# LOGS
iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Output-Dropped: " --log-level 4
iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix "Input-Dropped: " --log-level 4
iptables -A FORWARD -m limit --limit 2/min -j LOG --log-prefix "Forward-Dropped: " --log-level 4

# Saving IPTables
iptables-save > /etc/iptables/iptables-rules
iptables-save > /opt/iptables-rules

echo kern.warning    /var/log/iptables.log >> /etc/rsyslog.conf
echo "*.* @172.20.241.20:12821" >> /etc/rsyslog.conf

cd /var/log/
touch iptables.log