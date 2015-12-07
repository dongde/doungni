#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-12-05 08:52
# * Filename      : monitor_it_resource.sh
# * Description   : 
################################################################################################

# Paramentor
#                 : listen_ip, port_start, port_end
# listen_ip       : by jenkins
# port_start      : by jenkins
# port_end        : by jenkins
# listen_domain   : by jenkins
################################################################################################


# 1 Checking IP:PORT
# Arbitrary TCP and UDP connection and listens, port_start to prot end
#nc -w 1 ${listen_ip} -z ${port_start}-${port_end} 

# 2 Checking AUTOSSH
# Listen ssh retunnel effective
ssh_return=`ssh -i ${ssh_rsa} -o StrictHostKeyChecking=no root@${daemon_ip} "netstat -anlp | grep autossh" && echo yes || echo no`
if [ "x${ssh_return}" == "xyes"  ]; then
    echo "The autossh is do well work"
else
    echo "The autossh do not work"
fi

# 3 Checking Domain
# Check domain expired, by "Expiration Date(UTC)" minus "current_date"
current_date=`date +'%Y年%m月%d日'`
echo "${current_date}"
#[ -e listen_domain ] && listen_domain="jingantech.com"

domain_url="http://dc.aliyun.com/login/redirect?targetUrl=http://dc.aliyun.com/basic/domainDetail.htm&domainName=${listen_domain}"
expired_date=curl ${domain_curl} | grep "Expiration Date(UTC)"

if [ expr'${expired_date} - ${current_date}' < 30 ]
    echo "You have to pay the domain ${listen_domain}"
fi

# 4 Checking repo
# Include bitbucket.org and github.com

nc -w 1 ${url_repo}
