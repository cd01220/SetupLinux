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

##########Set up telnet server.############
if [ ${setupType} = "install" ];
then
    if [ ! -e /etc/xinetd.d/telnet ];
    then
        yum -y install telnet telnet-server
        chkconfig telnet on
        service xinetd restart
    fi
else
    yum -y erase telnet telnet-server
fi

exit 0