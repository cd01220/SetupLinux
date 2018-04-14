#!/bin/bash

userName=liuhao
setupType=install

whoAmI=$(whoami)
if [[ "root" != ${whoAmI} ]];
then
    su
fi

while getopts "l:f:t:s:u" opt
do
    case $opt in
    n ) userName=$OPTARG
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

###########Set up sudo authority for user "${userName}".###########
if ! (grep "^${userName}.*ALL=(ALL).*ALL$" /etc/sudoers 1>/dev/null 2>&1);
then
    chmod 777 /etc/sudoers
    sed -e '/^root.*ALL=(ALL).*ALL/ a ${userName}  ALL=(ALL)   ALL' \
		-e 's/^Defaults.*env_reset/Defaults    !env_reset/' \
        -i /etc/sudoers
    chmod 440 /etc/sudoers
fi

###########Set up yum repository.###########
if [ ! -e /media/CentOS_6.3 ];
then
    echo "Error, please copy CentOS CD to /media/CentOS_6.3"
    exit 1
fi
if [ ! -e /etc/yum.repos.d/CentOS-Media.repo.bak ];
then
    for dir in $(find /etc/yum.repos.d -name "*.repo");
    do
        mv ${dir} ${dir}.bak
    done
    cp -f /etc/yum.repos.d/CentOS-Media.repo.bak /etc/yum.repos.d/CentOS-Media.repo
    sed -e 's#^baseurl=.*$#baseurl=file:///media/CentOS_6.3/#' \
        -e '/ *file:\/\/\/media\/cdrom\//d' \
        -e 's/^enabled=0$/enabled=1/' \
        -i /etc/yum.repos.d/CentOS-Media.repo
fi

exit 0