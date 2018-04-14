#!/bin/bash

userName=tftp
localUserName=liuhao
setupType=install

while getopts "n:l:u" opt
do
    case $opt in
    n ) userName=$OPTARG
        ;;
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

###########Set up tftp server.###########
if [ ${setupType} = "install" ];
then
    if [ ! -e /etc/xinetd.d/tftp ];
    then
        if ! (grep "^${userName}:" /etc/passwd 1>/dev/null 2>&1);
        then
            useradd -s /sbin/nologin -r -M -d /var/lib/tftpboot ${userName}
			#in order to make daily work convenient(e.g. copy file to tftp directory), 
			#add "my name" to ftp group.
			usermod -a -G {userName} {localUserName}
        fi
        yum -y install tftp-server
        
        sed -e 's/server_args.*$/server_args = -sc -u tftp \/var\/lib\/tftpboot/' \
            -e 's/disable.*$/disable    = no/' \
            -i /etc/xinetd.d/tftp

        chown tftp:tftp /var/lib/tftpboot
		chmod g+w /var/lib/tftpboot
        #/var/lib/tftpboot will be shared with multi domain, e.g. samba, tftp
        chcon -R -t public_content_rw_t /var/lib/tftpboot
        setsebool -P tftp_anon_write=1
        chcon -R -t tftpdir_rw_t /var/lib/tftpboot

        service xinetd restart
		#Set up environment variable. We will use the "TftpRoot" variable in makefile.
		export TftpRoot=/var/lib/tftpboot
		echo "export TftpRoot=/var/lib/tftpboot" > /etc/profile.d/tftp.sh
    fi
else
    if (grep "${userName}.*/var/lib/tftpboot" /etc/passwd 1>/dev/null 2>&1);
    then
        groupdel ${userName}
        userdel ${userName}
    fi
	service xinetd stop
    yum -y erase tftp-server
	service xinetd start
    rm -f /etc/xinetd.d/tftp*
    rm -rf /var/lib/tftpboot
fi

exit 0
