#!/bin/bash

export DS_LICENSE=accept

/entrypoint.sh dse cassandra -f -k -s -g > /var/log/datastax.log &

counter=0
i=1
sp="/-\|"
echo -n ' '
while ! nc -z localhost 9042; do
  if [ $counter -gt 240 ]; then
    echo "Cassandra failed to startup within 120 seconds!"
    exit 1
  fi
  sleep 0.5 # wait for 1/10 of the second before check again
  counter=$((counter+1))
  printf "\b${sp:i++%${#sp}:1}"
done

echo "Cassandra is now up..."

exec "$@"
