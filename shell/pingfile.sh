#!/bin/bash -xe
PREFIX=192.168.3.1
#for i in `seq 1 10`
for i in {1..3}
do
    echo $i
    echo "#######"
    echo -n "$PREFIX$i "
    ping -c1  $PREFIX$i >/dev/null 2>&1
    if [ "$?" -eq 0 ];then
        echo "OK"
    else
        echo "Failed"
    fi
done
