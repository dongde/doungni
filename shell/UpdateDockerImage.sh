#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-11-26 18:03
# * Filename      : UpdateDockerImage.sh
# * Description   : 
################################################################################################

################################################################################################
# * Parameter         :
#   docker_image_name : By jenkins job configuration
#   docker_image_path : By jenkins job configuration
#   docker_daemon_port: By jenkins job configuration
#   split_file_size   : By jenkins job configuration
#
################################################################################################

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
function Update_docker_image() {
    # from jenkins container to docker daemon server
    ssh -tt -p ${docker_daemon_port} root@${docker_daemon_ip} <<EOF
        cd ${docker_image_path}

        if [ -r *.md5 ]; then
            md5sum -c *.md5
            if [ "x$?"="x0" ]; then
                cat \`find ! -name "*.md5" ! -name "*.sh*" ! -name "*.tar.gz" ! -name "*.*"\` > ${docker_image_name}
            else
                log "md5 verify failed"
            fi
        else
            log "*.md5 can not read"
        fi

        docker -v
        if [ "x$?"="x0" ]; then
            docker load -i ${docker_image_name}

            docker run -td --privileged ${appoint_update_docker} /bin/bash
            log "docker images install success"
        fi

        exit
EOF
}

# Need to determine whether the command md5sum can be used

docker_daemon_ip=$(recognize_docker_daemon_ip)
if [ -z $docker_daemon_ip ]; then
    echo "ERROR: failed to recognize docker daemon ip"
    exit 1
else
    echo "docker_daemon_ip: ${docker_daemon_ip}"
fi

Update_docker_image
# When used to remove #
#rm *.tar.gz
