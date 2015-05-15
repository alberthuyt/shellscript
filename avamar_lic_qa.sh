#!/bin/sh
#
# 5/15/15
# apply QA Avamar lic
#

#
# 1. stop avfirewall if it is running.
# 2. mount qadepot create /qadepot if it does not exist
# 3. sudo cp /qadepot/qts/lts/tools/gsankeygen.sles ~
# 4. ssh-agent bash
# 5. ssh-add ~/.ssh/dpnid
# 6. ssh-add ~/.ssh/admin_key
# 7. /usr/local/avamar/bin/gathergsankeydata --account_id="Avamar QA Team" --asset_reference_id=26 --internet_domain=irvineqa.local --nointeractive
# 8. /home/admin/gsankeygen.sles --datafile=gsankeydata.xml --expires=0 --protectedmax=0 --accountid="Avamar QA Team" --assetname=ave2 --assetid=26 > license.xml
# 9. mv /home/admin/license /usr/local/avamar/etc/
# 10. avmaint license --ava /usr/local/avamar/etc/license.xml


if [[ "$#" -ne 2 ]]; then
  echo "Usage : $0 <domain-name> <hostname>"
  echo "Prerequisite : ssh-agent bash && ssh-agent ~/.ssh/dpnid ssh-add ~/.ssh/admin_key"
  exit 1
fi


QADEPOT_LINK="qadepot.asl.lab.emc.com:/qadepot"

# check avfirewall status
avfirewall_status=$(sudo service avfirewall status)
if [[ $avfirewall_status =~ running ]]; then
  echo "avfirewall is running... now stop it to do mount qadepot"
  avfirewall_stop=$(sudo service avfirewall stop)
fi

# mount qadepot
if [[ ! -d "/qadepot" ]]; then
  create_qadepot_dir=$(sudo mkdir /qadepot)
fi

check_qadepot_mount=$(mountpoint /qadepot)
if [[ ! $check_qadepot_mount ]]; then
  mount_qadepot=$(sudo mount $QADEPOT_LINK /qadepot)
fi


copy_gsankeygen=$(sudo cp /qadepot/qts/lts/tools/gsankeygen.sles ~)
chmod_gsankeygen=$(sudo chmod 755 /home/admin/gsankeygen.sles)

#ssh-agent bash
#ssh-add ~/.ssh/dpnid
#echo "P3t3rPan" | ssh-add ~/.ssh/admin_key 

# genrate gsankeydata.xml file
echo
echo "generate gsankeydata.xml file ..."
gen_gsankeydata=$(/usr/local/avamar/bin/gathergsankeydata --account_id="Avamar QA team" --asset_reference_id=26 --internet_domain=$1 --nointeractive)

# generate license.xml file
echo
echo "genrate license ..."
gen_license=$(/home/admin/gsankeygen.sles --datafile=gsankeydata.xml --expires=0 --protectedmax=0 --accountid="Avamar QA Team" --assetname=$2 --assetid=26 > license.xml)

# mv license.xml
move_lic=$(mv /home/admin/license.xml /usr/local/avamar/etc)

# apply license
apply_lic=$(avmaint license --ava /usr/local/avamar/etc/license.xml)


echo "Start avfirewall service again..."
avfirewall_start=$(sudo service avfirewall start)
