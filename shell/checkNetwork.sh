#!/bin/bash -e

##################################################
# FileName : Ju.sh                       #
# Create   : 2015Äê10ÔÂ27ÈÕ                        #
# Author   : Doungni                               #
# Describe : judge network,by funcrion
# Update   :                                       #
#                                                #
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
