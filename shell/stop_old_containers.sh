#!/bin/bash -e
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-12-03 15:08
# * Filename      : stop_old_containers.sh
# * Description   : stop old containers
################################################################################################

################################################################################################
# * By Jenkins config
#       retain_running_days : Over a given period of time will be stop
#       docker_daemon_ip_port: Docker daemon server ip:port
#       regular_white_list: Regular expressions are supported
# * By define parameter
#       ssh_identity_file ssh_connet white_list running_contianer_names 
#       stop_container_list flag count_v container_name container_start_sd
#       container_start_ts server_current_ts
################################################################################################

############################## Function Start ##################################################
function log() {
    local msg=$*
    echo -e `date +'[%Y-%m-%d %H-%M-%S]'` "\n$msg\n"
}

# Docker client version gather than 1.7.1
function stop_expired_container() {
    # Save running container names 
    running_container_names=($($ssh_connect docker ps | awk '{print $NF}' | sed '1d'))
    log "Docker daemon: $daemon_ip:$daemon_port current running container list[${#running_container_names[@]}]:\n${running_container_names[@]}"

    # Count variable 
    local count_v=0

    # Continue to traverse the currently running container on the server
    for container_name in "${running_container_names[@]}"
    do
        # parameter: container_start_sd, container_start_ts server_current_ts only used in the Docker version 1.9.1
        # time format:standard -> sd, timestamp -> ts; use: "docker inspect -f"-format the output using the given go template
        container_start_sd=$($ssh_connect docker inspect -f '{{.State.StartedAt}}' $container_name)
        container_start_ts=$($ssh_connect date +%s -d $container_start_sd)

        # get remote server current timestamp
        server_current_ts=$($ssh_connect date +%s)

        # 1day =24h =1440min =86400s
        if [ $(($server_current_ts-$container_start_ts)) -lt $(($retain_running_days*86400)) ]; then
            log "Container: [$container_name] do not do any operation for less than $retain_running_days days"
            continue
        fi

        if [ ${#white_list[@]} -gt 0 ]; then
            # Mark variable
            local flag=0
            for white_name in "${white_list[@]}"
            do
                # Find the container in the white list and mark it as 1
                if [ $container_name = $white_name ]; then
                    flag=1
                    break
                fi
            done

            if [ $flag -eq 0 ]; then
                log "Container: [$container_name] not in the white list, Will be stopped"
                #$ssh_connect docker stop $container_name

                # Store is not white list and the need to stop the container
                stop_container[count_v]=$container_name
                count_v=$((count_v+1))
            fi
        else
            log "No white list! Containers:[$container_name] will be stopped for more than $retain_running_days days"
            #$ssh_connect docker stop $container_name

            # For each cycle of the container needs to stop
            stop_container[count_v]=$container_name
            count_v=$((count_v+1))
        fi
    done
}

# main entry function
function main_entry() {
    for ip_port in "${docker_daemon_ip_port[@]}"
    do
        daemon_ip_port=(${ip_port//:/ })
        daemon_ip=${daemon_ip_port[0]}
        daemon_port=${daemon_ip_port[1]}

        # SSH connect parameter
        ssh_connect="ssh -p $daemon_port -i $ssh_identity_file -o StrictHostKeyChecking=no root@$daemon_ip"

        if [ ${#regular_white_list[@]} -gt 0 ]; then
            for regular in "${regular_white_list[@]}"
            do
                regular_list=($($ssh_connect docker ps | awk '{print $NF}' | sed '1d' | grep -e "^$regular"))||true
                white_list+=("${regular_list[@]}")
            done
            
            log "Docker daemon $daemon_ip:$daemon_port white list[${#white_list[@]}]:\n${white_list[@]}"
        else
            log "Will stop all containers that have started more than $retain_running_days days"
        fi

        # Call stop expired container function
        stop_expired_container

        log "Docker daemon server: $daemon_ip:$daemon_port operation is completed!"
        stop_container_list+=("${daemon_ip}:${daemon_port} stop container list:\n${stop_container[@]}\n")
    done

    if [ ${#stop_container_list[@]} -gt 0 ]; then
        log "${stop_container_list[@]}"
        exit 1
    fi
}

############################## Function End ####################################################

############################## Shell Start #####################################################

ssh_identity_file="/var/lib/jenkins/.ssh/id_rsa"

# Jenkins parameter judge
if [ $retain_running_days -lt 0 ]; then
    log "ERROR: $retain_running_days must be greater than or equal to 0"
    exit 1
fi

if [ -z "$docker_daemon_ip_port" ]; then
    log "$docker_daemon_ip_port can not find"
    exit 1
fi
docker_daemon_ip_port=(${docker_daemon_ip_port// / })

if [ -n "$regular_white_list" ]; then
    regular_white_list=(${regular_white_list// / })
else
    log "Regular white list is empty, will stop over than $retain_running_days all containers"
fi

# Call main entry function
main_entry

############################## Shell End #######################################################
