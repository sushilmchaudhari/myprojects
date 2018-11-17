#!/bin/sh

# Install Puppet agent on Mac to have masterless puppet setup.

OS_VERS=$(cat /etc/redhat-release  | awk '{print $4}' | cut -d. -f1)
#AS_ROOT="/usr/bin/sudo -u $(uname) -H bash -l -c"
UNAME="$USER"
#XCODE_VERS=$(xcodebuild -version | grep Xcode | awk '{print $2}' | cut -d. -f1)

echo "====================================================================================================================="

if [[ ! `/opt/puppetlabs/bin/puppet --version` ]] ;
then
    echo "Installing Puppet agent..."
	
    # Installing puppetlabs repository for CentOS7.

    RPMURL="https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"
    rpm -ivh "$RPMURL"

    # Installing puppet agent

    yum -y install puppet-agent
    RET=`echo $?`
    if "$RET"
    then 
	echo "Puppet installation is successful."
    else
	echo "Puppet installation is UnSuccessful."
	exit
    fi
else
    echo "Puppet agent already installed...No Need to install again."
fi

PATH=/opt/puppetlabs/bin:$PATH; export PATH

echo "====================================================================================================================="


# Installing necessary puppet modules required.

if [[ ! `puppet module list  | grep stdlib` ]]
then
	puppet module install  puppetlabs/stdlib
fi

if [[ ! `puppet module list  | grep staging` ]]
then
        puppet module install  nanliu/staging
fi

if [[ ! `puppet module list  | grep rvm` ]]
then
        puppet module install  maestrodev/rvm
fi

#printf "Before configuring EBA on MAC , want to make sure everything is OK...\n\n"


#if [[ ( "$XCODE_VERS" -ge 7 ) && ( `git --version` ) && ( -d ~/eba ) ]]
#then
#        echo "Necessary softwares are installed and Eba directory is cloned."
#else
#        echo "Please install Xcode if not."
#        echo "Please install and configure Git if not follow: https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-Gitlab"
#        echo "Clone EBA project from Gitlab use command:=> git clone git@git.sic-eba.com:s000176/eba.git"
#        exit
#fi

#echo "====================================================================================================================="

#VMware Fusion
#if [[ -d "/Applications/Vmware Fusion.app/Contents/Library" ]]
#then
#        echo "VMWare Fusion is Installed."
#        echo "Please configure vmware as given in link https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-VMWareFusion"

#else
#        echo "Please install VMware Fusion follow: https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-VMWareFusion"
#        exit
#fi

#echo "====================================================================================================================="

#if [[ ! `sudo cat /etc/hosts | grep -v '^#' | grep ebarubydev` ]]
#then
#        echo "Oracle DB server entry not exist on server."
#        echo "Please check https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-VMWareFusion"
#        echo "to add entry in hosts file."
#        echo "Now exiting."
#        exit
#else
#        ORACLE_IP=$(cat /etc/hosts | grep -v '^#' | grep ebarubydev | awk '{print $1}')
#        PING=$(ping -c 3 "$ORACLE_IP" | grep "packet loss" | awk '{print $7}' | cut -d. -f1)
#        if [[ "$PING" -ne 0 ]]
#        then
#           echo "Oracle DB Server is not reachable. Please check IP/connection.Now exiting"
#           exit
#        else
#           echo "Oracle DB server is reachable."
#        fi
#fi
#
#echo "====================================================================================================================="
#
#echo "Running Puppet manifests to setup Eba dev env and install necessary softwares."
#
#sudo /opt/puppetlabs/bin/puppet apply  ~/eba-mac-setup/manifests/site.pp

#echo "====================================================================================================================="
