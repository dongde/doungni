#!/bin/bash -e
#######################################################################################
#  Author        : doungni
#  Email         : doungni@doungni.com
#  Last modified : 2015-11-04 10:53
#  Filename      : collect_logfile.sh
#  Description   : collect logfile, by ssh 
#######################################################################################

#######################################################################################
# env variables  : work_path, collect_time, ssh_key_file, server_list, logfile_list
#                  tail_line, retention_day
# env value
# work_path:     : ${WORKSPACE}
# collect_time   : `date+'%Y%m%d-%H%M%S'`
# ssh_key_file   : "${JENKINS_HOME}/.ssh/id_rsa"
# server_list    : By jenkins job configuration
# logfile_list   : By jenkins job configuration
# tail_line      : By jenkins job configuration
# retention_day  : By jenkins job configuration
#######################################################################################

############################ collect_logfile.sh Start #################################

function log() {
    local msg=$*

    echo -e `date +['%Y-%m-%d %H-%M-%S']` "\n$msg\n"
}

#######################################################################################
# Paramenter     : server_list, server_arr[], server_split[], server_ip, server_port
#                  server_hostname, ssh_result, logfile_list, logfile_parent_dir
#                  logfile_name, tail_line
# Function       :
#                  split each server
#                  split ip and port
#                  connect server
#                  collect logfile
#                  compress logfile
#                  output download path
#######################################################################################
function collect_logfile() {
    # Non NULL judgment of ${server_list}
    if [ -z "${server_list}" ]; then
        log "Error: Please refer to the correct parameters for the prompt configuration"
        exit 1
    fi

    # Each server is separated by a comma
    server_arr=(${server_list//,/ })

    # If the server_arr has duplicate elements, the duplicate removal operations
    len=${#server_arr[*]}

    for (( i = 0; i < $len; i++ ))
    do
        for (( j = $len -1; j > i; j-- ))
        do
            if [[ ${[i]} = ${server_arr[j]} ]]; then
                unset server_arr[i]
            fi
        done
    done

    # If the server_arr has duplicate elements, output warning information
    re_len=${#server_arr[*]}

    if [[ ${re_len} -lt ${len} ]]; then
        echo "Warning: You enter the Server: Ip:Port to have a repeat"
    fi

    # Re count the need to collect the server, use variable count_machine
    local count_machine=0
    for re_server_arr in ${server_arr[*]}
    do
        count_machine=`expr ${count_machine} + 1`
        echo -e "Need to collect the log file Server Machine ${count_machine}:\nIp:Port\n${re_server_arr}\n"
    done

    # Count current traversal of the server, use variable count_traversal
    local count_traversal=0
    for server in ${server_arr[*]}
    do
        server_split=(${server//:/ })
        server_ip=${server_split[0]}
        server_port=${server_split[1]}

        count_traversal=`expr ${count_traversal} + 1`
        echo "--------------------------------------"
        echo -e "Collect log files from:\nServer Machine: ${count_traversal}\nServer Ip: ${server_ip}\nServer Port: ${server_port}"

        # Check if IP:PORT can connect, timeout 1 seconds
        nc_return=`nc -w 1 ${server_ip} ${server_port} && echo yes || echo no`

        if [ "x${nc_return}" == "xyes" ]; then
            # New logfile save folder, named: ip-port
            mkdir -p ${work_path}/${server_ip}-${server_port}
            cd ${work_path}/${server_ip}-${server_port}
    
            # Count collecting log on the server, use variable count_logfile
            local count_logfile=0
            # Cycle logfile_list
            for logfile in ${logfile_list[*]}
            do
                count_logfile=`expr ${count_logfile} + 1`
                echo "======================================"
                echo "Collect log files:${count_logfile}"

                # Get server_ip hostname
                server_hostname=`ssh -i ${ssh_key_file} -p ${server_port} -o StrictHostKeyChecking=no root@${server_ip} "hostname"`
                
                # By connect ip collect logfile
                echo -e "\nCurrent collection of log information:\nServer Hostname: ${server_hostname}\nServer Ip: ${server_ip}\nServer Port: ${server_port}\nLog file: $logfile\n"
    
                # True if logfile exists and is readable
                ssh_result=`ssh -i ${ssh_key_file} -p ${server_port} -o StrictHostKeyChecking=no root@${server_ip} "test -r ${logfile}" && echo yes || echo no`
    
                # If exist and readable
                if [ "x${ssh_result}" == "xyes" ]; then
                    # deal with logfile
                    logfile_parent_dir=${logfile%/*}
                    mkdir -p ${logfile_parent_dir#*/}
                    logfile_name=${logfile##*/}
    
                    # ${tail_line} less equal 0 or null
                    if [ $tail_line -le 0 ] || [ -z $tail_line ];then
                        log "Error: Invalid parameter for ${tail_line}. It should be positive integer"
                        exit 1
                    else
                        # collect the tail line of the log file.
                        ssh -i ${ssh_key_file} -p ${server_port} -o StrictHostKeyChecking=no root@${server_ip} "tail -n ${tail_line} ${logfile}" > ./${logfile_parent_dir}/${logfile_name}
                    fi
    	        else
                    echo -e "Warning: The log files:\n${logfile}\nIs not present or not readable on the Server:\nIp:Port-${server_ip}:${server_port}\n"
                fi
            done

            if [ `ls | wc -l` -gt 0 ]; then
                # Pack all the log files in the server
                cd ${work_path}
                            
                # compress current named:hostname-server_ip-server_port-current_time logfile
                echo "Tar current Server:${server_ip}:${server_port} collected log files:"
                tar -zcvf ${server_hostname}-${server_ip}-${server_port}-${collect_time}.tar.gz ${server_ip}-${server_port}/*
            else
                echo -e "\nWarning: The ${server_ip}-${server_port} folder is empty,did not collect the log file\n"
            fi

            # Delete ${server_ip}
            rm -rf ${server_ip}-${server_port}
        else
            echo -e "\nWarning:Can not collect the log file in the Server:${server_ip}:${server_port}\nNotice:Please check if the network is connected or otherwise\n"
        fi
    done
    
    if [ `ls | wc -l` -gt 0 ]; then
        # Download logfile
        echo -e "\nGenerate log files download link:\n${JOB_URL}/ws\n"
    else
        echo -e "\nWarning: Log packege is empty!\n"
    fi
}

#######################################################################################
# Shell Entracnce 
#######################################################################################
# Parameter for current time
collect_time=`date +'%Y%m%d-%H%M%S'`

ssh_key_file="${JENKINS_HOME}/.ssh/id_rsa"

work_path="${WORKSPACE}/${JOB_NAME}-${collect_time}"
[ ! -d ${work_path} ] && mkdir -p ${work_path}
cd ${work_path}

# connect server and collect logfile
collect_logfile

# Delete retention day tar
find_return=`find ${WORKSPACE} -mtime ${retention_day} -name "${JOB_NAME}*"`
stat_return=`echo "${find_return}" | grep ${JOB_NAME}*`
if [ $? -eq 0 ]; then
    find ${WORKSPACE} -mtime ${retention_day} -name "${JOB_NAME}*" -exec rm -rf {} \+
    echo -e "\nWarning: You have deleted the folder:\n${find_return}"
else
    echo -e "\nNotice: You did not delete any folders"
fi
############################ collect_logfile.sh End #################################
