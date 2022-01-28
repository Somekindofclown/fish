#!/bin/bash
read -p "Enter password for system users: " systempass
read -p "Enter password for system users: " userpass
users=$(getent passwd {1000..6000} | cut -d “:” -f 1)
for user in $users
do
    echo “$user:$systempass” | chpasswd
    echo “$user done” >> justforme.csv
done
users=$(getent passwd {1..999} | cut -d “:” -f 1)
for user in $users
do
    echo “$user:$userpass” | chpasswd
	echo “$user done” >> justforme.csv
done