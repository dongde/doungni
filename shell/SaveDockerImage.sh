#!/bin/bash -xe
################################################################################################
# * Author         : doungni
# * Email          : doungni@doungni.com
# * Last modified  : 2015-11-24 00:46
# * Filename       : SaveDockerImage.sh
# * Description    : 
################################################################################################

################################################################################################
# * Parameter         :
#   docker_image_name : By jenkins job configuration
#   docker_image_path : By jenkins job configuration
#   docker_daemon_port: By jenkins job configuration
#   split_file_size   : By jenkins job configuration
#   file_md5_path     : ${image_path}/file_md5_path
#
################################################################################################


# print log message
function log() {
    local msg
    echo `date +'[%Y-%m-%d %H-%M-%S']` "\n $msg\n"
}

# recognize docker daemon ip
# by current known daemon ip judge
function recognize_docker_daemon_ip() {
    local docker_daemon_ip=""
    maybe_ip="172.17.0.1 172.17.42.1 172.18.0.1 172.18.42.1 192.168.50.10 192.168.99.1"
    maybe_ip=($maybe_ip)
    for ip in ${maybe_ip[*]}; do
	if ping -c3 $ip 2>/dev/null 1>/dev/null; then
	    docker_daemon_ip=$ip
	    break
	fi
    done
    
    echo $docker_daemon_ip
}

# save docker image, by ssh method
function save_docker_image() {

    # from jenkins container to docker daemon server
    ssh -tt -p ${docker_daemon_port} root@${docker_daemon_ip} <<EOF
        mkdir -p ${docker_image_path}

        cd ${docker_image_path}
	    mkdir -p ${docker_image_name%%.*}_${datefile}

        if [ -r ${docker_image_name} ]; then
	        cd ${docker_image_name%%.*}_${datefile}
            split -b ${file_size} ../${docker_image_name} ${docker_image_name%%.*}
	        md5sum \`ls ${docker_image_name%%.*}*\` > ${docker_image_name%%.*}.md5
        else
	        log "The ${image_name} can not found in the ${docker_image_path}"
        fi
        exit 1
EOF
}

################################## Entrance  ##############################################

# each file split bytes
file_size=$(( ${split_file_size} * 1024 * 1024 ))

datefile=`date +%Y-%m-%d`

docker_daemon_ip=$(recognize_docker_daemon_ip)
if [ -z $docker_daemon_ip ]; then
    echo "ERROR: failed to recognize docker daemon ip"
    exit 1
else 
    echo "docker_daemon_ip: ${docker_daemon_ip}"
fi

save_docker_image
