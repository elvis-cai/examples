#!/bin/bash

for i in $(triton ls | awk 'NR>1{print $2}' | grep awx)
do 
  echo -n " 
- $i:
  hostname: $i.awx.im
  nodename: $i.awx.im
  tags: 'dev,sh'
  username: root"
done
