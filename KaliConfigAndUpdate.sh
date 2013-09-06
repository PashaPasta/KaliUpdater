	

    #!/bin/bash
    # This script is intended for those who are new to Kali Linux and may not know what they need to do in terms of getting
    # Kali set up and configured for basic uses.  Contact thejesterrace87@gmail.com with bug info.
     
     
    echo Starting postgresql and metasploit services...
    service postgresql start
    service metasploit start
    read -p "Do you want postgresql and metasploit to start on boot? [y/n] " answer1
    if [[ $answer1 = y ]] ; then
    echo ...Updating rc.d...
    update-rc.d postgresql enable
    update-rc.d metasploit enable
    fi
    read -p "Would you like to setup OpenVAS now? [y/n] " answer2
    if [[ $answer2 = y ]] ; then
    echo ...Starting OpenVAS setup...
    openvas-setup
    echo ...Now starting setup diagnostics, results will be saved to /Desktop/openvas-info.txt
    sleep 10
    echo ...May this stage may appear to be doing nothing, be patient...
    openvas-setup --check-install > /home/root/Desktop/openvas-info.txt
    echo ...Updating OpenVAS Definitions
    openvas-nvt-sync
    openvas-feed-update
    print "...Note: default openVAS user name is admin NOT ROOT"
    echo ...openvas setup should be complete, check openvas-info.txt for errors
    fi
    sleep 2
    read -p "Would you like to install tor? [y/n] " answer3
    if [[ $answer3 = y ]] ; then
    apt-get install tor privoxy vidalia polipo
    echo Configuring the tor proxy for you...
    echo forward-socks4a / 127.0.0.1:9050 >> /etc/privoxy/config
    sed "695s/#listen-address       127.0.0.1:8118/" /etc/privoxy/config
    fi
    sleep 3
    read -p "Do you want to add the Bleeding Edge repo to your sources? [y/n]" answer4
    if [[ $answer4 = y  ]] ; then
    echo deb http://repo.kali.org/kali kali-bleeding-edge main >> /etc/apt/sources.list
    fi
    read -p "Do you want to update Kali Linux now? WARNING This may take up to an hour to complete... [y/n]" answer5
    if [[ $answer5 = y ]] ; then
    echo Hope you have a something to kill time for a while...
    apt-get update  && apt-get -y upgrade && apt-get -y dist-upgrade
    fi
    print "This completes the script, goodluck and  don't get in too much trouble..."

