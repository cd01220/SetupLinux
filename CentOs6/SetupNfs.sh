#!/bin/bash

setupType=install

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

###########Set up ftp server.###########
#client command:  mount -t nfs -o nolock 10.0.0.2:/var/lib/tftpboot /mnt
if [ ${setupType} = "install" ];
then
    if ! (service nfs status 1>/dev/null 2>&1);
    then
		yum install nfs-utils
		yum install rpcbind
        
		echo "/var/lib/tftpboot 10.0.0.0/24(rw,sync) *(rw)" > /etc/exports 
		chkconfig rpcbind on
		chkconfig nfs on
        service rpcbind start
		service nfs start
    fi
else
	sed -ie '/^\/var\/lib\/tftpboot/d' /etc/exports
	service rpcbind stop
	service nfs stop
    yum -y nfs-utils vsftpd
	yum -y nfs vsftpd
fi

exit 0
