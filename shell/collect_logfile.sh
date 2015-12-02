#!/bin/bash -xe
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
        log "Please refer to the correct parameters for the prompt configuration"
        exit 1
    fi

    # Each server is separated by a comma
    server_arr=(${server_list//,/ })

    # Count collecting log on the server, use variable m
    local count_server=0
    for i in ${server_arr[*]}
    do
        count_server=`expr ${count_server} + 1`
        echo -e "\nNeed to collect the logfile Server ${count_server}:\nIp:Port\n$i\n"
    done

    # Count current traversal of the server, use variable n
    local count_traversal=0
    for server in ${server_arr[*]}
    do
        server_split=(${server//:/ })
        server_ip=${server_split[0]}
        server_port=${server_split[1]}

        count_traversal=`expr ${count_traversal} + 1`
        echo -e "\nStart to collect the log of the ${count_traversal} server:\nServer_ip:${server_ip}\nServer_port:${server_port}\n"

        # Check if IP:PORT can connect
        echo -e "\n" | telnet ${server_ip} ${server_port} | grep Connected 2>/dev/null 1>/dev/null

        if [ $? -eq 0 ]; then
            echo "New logfile save folder, named: ip-port"
    	    mkdir -p ${work_path}/${server_ip}-${server_port}
    	    cd ${work_path}/${server_ip}-${server_port}
    
            # Count collecting log on the server, use variable m
            local count_logfile=0
            # Cycle logfile_list
            for logfile in ${logfile_list[*]}
            do
                count_logfile=`expr ${count_logfile} + 1`
                echo -e "\nStart to collect logfile:${count_logfile}\n"

                # Get server_ip hostname
                server_hostname=`ssh -i ${ssh_key_file} -p ${server_port}  -o StrictHostKeyChecking=no root@${server_ip} "hostname"`
                
                # By connect ip collect logfile
                echo -e "\nCurrent collection of log information:\nHostname:${server_hostname}\nServer_ip:${server_ip}\nServer_port:${server_port}\nLogfile: $logfile\n"
    
                # True if logfile exists and is readable
                ssh_result=`ssh -i ${ssh_key_file} -p ${server_port}  -o StrictHostKeyChecking=no root@${server_ip} "test -r ${logfile}" && echo yes || echo no`
    
                # If exist and readable
                if [ "x${ssh_result}" == "xyes" ]; then
                    # deal with logfile
                    logfile_parent_dir=${logfile%/*}
                    mkdir -p ${logfile_parent_dir#*/}
                    logfile_name=${logfile##*/}
    
                    # ${tail_line} less equal 0 or null
                    if [ $tail_line -le 0 ] || [ -z $tail_line ];then
                        log "Please refer to the correct parameters for the prompt configuration"
                    else
                        # collect the tail line of the log file.
                        ssh -i ${ssh_key_file} -p ${server_port} -o StrictHostKeyChecking=no root@${server_ip} "tail -n ${tail_line} ${logfile}" > ./${logfile_parent_dir}/${logfile_name}
                    fi
    	        else
                    echo -e "\nThe logfile:${logfile}\nOn the server[ip:port-${server_ip}:${server_port}] is not readable or does not exist\n"
                fi
            done

            if [ `ls | wc -l` -ge 0 ]; then
                # Pack all the log files in the server
                cd ${work_path}
                            
                # compress current named:hostname-server_ip-server_port-current_time logfile
                tar -zcvf ${server_hostname}-${server_ip}-${server_port}-${collect_time}.tar.gz ${server_ip}-${server_port}/*
            else
                echo -e "\nThe ${server_ip}-${server_port} folder is empty,did not collect the log file\n"
            fi

            # Delete ${server_ip}
            rm -rf ${server_ip}-${server_port}
        else
            echo -e "\nCan not collect logfile in the:\n[Hostname:${hostname}]\n[ServerIp:Port:${server_ip}:${server_port}]\nNotice:Please check if the network is connected or otherwise\n"
        fi
    done
    
    if [ `ls | wc -l` -ge 0 ]; then
        # Download logfile
        echo -e "\nDownload log package link:${JOB_URL}/ws\n"
    else
        echo -e "\nSorry, Log packege is empty!\n"
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
find ${WORKSPACE} -mtime +${retention_day} -name "${JOB_NAME}*" -exec rm -rf {} \+
############################ collect_logfile.sh End #################################
