#!/bin/bash

setupType=install

whoAmI=$(whoami)
if [[ "root" != ${whoAmI} ]];
then
    su
fi

while getopts "u" opt
do
    case $opt in
    u ) setupType=uninstall
        ;;
    ? ) echo "error"
        exit 1
        ;;
    esac
done
shift $(($OPTIND - 1))
if (($# != 0));
then
	echo -e "error, unknown para \"$1\""
	exit
fi

###########Set up dhcp server.###########
if [ ${setupType} = "install" ];
then
    if ! (service dhcpd status 1>/dev/null 2>&1);
    then
        yum -y install dhcp
        cp ./dhcpd.conf /etc/dhcp/dhcpd.conf
        
        chkconfig dhcpd on
        service dhcpd start
    fi
else
	service dhcpd stop
    yum -y erase dhcp
    rm -rf /etc/dhcp/dhcpd.conf
fi

exit 0