#!/bin/bash
users=$(getent passwd {1000..6000} | cut -d ":" -f 1)
for users in $users ; do
	pass="tryit"
	echo "$user:$pass" | chpasswd
	echo "$user:$pass" >> my_stoof.csv
done
users=$(getent passwd {1..999} | cut -d ":" -f 1)
	for user in $users; do
	echo "$user:pass" >> my_stoof1.csv
done