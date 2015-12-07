#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-11-24 01:15
# * Filename      : LoadDockerImage.sh
# * Description   : 
################################################################################################

${docker_images}
${split_md5}

function log() {
    local msg
        echo "`data +'[%Y-%m-%d %H-%M-%S']`" "\n $msg}"
}
# from jenkins container to docker daemon server
    ssh_return=`ssh -p 2703 root@172.17.42.1 'ls'||echo yes && echo no`

local split_iam
PWD=`pwd`

CD=`mkdir -p ${PWD}/${docker_images}`
cd ${CD}

tar zCxvf /${split_file_path}/split_iam.tar.gz split_iam/

for md5 in md5.txt*
do
    md5sum
done

docker_iam=docker_iam.tar.gz
cat splt* > ${docker_oam}

# import image
docker load -i ${docker_oam}

# new create new container
docker run -td --privilege ${iam_deploy} /bin/bash
