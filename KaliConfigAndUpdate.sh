#!/bin/bash

# Kali Configuration and Updater version 2.0
# This script is intended for use in new Kali Linux Installations
# Please contact thejesterrace87@gmail.com with bugs or feature requests

printf "

			#############################
			# KaliUpdater and Config v2 #
			#############################

	##############################################################
	# Welcome, you will be presented with a few questions, please#
	#          answer [y/n] according to your needs.             #
	##############################################################\n\n"

# Functionality for flags

# Ask Initial questions
function questions() {
read -p "Do you want to add the Bleeding Edge repo for more regular updates? [y/n] " answerRepo
read -p "Do you want to install updates to Kali Linux now? [y/n] " answerUpdate
read -p "Do you want the metasploit and postgresql services to start on boot? (Recommended) [y/n] "
read -p "Do you want to setup OpenVAS? (Note: You will be prompted to enter a password for the OpenVAS admin user, this process may take up to an hour) [y/n] " answerOpenVAS
read -p "Do you want to install and setup TOR with Privoxy? [y/n] " answerTOR
read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
}

# If script run with -a flag, all options will automatically default to yes

if [[ $1 = -a ]] ; then
	
	answerRepo=y
	answerUpdate=y
	answerOpenVAS=y
	answerTOR=y
	answerNikto=y
else 

	questions

fi



# Logic for update and configuration steps

 

if [[ $answerRepo = y ]] ; then

        echo deb http://repo.kali.org/kali kali-bleeding-edge main >> /etc/apt/sources.list
fi

if [[ $answerUpdate = y ]] ; then
        
	printf "Updating Kali Linux, this stage may take about an hour to complete...
	"
        sleep 3
	apt-get update -qq && apt-get -y upgrade -qq && apt-get -y dist-upgrade -qq
fi

if [[ $answerServices = y ]] ; then        

        service postgresql start
    	service metasploit start

	update-rc.d postgresql enable
        update-rc.d metasploit enable
fi

if [[ $answerOpenVAS = y ]] ; then

        echo ...Starting OpenVAS setup...Please be ready to enter desired OpenVAS admin password
    
                openvas-setup
        	openvas-setup --check-install > /root/Desktop/openvas-info.txt
     		openvas-nvt-sync
                openvas-feed-update
                 
fi

if [[ $answerTOR = y ]] ; then

            apt-get -y -qq install tor privoxy vidalia polipo

            echo forward-socks4a / 127.0.0.1:9050 >> /etc/privoxy/config
            echo listen-address 127.0.0.1:8118 >> /etc/privoxy/config
fi
	
if [[ $answerNikto = y ]] ; then

	nikto -update
fi

# If OpenVAS was installed, check for error file, if present, print alert

function filecheck () {
	file="/root/Desktop/openvas-info.txt"

	if [ -f "$file" ] ; then
		printf "Check /root/Desktop/openvas-info.txt for errors and recommendations
		"
	fi
}	
if [[ $answerOpenVAS = y ]] ; then

file="/root/Desktop/openvas-info.txt"

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

function pause () {
        read -p "$*"
}
    
pause '
	Press [Enter] key to finish script...
	'
