##################### FIRST LINE
# ---------------------------
#!/bin/bash
# ---------------------------
#
#
# The Seedbox From Scratch Script
#   By Notos ---> https://github.com/Notos/
#
#
#  git clone -b master https://github.com/Notos/seedbox-from-scratch.git /etc/scripts
#  sudo git stash; sudo git pull
#
#
# Changelog
#
#  Version 1.30 (BETA)
#  23/10/2012 04:54:29
#     - Scripts now accept a full install without having to create variables and do anything else
#
#  Version 1.20 (BETA)
#  19 Oct 2012 03:24 (by Notos)
#    - Install OpenVPN - (BETA) Still not in the script, just an outside script
#      Tested client: http://openvpn.net/index.php?option=com_content&id=357
#
#  Version 1.11
#  18/10/2012 05:13 (by Notos)
#    - Added scripts to downgrade and upgrade rTorrent
#
#    - Added all supported plowshare sites into fileupload plugin: 115, 1fichier, 2shared, 4shared, bayfiles, bitshare, config, cramit, data_hu, dataport_cz,
#      depositfiles, divshare, dl_free_fr, euroshare_eu, extabit, filebox, filemates, filepost, freakshare, go4up, hotfile, mediafire, megashares, mirrorcreator, multiupload, netload_in,
#      oron, putlocker, rapidgator, rapidshare, ryushare, sendspace, shareonline_biz, turbobit, uploaded_net, uploadhero, uploading, uptobox, zalaa, zippyshare
#
#  Version 1.10
#  06/10/2012 14:18 (by Notos)
#    - Added Fileupload plugin
#
#    - Added all supported plowshare sites into fileupload plugin: 115, 1fichier, 2shared, 4shared, bayfiles, bitshare, config, cramit, data_hu, dataport_cz,
#      depositfiles, divshare, dl_free_fr, euroshare_eu, extabit, filebox, filemates, filepost, freakshare, go4up, hotfile, mediafire, megashares, mirrorcreator, multiupload, netload_in,
#      oron, putlocker, rapidgator, rapidshare, ryushare, sendspace, shareonline_biz, turbobit, uploaded_net, uploadhero, uploading, uptobox, zalaa, zippyshare
#
#  Version 1.00
#  30/09/2012 14:18 (by Notos)
#    - Changing some file names and depoying version 1.00
#
#  Version 0.99b
#  27/09/2012 19:39 (by Notos)
#    - Quota for users
#    - Download dir inside user home
#
#  Version 0.99a
#  27/09/2012 19:39 (by Notos)
#    - Quota for users
#    - Download dir inside user home
#
#  Version 0.92a
#  28/08/2012 19:39 (by Notos)
#    - Also working on Debian now
#
#  Version 0.91a
#  24/08/2012 19:39 (by Notos)
#    - First multi-user version sent to public
#
#  Version 0.90a
#  22/08/2012 19:39 (by Notos)
#    - Working version for OVH Kimsufi 2G Server - Ubuntu Based
#
#  Version 0.89a
#  17/08/2012 19:39 (by Notos)
#
# to get IP address = ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | head -1 | awk '{print $2}'`
#

# 0.

apt-get --yes install whois sudo makepasswd git

rm -f -r /etc/scripts
mkdir -p /etc/scripts
git clone -b fullCreate https://github.com/Notos/seedbox-from-scratch.git /etc/scripts
#git clone -b master https://github.com/Notos/seedbox-from-scratch.git /etc/scripts

if [ ! -f /etc/scripts/seedbox-from-scratch.sh ]
then
  clear
  echo Looks like somethig is wrong, this script was not able to download its whole git repository.
  set -e
  exit 1
fi

# 1.
clear

# 1.1 functions

function getString()
{
  local NEWVAR1=a
  local NEWVAR2=b
  while [ ! $NEWVAR1 = $NEWVAR2 ];
  do
    clear
    echo "#"
    echo "#"
    echo "# The Seedbox From Scratch Script"
    echo "#   By Notos ---> https://github.com/Notos/"
    echo "#"
    echo "#"
    echo "#"
    echo
    read -e -i "$3" -p "$1" NEWVAR1
    if [ "$NEWVAR1" == "$3" ]
    then
      NEWVAR2=$NEWVAR1
    else
      read -p "Retype: " NEWVAR2
    fi
  done
  eval $2=\$NEWVAR1
}
function getPassword()
{
  local NEWVAR1=a
  local NEWVAR2=b
  while [ ! $NEWVAR1 = $NEWVAR2 ];
  do
    clear
    echo "#"
    echo "#"
    echo "# The Seedbox From Scratch Script"
    echo "#   By Notos ---> https://github.com/Notos/"
    echo "#"
    echo "#"
    echo "#"
    echo
    read -s -p "$1" NEWVAR1
    echo ""
    read -s -p "Retype: " NEWVAR2
    echo ""
  done
  eval $2=\$NEWVAR1
}

# 3.1

#localhost is ok this rtorrent/rutorrent installation
IPADDRESS1=`grep address /etc/network/interfaces | grep -v 127.0.0.1  | awk '{print $2}'`

#those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

