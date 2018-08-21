#! /bin/bash
while true; do
ps aux | sort -nrk 3,3 | head -n 5 | awk '{ print $1 }'
sleep 5
done
