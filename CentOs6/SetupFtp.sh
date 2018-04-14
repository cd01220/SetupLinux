#!/bin/bash

userName=ftp
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

###########Set up ftp server.###########
if [ ${setupType} = "install" ];
then
    if ! (service vsftpd status 1>/dev/null 2>&1);
    then
        yum -y install vsftpd
        #create ftp user
        if ! (grep "^${userName}:" /etc/passwd 1>/dev/null 2>&1);
        then
            useradd -s /sbin/nologin -r -M -d /var/ftp ${userName}
			#in order to make daily work convenient(e.g. copy file to tftp directory), 
			#add "my name" to ftp group.
			usermod -a -G {userName} {localUserName}
        fi
        
        #To support local user, we have to clean ftpusers and user_list(uncomments the following 3 lines).
        #sed -e '/root/,$d' -i /etc/vsftpd/ftpusers 
        #sed -e '/root/,$d' -i /etc/vsftpd/user_list 
		#setsebool -P ftp_home_dir 1
        
        #edit /etc/vsftpd/vsftpd.conf
        sed -e 's/^anonymous_enable=.*$/anonymous_enable=YES/' \
            -e 's/^#anon_upload_enable=.*$/anon_upload_enable=YES/' \
			-e '/local_umask/a anon_umask=022' \
			-e 's/^#anon_mkdir_write_enable=.*$/anon_mkdir_write_enable=YES/' \
			-e '/anon_mkdir_write_enable/a anon_other_write_enable=YES' \
            -e '$a ftp_username=ftp' \
            -i /etc/vsftpd/vsftpd.conf
        		
        chcon -R -t public_content_rw_t /var/ftp
        setsebool -P allow_ftpd_anon_write=1
        chown ${userName}:${userName} /var/ftp/pub
        
        chkconfig vsftpd on
        service vsftpd start
    fi
else
    if (grep "${userName}.*/var/ftp" /etc/passwd 1>/dev/null 2>&1);
    then
        groupdel ${userName}
        userdel ${userName}
    fi
	service vsftpd stop
    yum -y erase vsftpd
    rm -rf /etc/vsftpd
    rm -rf /var/ftp
fi

exit 0
