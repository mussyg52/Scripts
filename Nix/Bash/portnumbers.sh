#!/bin/bash

echo '---
stingray:
  :service: sas

tig:
  -
    :ip: <%= $SAS_TIG %>
    :description: "Load balancer config for the sas service"

pool:
  -'


for i in $(cat ports.txt); do
  echo "	:name: sas-$i"
  echo "	"$(echo 'poolnodes: \<%= $SAS_POOL_MEMBERS_')$(echo "$i")$(echo ' %>')
  done
