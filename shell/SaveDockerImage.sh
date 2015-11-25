#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-11-24 00:46
# * Filename      : SaveDockerImage.sh
# * Description   : 
################################################################################################

################################################################################################
# * Parameter     :
#   image_path    : By jenkins job configuration
#   image_name    : By jenkins job configuration
#   splitfile_md5 : By jenkins job configuration
#
################################################################################################

if [ -z ${image_path} ]; then
    image_path=`mkdir -p ~/docker_file`
fi

if [ -z ${image_name} ]; then
    image_name="iam_docker.tar.gz"
fi

# print log message
function log() {
    local msg
    echo `data +'[%Y-%m-%d %H-%M-%S']` "\n $msg\n"
}

# image host ssh port
ssh_port=2703
# docker daemon ip
daemon_ip="172.17.42.1"

function save_image() {
    local split_image
    local 

    # from jenkins container to docker daemon server
    ssh_return=`ssh -p ${ssh_port} root@ ${daemon_ip} "df -h" && echo yes || echo no`
    
    if [ "x${ssh_return}" = "xyes" ]; then
        # save docker image
        #docker save ${docker_image} > iam_docker.tar.gz
        cd ${image_path}
    
        if [ -e ${image_name} ]; then
            # split_images="iam_docker.tar.gz"

            split_iam=`split -b 314572800 ${image_name} split_image`
    
            for split_image in ${split_iam[*]}
            do
                md5check split_image >> split_iam.md5

                cp split_image* split_iam.md5 ${splitfile_md5}
            done
        else
            log "####### ${image_name} can not found in ${image_path} path #######"
        fi
    else
        log "####### Can not collect docker daemon host, Please check you config #######"
    fi
}
