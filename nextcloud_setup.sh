#!/bin/bash


#===================================================================
# title           setup-new-computer.sh
# author          arcweld
#                 https://github.com/arcweld
#===================================================================
#   A shell script to help with the quick setup and installation of
#   NextCloud by snap for new laptops
#
#
#===============================================================================

printLogo() {
cat << "EOT"

   __ _ _ __ _____      _____| | __| |
  / _` | '__/ __\ \ /\ / / _ \ |/ _` |
 | (_| | | | (__ \ V  V /  __/ | (_| |
  \__,_|_|  \___| \_/\_/ \___|_|\__,_|
 ------------------------------------------
N E X T C L O U D   S E T U P   S C R I P T

EOT
}

printLogo

echo ''
echo "Install NextCloud. (Response will indicate if already installed)"
sudo snap install nextcloud
echo ''
echo "Configure NextCloud with adminstrator account"
# read -p "  What will be your administrator account username?  " ncadmin
# read -s -p "  What will be your admin password? " ncpasswd
sudo nextcloud.occ user:list | if ! [ xargs ]; then sudo nextcloud.manual-install admin admin ; fi
echo '   Admin account configured (or existed)'
echo ''
echo "Add trusted domain "
sudo nextcloud.occ config:system:set trusted_domains 1 --value=emma.cloud.tabdigital.eu
echo ''
echo 'Trusted domains:'
sudo nextcloud.occ config:system:get trusted_domains
