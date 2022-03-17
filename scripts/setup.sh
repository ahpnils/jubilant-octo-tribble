#!/bin/bash -x

apt -qq update &&
apt -qq -y install fdisk xfsprogs &&
#apt -qy upgrade &&
echo "[INFO] system updated"

while [[ ! -b /dev/sdb ]]; do
	sleep 5
done

if [ -b /dev/sdb1 ]; then
	echo "[INFO] Data disk already formatted"
else
	echo "[INFO] Data disk unallocated"
	echo "label: dos
unit: sectors
sector-size: 512

/dev/sdx1 : start=        2048, size=    62912512, type=83
	" > /tmp/datadisk.dat
	sfdisk /dev/sdb < /tmp/datadisk.dat
	sleep 5
	mkfs.xfs -q /dev/sdb1
	echo "[INFO] Data disk formatted"
	partid="$(blkid /dev/sdb1 | awk -F '"' '{print $2}')"
	echo "UUID=${partid} /srv xfs defaults 1 1" >> /etc/fstab
	mount /srv
	echo "[INFO] Data disk mounted"
fi

echo "[INFO] setup script executed"
# More scripts here.

