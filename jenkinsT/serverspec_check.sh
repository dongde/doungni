#!/bin/bash -e
##-------------------------------------------------------------------
## File : serverspec_check.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2015-07-29>
## Updated: Time-stamp: <2015-08-07 22:55:37>

##################### 
## Modify   : doungni
## Describe : Add Bitbucket.org judge connect 
## Updated  : 2015-10-28 16:27:52
##-------------------------------------------------------------------

################################################################################################
## env variables: test_spec
## Example:
##      test_spec:
##          describe service('apache2') do
##           it { should be_running }
##          end
##
################################################################################################


function check_Network() {
    #connect timeout
    timeout=7
    # The maximum allowable time data transmission
    maxtime=10
    # check website or ip
    target="bi1tbucket.org"

    ret=`curl -I -s --connect-timeout $timeout -m $maxtime $target -w %{http_code} | tail -n1`
    echo "$ret"

    if [ "$ret" = "302" ] || [ "$ret" = "301" ] || [ "$ret" = "200" ]; then
        echo "$target connect succeed"
        #exit 0
    else
        echo "$target connect failed"
        exit 1
    fi
}


function install_serverspec() {
    if ! sudo gem list | grep serverspec 2>/dev/null 1>/dev/null; then
        sudo gem install serverspec
    fi

    if ! sudo dpkg -l rake 2>/dev/null 1>/dev/null; then
        sudo apt-get install -y rake
    fi
}

function setup_serverspec() {
    working_dir=${1?}
    cd $working_dir
    if [ ! -f spec/spec_helper.rb ]; then
        echo "Setup Serverspec Test case"
        cat > spec/spec_helper.rb <<EOF
require 'serverspec'

set :backend, :exec
EOF

        cat > Rakefile <<EOF
require 'rake'
require 'rspec/core/rake_task'

task :spec => 'spec:all'
task :default => :spec

namespace :spec do
 targets = []
 Dir.glob('./spec/*').each do |dir|
 next unless File.directory?(dir)
 target = File.basename(dir)
 target = "_#{target}" if target == "default"
 targets << target
 end

 task :all => targets
 task :default => :all

 targets.each do |target|
 original_target = target == "_default" ? target[1..-1] : target
 desc "Run serverspec tests to #{original_target}"
 RSpec::Core::RakeTask.new(target.to_sym) do |t|
 ENV['TARGET_HOST'] = original_target
 t.pattern = "spec/#{original_target}/*_spec.rb"
 end
 end
end
EOF
    fi
}

#####################################################
check_Network
working_dir="/var/lib/jenkins/serverspec"
mkdir -p $working_dir/spec/localhost
cd $working_dir

/usr/sbin/locale-gen --lang en_US.UTF-8
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

install_serverspec
setup_serverspec $working_dir

cat > spec/localhost/sample_spec.rb <<EOF
require 'spec_helper'

# Check at least 3 GB free disk
describe command("[ `df -h -B 1G / | tail -n1 | awk -F' ' '{print $4}'` -gt 3 ]") do
  its(:exit_status) { should eq 0 }
end

# Check at least 1 GB free memory
describe command("[ `free -ml | grep 'buffers/cache' | awk -F' ' '{print $4}'` -gt 1024 ]") do
  its(:exit_status) { should eq 0 }
end

$test_spec
EOF

echo "Perform serverspec check"
sudo rake spec
## File : serverspec_check.sh ends
