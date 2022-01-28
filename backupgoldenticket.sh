#!/bin/bash
# fedora web/mail CCDC script by Caleb Anderson (www.calebdanderson.dev) 2022

# backup original iptables
iptables-save > original-iptables.out

# disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# clear all iptables
iptables -X
iptables -F
# set default deny
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# logging from Logan
iptables -A INPUT -p tcp ! --syn -m state --state NEW -m limit --limit 1/min -j LOG --log-prefix "SYN packet flood: "
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

iptables -A INPUT -f -m limit --limit 1/min -j LOG --log-prefix "Fragmented packet: "
iptables -A INPUT -f -j DROP

iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/min -j LOG --log-prefix "XMAS packet: "
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/min -j LOG --log-prefix "NULL packet: "
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

iptables -A INPUT -p icmp -m limit --limit 3/sec -j ACCEPT
iptables -A INPUT -p icmp -m limit --limit 1/minute -j LOG --log-prefix "ICMP Flood: "

#iptables -A OUTPUT -f -m limit --limit 1/min -j LOG --log-prefix "Hacked Client "
#iptables -A OUTPUT -p tcp --dport 31337:31340 --sport 31337:31340 -j DROP

iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Output-Dropped: " --log-level 4
iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix "Input-Dropped: " --log-level 4
iptables -A FORWARD -m limit --limit 2/min -j LOG --log-prefix "Forward-Dropped: " --log-level 4

# setup my services
iptables -A INPUT -p tcp -m multiport --dports 25,80,110,143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 25,80,110,143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp -m multiport --dports 53,123,389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 389,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# save iptables
iptables-save > /etc/sysconfig/iptables

echo kern.warning /var/log/iptables.log >> /etc/rsyslog.conf

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p

# zip / quarantine redteam www
tar -czf ~/quarantine_www.tar.gz /var/www/html
rm -rf /var/www/html/*

# add redirect to roundcube
echo "<!DOCTYPE html>
<html lang=\"en-US\">
  <meta charset=\"utf-8\">
  <title>Redirecting&hellip;</title>
  <link rel=\"canonical\" href=\"/roundcubemail\">
  <script>location=\"/roundcubemail\"</script>
  <meta http-equiv=\"refresh\" content=\"0; url=/roundcubemail\">
  <meta name=\"robots\" content=\"noindex\">
  <h1>Redirecting&hellip;</h1>
  <a href=\"/roundcubemail\">Click here if you are not redirected.</a>
</html>" > /var/www/html/index.html

# quarantine redteam iptables
gzip /etc/sysconfig/iptables-config
mv /etc/sysconfig/iptables-config.gz ~/quarantine_iptables.gz
# replace good iptables-config
echo "IPTABLES_MODULES=""
IPTABLES_MODULES_UNLOAD=\"yes\"
IPTABLES_SAVE_ON_STOP=\"no\"
IPTABLES_SAVE_ON_RESTART=\"no\"
IPTABLES_SAVE_COUNTER=\"no\"
IPTABLES_STATUS_NUMERIC=\"yes\"
IPTABLES_STATUS_VERBOSE=\"no\"
IPTABLES_STATUS_LINENUMBERS=\"yes\"" > /etc/sysconfig/iptables-config

# audit system accounts with logins
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' > audit_system_usr_shells.txt

users=$(getent passwd {1000..6000} | cut -d ":" -f 1)
for user in $users; do
  # give random 8 char password
  pass=$(openssl rand -base64 6)
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> fedora_users.csv
  # set shell to nologin
  /usr/sbin/usermod -s /usr/sbin/nologin $user
done
