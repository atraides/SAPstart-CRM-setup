#!/bin/bash

apt-get update
apt-get -y install nginx drbd8-utils 
apt-get -y install pacemaker corosync
mkdir -p /var/log/cluster

sed -ie s/START=no/START=yes/ /etc/default/corosync
if [ -e /etc/corosync/corosync.conf ]; then 
    mv /etc/corosync/corosync.conf /etc/corosync/corosync.conf.orig; 
fi

tar jxvf cluster_cfg.tbz2 -C /

service drbd start ; service corosync start && service pacemaker start

tar jxvf drbd_cfg.tbz2 -C /

for i in nginx openvpn shorewall; do lvcreate -L 256M -n lv_$i rootvg; done

mkdir -p /etc/nginx ; echo -e "yes\nyes"| /sbin/drbdadm  create-md drbd_cfg_openvpn/0 && echo -e "yes\nyes"| /sbin/drbdadm  create-md drbd_cfg_shorewall/0 && echo -e "yes\nyes"| /sbin/drbdadm  create-md drbd_cfg_nginx/0 && service drbd reload 

update-rc.d -f drbd remove && update-rc.d pacemaker defaults
