#!/bin/bash

# A totally fake replacement for uname which spits out the kernel version of the target
# machine and not the build container.  Required because HSM driver install compiles
# modules for the target machine according to the results of `uname -r`

if [ $# -eq 0 ]; then
	echo "Linux"
elif [ "$1" == "-r" ]; then
	echo "5.10.0-10-amd64"
elif [ "$1" == "-s" ]; then
	echo "Linux"
elif [ "$1" == "-m" ]; then
	echo "x86_64"
elif [ "$1" == "-a" ]; then
	echo "Linux coen 5.10.0-10-amd64 #1 SMP Debian 5.10.84-1 (2021-12-08) x86_64 GNU/Linux"
else
	exit 1
fi
