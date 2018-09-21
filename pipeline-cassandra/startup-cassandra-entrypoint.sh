#!/bin/bash

export DS_LICENSE=accept

#Startup Cassandra
su dse -p -c 'export PATH=$PATH:$DSE_HOME/bin; /entrypoint.sh dse cassandra -f -k -s -g > /var/log/datastax.log &'

if [ -z "$TIMEOUT" ]; then
  TIMEOUT=1200
else
  TIMEOUT=$((TIMEOUT*2))
fi

counter=0
i=1
sp="/-\|"
echo -n ' '
while ! nc -z localhost 9042; do
  if [ $counter -gt $TIMEOUT ]; then
    printf "\nCassandra failed to startup within [%d] seconds!\n" $((counter/2))
    exit 1
  fi
  sleep 0.5 # wait for 1/10 of the second before check again
  counter=$((counter+1))
  printf "\b${sp:i++%${#sp}:1}"
done

printf "\nCassandra is now up...Took: %d seconds!\n" $((counter/2))
exec "$@"

#Shutdown cassandra
su dse -p -c 'export PATH=$PATH:$DSE_HOME/bin; dse cassandra-stop'
