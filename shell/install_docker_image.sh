#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-11-26 15:27
# * Filename      : install_docker_image.sh
# * Description   : 
################################################################################################

# print log message
function log() {
    local msg
    echo `date +'[%Y-%m-%d %H-%M-%S']` "\n $msg\n"
}

# Need to determine whether the command md5sum can be used

function docker_verify_load() {
    cd ./

    if [ -r *.md5 ]; then
        md5sum -c *.md5
        return_val=$?
        if [ "x${return_val}"="x1" ]; then
    	    log "md5 verify failed"
        else
    	    cat $(find ! -name "*.md5" ! -name "*.sh*" ! -name "*.tar.gz" ! -name "*.*") > iam_docker_image.tar.gz
        fi
    else
        log "*.md5 can not read"
    fi
    
    docker -v
    return_val2=$?
    if [ "x${return_val2}"="x0" ]; then
        # When used to remove #
        #docker load  iam_docker_iamge.tar.gz

        # When used to remove #
    	# Check if docker is installed
    	#docker run -td --privilege denny/osc:latest /bin/bash
    	log "docker images install success"
    fi
}

docker_verify_load
# When used to remove #
#rm *.tar.gz