getString "You need to create an user for your seedbox: " NEWUSER1
getPassword "ruTorrent password for user $NEWUSER1: " PASSWORD1
getString "IP address or hostname of your box: " NEWHOSTNAME1 $IPADDRESS1
getString "New SSH port: " NEWSSHPORT1 21976

# 3.2

#show all commands
set -x verbose

# 4.
perl -pi -e "s/Port 22/Port $NEWSSHPORT1/g" /etc/ssh/sshd_config
perl -pi -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
perl -pi -e "s/#Protocol 2/Protocol 2/g" /etc/ssh/sshd_config
perl -pi -e "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config

echo "" | tee -a /etc/ssh/sshd_config > /dev/null
echo "UseDNS no" | tee -a /etc/ssh/sshd_config > /dev/null

service ssh restart

# 6.
#remove cdrom from apt so it doesn't stop asking for it
perl -pi -e "s/deb cdrom/#deb cdrom/g" /etc/apt/sources.list

#if webmin isup, download key
ping -c1 -w2 www.webmin.com > /dev/null
WEBMINDOWN=yes
if [ $? = 0 ] ; then
  #add webmin source
  echo "" | tee -a /etc/apt/sources.list > /dev/null
  echo "deb http://download.webmin.com/download/repository sarge contrib" | tee -a /etc/apt/sources.list > /dev/null
  cd /tmp
  wget http://www.webmin.com/jcameron-key.asc
  apt-key add jcameron-key.asc
  WEBMINDOWN=no
fi
sleep 5000

#add non-free sources to Debian Squeeze
perl -pi -e "s/squeeze main/squeeze main non-free/g" /etc/apt/sources.list
perl -pi -e "s/squeeze\/updates main/squeeze\/updates main non-free/g" /etc/apt/sources.list

# 7.
# update and upgrade packages

sudo apt-get --yes update
apt-get --yes upgrade

# 8.
#install all needed packages including webmin

apt-get --yes build-dep znc
apt-get --yes install apache2 apache2-utils autoconf build-essential ca-certificates comerr-dev curl cfv quota mktorrent dtach htop irssi libapache2-mod-php5 libcloog-ppl-dev libcppunit-dev libcurl3 libcurl4-openssl-dev libncurses5-dev libterm-readline-gnu-perl libsigc++-2.0-dev libperl-dev openvpn libssl-dev libtool libxml2-dev ncurses-base ncurses-term ntp openssl patch pkg-config php5 php5-cli php5-dev php5-curl php5-geoip php5-mcrypt php5-xmlrpc pkg-config python-scgi screen ssl-cert subversion texinfo unrar-free unzip zlib1g-dev expect joe ffmpeg libarchive-zip-perl libnet-ssleay-perl libhtml-parser-perl libxml-libxml-perl libjson-perl libjson-xs-perl libxml-libxslt-perl libxml-libxml-perl libjson-rpc-perl libarchive-zip-perl znc rar zip
if [ $? -gt 0 ]; then
  set +x verbose
  echo
  echo
  echo *** ERROR ***
  echo
  echo "Looks like somethig is wrong with apt-get install, aborting."
  echo
  echo
  echo
  set -e
  exit 1
fi

if [ "$WEBMINDOWN" = "no" ]; then
  apt-get --yes install webmin
fi

# 8.1 additional packages for Ubuntu
# this is better to be apart from the others
apt-get --yes install php5-fpm

#Check if its Debian an do a sysvinit by upstart replacement:

if [ -f /etc/debian_version ]
  then
    echo 'Yes, do as I say!' | apt-get -y --force-yes install upstart
fi

# 8.3 Generate our lists of ports and RPC and create variables

#permanently adding scripts to PATH to all users and root
echo "PATH=$PATH:/etc/scripts:/sbin" | tee -a /etc/profile > /dev/null
echo "export PATH" | tee -a /etc/profile > /dev/null
echo "PATH=$PATH:/etc/scripts:/sbin" | tee -a /root/.bashrc > /dev/null
echo "export PATH" | tee -a /root/.bashrc > /dev/null

rm -f /etc/scripts/ports.txt
for i in $(seq 51101 51999)
do
  echo "$i" | tee -a /etc/scripts/ports.txt > /dev/null
done

rm -f /etc/scripts/rpc.txt
for i in $(seq 2 1000)
do
  echo "RPC$i"  | tee -a /etc/scripts/rpc.txt > /dev/null
done

# 9.
a2enmod ssl
a2enmod auth_digest
a2enmod reqtimeout
#a2enmod scgi ############### if we cant make python-scgi works

# 10.

#remove timeout if  there are any
perl -pi -e "s/^Timeout [0-9]*$//g" /etc/apache2/apache2.conf

echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "#seedbox values" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerSignature Off" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerTokens Prod" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "Timeout 30" | tee -a /etc/apache2/apache2.conf > /dev/null

service apache2 restart

echo "<?php phpinfo(); ?>" | tee -a /var/www/info.php > /dev/null
rm -f /var/www/info.php

# 11.

openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -out /etc/apache2/apache.pem -keyout /etc/apache2/apache.pem -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'
chmod 600 /etc/apache2/apache.pem

