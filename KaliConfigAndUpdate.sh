#!/bin/bash

# Kali Configuration and Updater version 3.0
# This script is intended for use in new Kali Linux Installations
# Please contact thejesterrace87@gmail.com with bugs or feature requests


# Changelog:
# 7/2/2014: Added VPN installation option, Added additional tool installations, Added gnome-tweak-tool
# 7/18/2014: Fixed rawr.py install, rawr devs changed from --check-install to -U
# 7/27/2014: Added git and svn protocol updaters for existing git clones and svn checkouts; fixed a few formatting issues 
printf "

###############################
# KaliUpdater and Config v3.0 #
###############################

##############################################################
# Welcome, you will be presented with a few questions, please#
# answer [y/n] according to your needs. #
##############################################################\n\n"



# Questions function
function questions() {
read -p "Do you want to add the Bleeding Edge repo for more regular updates? [y/n] " answerRepo
read -p "Do you want to install updates to Kali Linux now? [y/n] " answerUpdate
read -p "Do you want to install packages required for VPN functionality? [y/n] " answerVPN
read -p "Do you want the metasploit and postgresql services to start on boot? (Recommended) [y/n] " answerServices
read -p "Do you want to setup OpenVAS? (Note: You will be prompted to enter a password for the OpenVAS admin user, this process may take up to an hour) [y/n] " answerOpenVAS
read -p "Do you want to install and setup TOR with Privoxy? [y/n] " answerTOR
read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
read -p "Do you want to download additional tools and scripts for pentesting purposes? [y/n]" answerScripts
read -p "Do you want to find and install updates to all svn and git tools previously installed? [y/n]" answerSVN
}

#Flags!!!!
# If script run with -a flag, all options will automatically default to yes
# IF script run with -h flag, README.md will be displayed

if [[ $1 = -a ]] ; then

read -p "Are you sure you want to install all packages and configure everything by default? [y/n] " answerWarning
if [[ $answerWarning = y ]] ; then
answerRepo=y
answerUpdate=y
answerVPN=y
answerServices=y
answerOpenVAS=y
answerTOR=y
answerNikto=y
answerScripts=y
answerSVN=y
else
printf "Verify would you do and do not want done...."
sleep 2
questions
fi

elif [[ $1 = -h ]] ; then

cat README.md
exit
else

questions

fi



# Logic for update and configuration steps



if [[ $answerRepo = y ]] ; then

        echo deb http://repo.kali.org/kali kali-bleeding-edge main >> /etc/apt/sources.list
fi

if [[ $answerUpdate = y ]] ; then

printf "Updating Kali Linux, this stage may take about an hour to complete...Hope you have some time to burn...
"
apt-get update -qq && apt-get -y upgrade -qq && apt-get -y dist-upgrade -qq
  apt-get install unrar unace rar p7zip zip unzip p7zip-full p7zip-rar file-roller -y
  apt-get install flashplugin-nonfree -y
  update-flashplugin-nonfree --install
  apt-get install htop nethogs gnome-tweak-tool -y
fi

# Add VPN Installation step here
if [[ $answerVPN = y ]] ; then

  apt-get -y install network-manager-openvpn network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome network-manager-strongswan network-manager-vpnc network-manager-vpnc-gnome

fi

if [[ $answerServices = y ]] ; then

  service postgresql start
  service metasploit start

  update-rc.d postgresql enable
  update-rc.d metasploit enable
fi

if [[ $answerOpenVAS = y ]] ; then

        echo ...Starting OpenVAS setup...Please be ready to enter desired OpenVAS admin password

                apt-get -y install nsis rpm
                openvas-setup
                openvas-setup --check-install > /var/log/KaliUpdater.log
                openvas-nvt-sync
                openvas-feed-update

fi

if [[ $answerTOR = y ]] ; then

            apt-get -y -qq install tor privoxy vidalia polipo

            echo forward-socks4a / 127.0.0.1:9050 . >> /etc/privoxy/config
            echo forward-socks4 / 127.0.0.1:9050 . >> /etc/privoxy/config
            echo forward-socks5 / 127.0.0.1:9050 . >> /etc/privoxy/config
            echo listen-address 127.0.0.1:8118 >> /etc/privoxy/config
fi

if [[ $answerNikto = y ]] ; then

nikto -update
fi

# If OpenVAS was installed, check for error file, if present, print alert

function filecheck () {
file="/var/log/KaliUpdater.log"

if [ -f "$file" ] ; then
printf "Check /var/log/KaliUpdater.log for errors and recommendations
"
fi
}
if [[ $answerOpenVAS = y ]] ; then

file="/var/log/KaliUpdater.log"

filecheck
printf "Note: OpenVAS user name is [admin]
"
sleep 3
fi

if [[ $answerTOR = y ]] ; then
printf "TOR has been configured with Privoxy, set your browser to use a socks4 proxy on localhost:8118
"
sleep 3
fi

if [[ $answerScripts = y ]] ; then
printf "Downloading scripts...."
mkdir /root/scripts
cd /root/scripts
git clone https://bitbucket.org/al14s/rawr.git
cd rawr
apt-get install python-pygraphviz
python rawr.py -U
#Add other tools here

fi

if [[ $answerSVN = y ]] ; then
  # Start git updater
  find . -name .git -type d -prune > /tmp/gitsfound.txt
  rev /tmp/gitsfound.txt | cut -c 5- | rev > /tmp/gitsfound-fixed.txt
  cat /tmp/gitsfound-fixed.txt | cut -c 3- | grep '[a-z]' > /tmp/gitsfound-fixed2.txt
  for i in `cat /tmp/gitsfound-fixed2.txt`; do cd /root/$i && git pull && cd;done
  rm /tmp/gitsfound*
  # Finish git updater

  # Start svn updater
  find . -name .svn -type d -prune > /tmp/svnsfound.txt
  rev /tmp/svnsfound.txt | cut -c 5- | rev > /tmp/svnsfound-fixed.txt
  cat /tmp/svnsfound-fixed.txt | cut -c 3- | grep '[a-z]' > /tmp/svnsfound-fixed2.txt
  for i in `cat /tmp/svnsfound-fixed2.txt` ; do cd /root/$i && svn update && cd;done
  rm /tmp/svnsfound*
  # Finish svn updater

fi

function pause () {
        read -p "$*"
}

pause '
Press [Enter] key to exit...
'
