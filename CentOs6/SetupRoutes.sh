#!/bin/bash

whoAmI=$(whoami)
if [[ "root" != ${whoAmI} ]];
then
    su
fi

#profile=/etc/rc.local
profile=/etc/sysconfig/static-routes
touch ${profile}
for i in $(seq 5 20);
do
    if ! (grep "net 192.$i.0.0" ${profile} 1>/dev/null 2>&1);
    then
        #echo "route add -net 192.$i.0.0 netmask 255.255.0.0 gw 20.0.0.$i" >> ${profile}
        echo "any net 192.$i.0.0 netmask 255.255.0.0 gw 20.0.0.$i" >> ${profile}
    fi
done