# 13.
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.ORI
rm -f /etc/apache2/sites-available/default

cp /etc/scripts/etc.apache2.default.template /etc/apache2/sites-available/default
perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/default

# 14.
a2ensite default-ssl

#14.1
#ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load
#service apache2 restart
#apt-get --yes install libxmlrpc-core-c3-dev

# 15.
cd /etc/scripts
mkdir source
cd source
svn co https://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/stable xmlrpc

curl http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz | tar xz
curl http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz | tar xz

#curl http://libtorrent.rakshasa.no/downloads/rtorrent-0.8.9.tar.gz | tar xz
#curl http://libtorrent.rakshasa.no/downloads/libtorrent-0.12.9.tar.gz | tar xz

# 16.
cd xmlrpc
./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server
make
make install

# 16.1 - c-ares


# 17.
cd ../libtorrent-0.13.2
./autogen.sh
./configure --prefix=/usr
make -j2
make install

cd ../rtorrent-0.9.2
./autogen.sh
./configure --prefix=/usr --with-xmlrpc-c
make -j2
make install
ldconfig


# 22.
cd /var/www
rm -f -r rutorrent
svn checkout http://rutorrent.googlecode.com/svn/trunk/rutorrent
svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins
rm -r -f rutorrent/plugins
mv plugins rutorrent/

cp /etc/scripts/action.php.template /var/www/rutorrent/plugins/diskspace/action.php

# 26.
cd /tmp
wget http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
tar jxvf MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
cd MediaInfo_CLI_GNU_FromSource/
sh CLI_Compile.sh
cd MediaInfo/Project/GNU/CLI
make install


cd /var/www/rutorrent/plugins
svn co https://autodl-irssi.svn.sourceforge.net/svnroot/autodl-irssi/trunk/rutorrent/autodl-irssi
cd autodl-irssi

# 31.

#clear
#echo "ZNC Configuration"
#echo ""
#znc --makeconf
#/home/antoniocarlos/.znc/configs/znc.conf

# 32.

# Installing poweroff button on ruTorrent

cd /var/www/rutorrent/plugins/
wget http://rutorrent-logoff.googlecode.com/files/logoff-1.0.tar.gz
tar -zxf logoff-1.0.tar.gz
rm -f logoff-1.0.tar.gz

# Installing Filemanager and MediaStream

rm -f -R /var/www/rutorrent/plugins/filemanager
rm -f -R /var/www/rutorrent/plugins/fileupload
rm -f -R /var/www/rutorrent/plugins/mediastream
rm -f -R /var/www/stream

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/mediastream

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

cp /etc/scripts/rutorrent.plugins.filemanager.conf.php.template /var/www/rutorrent/plugins/filemanager/conf.php

mkdir -p /var/www/stream/
ln -s /var/www/rutorrent/plugins/mediastream/view.php /var/www/stream/view.php
chown www-data: /var/www/stream
chown www-data: /var/www/stream/view.php

echo "<?php \$streampath = 'http://$NEWHOSTNAME1/stream/view.php'; ?>" | tee /var/www/rutorrent/plugins/mediastream/conf.php > /dev/null

# 32.1 # FILEUPLOAD
cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileupload
chmod 775 /var/www/rutorrent/plugins/fileupload/scripts/upload
wget -O /tmp/plowshare.deb http://plowshare.googlecode.com/files/plowshare_1~git20120930-1_all.deb
dpkg -i /tmp/plowshare.deb
apt-get --yes -f install

# 32.2
chown -R www-data:www-data /var/www/rutorrent
chmod -R 755 /var/www/rutorrent

#32.3

perl -pi -e "s/\\\$topDirectory\, \\\$fm/\\\$homeDirectory\, \\\$topDirectory\, \\\$fm/g" /var/www/rutorrent/plugins/filemanager/flm.class.php
perl -pi -e "s/\\\$this\-\>userdir \= addslash\(\\\$topDirectory\)\;/\\\$this\-\>userdir \= \\\$homeDirectory \? addslash\(\\\$homeDirectory\) \: addslash\(\\\$topDirectory\)\;/g" /var/www/rutorrent/plugins/filemanager/flm.class.php

# 33.
# createSeedboxUser script creation

# scripts are now in git form :)

chmod +x /etc/scripts/createSeedboxUser
chmod +x /etc/scripts/deleteSeedboxUser
chmod +x /etc/scripts/installOpenVPN
chmod +x /etc/scripts/removeWebmin
chmod +x /etc/scripts/downgradeRTorrent
chmod +x /etc/scripts/upgradeRTorrent
chmod +x /etc/scripts/ovpni

# 97.

/etc/scripts/createSeedboxUser $NEWUSER1 $PASSWORD1

# 98.

clear

echo ""
echo "<<< The Seedbox From Scratch Script >>>"
echo ""
echo ""
echo ""
echo "Looks like everything is set."
echo ""
echo "Remember that your SSH port is now ======> $NEWSSHPORT1"
echo ""
echo "System will reboot now, but don't close this window until you take note of the port number: $NEWSSHPORT1"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

# 99.

reboot

##################### LAST LINE ###########

