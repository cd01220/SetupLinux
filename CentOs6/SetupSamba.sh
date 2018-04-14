#!/bin/bash

localUserName=liuhao
setupType=install

while getopts "l:u" opt
do
    case $opt in
    l ) localUserName=$OPTARG
        ;;
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

###########Set up samba server.###########
if [ ${setupType} = "install" ];
then
    if ! (service smb status 1>/dev/null 2>&1);
    then
        yum -y install samba
		
        smbpasswd -a ${localUserName}
        setsebool -P samba_enable_home_dirs=1
        
        chkconfig smb on
        chkconfig nmb on
        service smb start
        service nmb start
    fi
else
    #erase samba* could delete /etc/samba/* together.  /etc/samba/smb.conf will be created by samba-common
	service smb stop
    service nmb stop
    yum -y erase samba*
fi

exit 0
