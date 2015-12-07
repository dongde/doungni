#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-12-03 15:08
# * Filename      : stop_old_containers.sh
# * Description   : stop old containers
################################################################################################

function verify_command_exists() {
    command -v "$@" > /dev/null 2>&1
}

if verify_command_exists docker && [ -e /var/run/docker.sock ]; then
    (
        set -x
        bash -c `docker version`
    ) || true
fi
