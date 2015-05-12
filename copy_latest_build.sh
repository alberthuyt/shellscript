#!/bin/sh
#
# Copy latest build
#
#

QADEPOT_LINK="qadepot.asl.lab.emc.com:/qadepot"

# Check status avfirewall
avfirewall_status=$(sudo service avfirewall status)

if [[ $avfirewall_status =~ running ]]; then
  echo "avfirwall is running, now stop it to do mount"
  avstop=$(sudo service avfirewall stop)
fi

mountqadepot=$(sudo mount $QADEPOT_LINK /qadepot)
avstart=$(sudo service avfirewall start)

listbuild=$(ls -rt /qadepot/builds/ | grep -E "7.2.0")


for i in $listbuild; do
  folderlatestbuild=$i
done

echo "folder latest build: " $folderlatestbuild

build=$(echo $folderlatestbuild | sed -e "s/v7.2.0./7.2.0-/g")

echo $build

AVUPGRADEPKG="/qadepot/builds/$folderlatestbuild/PACKAGES/AvamarUpgrade-$build.avp"

echo "copy upgrade package $AVUPGRADEPKG ..."

copystatus=$(cp $AVUPGRADEPKG /data01/avamar/repo/packages/)
