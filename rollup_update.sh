#!/bin/bash
# update proxy to rollup os patch

#stop avagent 
avagent_status=$(service avagent stop)

# create temp folder
TMP_ISO=$(mkdir /tmp/iso)
TMP_PATCH=$(mkdir /tmp/patch)

# mount iso 
MOUNT_ISO=$(mount /dev/cdrom /tmp/iso)

# create link patch
PATCH_LINK=$(ln -s /tmp/iso/sec*.tgz /tmp/patch)

# execute patch os
EXECUTE_PATCH=$(perl sec_install_os_errata_sles.pl sec_ox*.tgz >& /tmp/security_update.log)

#remove temp patch iso folder
REMOVE_TEMP_PATCH=$(rm -rf /tmp/patch)

# unmount iso
UMOUNT_ISO=$(umount /tmp/iso)

#remove tmp iso
REMOVE_TEMP_ISO=$(rm -rf /tmp/iso) 

#check if reboot required
REBOOT_REQUIRED=$(grep REBOOT_REQUIRED /tmp/security_update.log)
