#!/bin/bash -e

##################################################
# FileName : checkNetwork.sh 
# Create   : 2015.10.27
# Author   : Doungni  
# Describe : check network,by checkNetwork()
# Update   : 10.18   
# Idea     : 
##################################################

function checkNetwork() {
    timeout=7
    target="www.bitbucket.org"
    # variable and no variable 
    ret=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`
    #ret=`curl -I -s --connect-timeout 7 bitbucket.org -w %{http_code} | tail -n1`
    # print ret
    echo "$ret"
    # judge 301 and 302, avoid github.com/www.github.com,http_code reture 301 & 302
    # judge http return code:200, regula no goto
    if [ "$ret" = "302" ] || [ "$ret" = "301" ] || [ "$ret" = "200" ]; then
        echo "$target connect succeed"
        exit 0
    else
        echo "$target connect failed"
        exit 1
    fi
}

# call function
checkNetwork
