#!/bin/bash -ex
#/**********************************************************
 # Author        : doungni
 # Email         : 2303134@qq.com
 # Last modified : 2015-11-03 15:10
 # Filename      : CollectLog.sh
 # Description   : 
 # *******************************************************/

 function log() {
    local msg=$*
    echo -ne `date +['%Y-%m-%d %H:%M:%S']` "==== $msg ====\n"
 }

 function jenkins_Log() {

}
