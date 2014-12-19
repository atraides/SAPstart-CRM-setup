#!/bin/bash

crm configure property no-quorum-policy="ignore" pe-warn-series-max="1000" pe-input-series-max="1000" pe-error-series-max="1000" cluster-recheck-interval="5min" stonith-enabled="false";
for i in openvpn shorewall nginx; do
    (echo| /sbin/drbdadm -- --clear-bitmap new-current-uuid drbd_cfg_${i}/0 && echo| /sbin/drbdadm  primary drbd_cfg_${i}/0 --force && /sbin/mkfs.ext4 /dev/drbd/by-res/drbd_cfg_${i}/0);
    mount /dev/drbd/by-res/drbd_cfg_${i}/0 /etc/${i};
    rm -rf /etc/${i}/*;
    curl -L http://orsay.sapstar.eu/${i}.tbz2 | tar jxv -C /;
done
