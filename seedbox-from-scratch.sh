##################### FIRST LINE
# ---------------------------
#!/bin/bash
# ---------------------------
#
#
# The Seedbox From Scratch  Script
#   By Notos ---> https://github.com/Notos/
#
#
#  git clone -b master https://github.com/Notos/seedbox-from-scratch.git /etc/scripts
#
#
#
# Changelog
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

# 1.
clear
sudo apt-get --yes install whois makepasswd

# 1.1 functions

function getString()
{
  local NEWVAR1=a
  local NEWVAR2=b
  while [ ! $NEWVAR1 = $NEWVAR2 ];
  do
    clear
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
    read -s -p "$1" NEWVAR1
    echo ""
    read -s -p "Retype: " NEWVAR2
    echo ""
  done
  eval $2=\$NEWVAR1
}

# 3.1

sudo apt-get --yes install whois makepasswd

#those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

#localhost is ok this rtorrent/rutorrent installation
IPADDRESS1=127.0.0.1

#create a new variable, compatible with create user script
NEWUSER1=$USER

getPassword "ruTorrent password for user $NEWUSER1: " PASSWORD1
getString "IP address or hostname of your box: " NEWHOSTNAME1
getString "New SSH port: " NEWSSHPORT1 21976

# 3.2

#show all commands
set -x verbose

echo "" | sudo tee -a /etc/sudoers > /dev/null
echo "www-data ALL=(root) NOPASSWD: /usr/sbin/repquota" | sudo tee -a /etc/sudoers > /dev/null
echo "$NEWUSER1 ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

#SUDOLINE="$NEWUSER1 ALL=(ALL:ALL) ALL"
#PERLLINE="$NEWUSER1\ ALL=\(ALL\:ALL\)\ ALL"
#PERLCOND="s/^$PERLLINE$//g"
#sudo perl -pi -e "$PERLCOND" /etc/sudoers
#echo $SUDOLINE | sudo tee -a /etc/sudoers > /dev/null
#keep an empty line at the EOF
echo "" | sudo tee -a /etc/sudoers > /dev/null

# 4.
sudo perl -pi -e "s/Port 22/Port $NEWSSHPORT1/g" /etc/ssh/sshd_config
sudo perl -pi -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo perl -pi -e "s/#Protocol 2/Protocol 2/g" /etc/ssh/sshd_config
sudo perl -pi -e "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config

echo "" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "UseDNS no" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "AllowUsers $NEWUSER1" | sudo tee -a /etc/ssh/sshd_config > /dev/null

sudo service ssh restart

# 6.
#remove cdrom from apt so it doesn't stop asking for it
sudo perl -pi -e "s/deb cdrom/#deb cdrom/g" /etc/apt/sources.list

#add webmin source
echo "" | sudo tee -a /etc/apt/sources.list > /dev/null
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list > /dev/null
cd /tmp
wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc

#add non-free sources to Debian Squeeze
sudo perl -pi -e "s/squeeze main/squeeze main non-free/g" /etc/apt/sources.list
sudo perl -pi -e "s/squeeze\/updates main/squeeze\/updates main non-free/g" /etc/apt/sources.list

# 7.
# update and upgrade packages

sudo apt-get --yes update
sudo apt-get --yes upgrade

# 8.
#install all needed packages including webmin

sudo apt-get --yes build-dep znc
sudo apt-get --yes install apache2 apache2-utils autoconf build-essential ca-certificates comerr-dev curl cfv quota mktorrent dtach htop irssi libapache2-mod-php5 libcloog-ppl-dev libcppunit-dev libcurl3 libcurl4-openssl-dev libncurses5-dev libterm-readline-gnu-perl libsigc++-2.0-dev libperl-dev openvpn libssl-dev libtool libxml2-dev ncurses-base ncurses-term ntp openssl patch pkg-config php5 php5-cli php5-dev php5-curl php5-geoip php5-mcrypt php5-xmlrpc pkg-config python-scgi screen ssl-cert subversion texinfo unrar-free unzip zlib1g-dev expect joe ffmpeg webmin libarchive-zip-perl libnet-ssleay-perl libhtml-parser-perl libxml-libxml-perl libjson-perl libjson-xs-perl libxml-libxslt-perl libxml-libxml-perl libjson-rpc-perl libarchive-zip-perl znc rar zip

# 8.1 additional packages for Ubuntu
# this is better to be apart from the others
sudo apt-get --yes php5-fpm

#Check if its Debian an do a sysvinit by upstart replacement:

if [ -f /etc/debian_version ]
  then
    echo 'Yes, do as I say!' | sudo apt-get -y --force-yes install upstart
fi

# 8.3 Generate our lists of ports and RPC and create variables

#lists are being created in a permanent directory because other scripts will need this
sudo mkdir -p /etc/scripts

#permanently adding scripts to PATH to all users and root
echo "PATH=$PATH:/etc/scripts:/sbin" | sudo tee -a /etc/profile > /dev/null
echo "export PATH" | sudo tee -a /etc/profile > /dev/null
echo "PATH=$PATH:/etc/scripts:/sbin" | sudo tee -a /root/.bashrc > /dev/null
echo "export PATH" | sudo tee -a /root/.bashrc > /dev/null

sudo rm /etc/scripts/ports.txt
for i in $(seq 51101 51999)
do
  echo "$i" | sudo tee -a /etc/scripts/ports.txt > /dev/null
done

sudo rm /etc/scripts/rpc.txt
for i in $(seq 2 1000)
do
  echo "RPC$i"  | sudo tee -a /etc/scripts/rpc.txt > /dev/null
done

NEWRPC1=`head -n 1 /etc/scripts/rpc.txt | tail -n 1`
sudo perl -pi -e "s/^$NEWRPC1.*\n$//g" /etc/scripts/rpc.txt

IRSSIPORT=`head -n 1 /etc/scripts/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$IRSSIPORT.*\n$//g" /etc/scripts/ports.txt

SCGIPORT=`head -n 1 /etc/scripts/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$SCGIPORT.*\n$//g" /etc/scripts/ports.txt

NETWORKPORT=`head -n 1 /etc/scripts/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$NETWORKPORT.*\n$//g" /etc/scripts/ports.txt

IRSSIPASSWORD=`makepasswd`

# 9.
sudo a2enmod ssl
sudo a2enmod auth_digest
sudo a2enmod reqtimeout
#sudo a2enmod scgi ############### if we cant make python-scgi works

# 10.

#remove timeout if  there are any
sudo perl -pi -e "s/^Timeout [0-9]*$//g" /etc/apache2/apache2.conf

echo "" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "#seedbox values" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerSignature Off" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerTokens Prod" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo "Timeout 30" | sudo tee -a /etc/apache2/apache2.conf > /dev/null

sudo service apache2 restart

echo "<?php phpinfo(); ?>" | sudo tee -a /var/www/info.php > /dev/null
sudo rm /var/www/info.php

# 11.

sudo openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -out /etc/apache2/apache.pem -keyout /etc/apache2/apache.pem -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'
sudo chmod 600 /etc/apache2/apache.pem

# 12.

#create digest data file
echo -n $NEWUSER1:rutorrent:$PASSWORD1 > /tmp/pass

#remove current password from htpassword
sudo perl -pi -e "s/^$NEWUSER1\:.*\n$//g" /etc/apache2/htpasswd

#create user and password for this new rutorrent user
echo $NEWUSER1:rutorrent:`md5sum /tmp/pass | cut -d" " -f1` | sudo tee -a /etc/apache2/htpasswd > /dev/null

# 13.
sudo mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.ORI
sudo rm /etc/apache2/sites-available/default

sudo cp /etc/scripts/etc.apache2.default.template /etc/apache2/sites-available/default
sudo perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/default

# 14.
sudo a2ensite default-ssl

#14.1
#sudo ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load
#sudo service apache2 restart
#sudo apt-get --yes install libxmlrpc-core-c3-dev

# 15.
cd /home/$NEWUSER1
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
sudo make install

# 16.1 - c-ares


# 17.
cd ../libtorrent-0.13.2
./autogen.sh
./configure --prefix=/usr
make -j2
sudo make install

cd ../rtorrent-0.9.2
./autogen.sh
./configure --prefix=/usr --with-xmlrpc-c
make -j2
sudo make install
sudo ldconfig

# 19.
sudo cp /etc/scripts/rtorrent.rc.template  /home/$NEWUSER1/.rtorrent.rc > /dev/null

sudo perl -pi -e "s/<username>/$NEWUSER1/g" /home/$NEWUSER1/.rtorrent.rc
sudo perl -pi -e "s/5995/$SCGIPORT/g" /home/$NEWUSER1/.rtorrent.rc
sudo perl -pi -e "s/99888/$NETWORKPORT/g" /home/$NEWUSER1/.rtorrent.rc

sudo chown $NEWUSER1:$NEWUSER1   /home/$NEWUSER1/.rtorrent.rc:$NEWUSER1 /home/$NEWUSER1/.rtorrent.rc

# 20.
sudo mkdir -p /home/$NEWUSER1/downloads/auto
sudo mkdir -p /home/$NEWUSER1/downloads/manual
sudo mkdir -p /home/$NEWUSER1/downloads/watch
sudo mkdir -p /home/$NEWUSER1/downloads/.session
sudo chown -R $NEWUSER1:$NEWUSER1 /home/$NEWUSER1/downloads

# 21.

sudo cp /etc/scripts/rtorrent.conf.template /etc/init/rtorrent.$NEWUSER1.conf
sudo perl -pi -e "s/<username>/$NEWUSER1/g" /etc/init/rtorrent.$NEWUSER1.conf

# 22.
cd /var/www
sudo rm -r rutorrent
sudo svn checkout http://rutorrent.googlecode.com/svn/trunk/rutorrent
sudo svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins
sudo rm -r -f rutorrent/plugins
sudo mv plugins rutorrent/

# prepare the tree
sudo mkdir -p /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi
sudo mkdir -p /var/www/rutorrent/conf/users/$NEWUSER1/plugins/diskspace
sudo mkdir -p /var/www/rutorrent/conf/users/$NEWUSER1/plugins/fileupload

echo '<?php $topDirectory = "/home"; ?>' | sudo tee -a /var/www/rutorrent/conf/users/$NEWUSER1/plugins/diskspace/conf.php > /dev/null

sudo cp /etc/scripts/action.php.template /var/www/rutorrent/plugins/diskspace/action.php

#some of those files will be changed later in this script
sudo cp /var/www/rutorrent/conf/access.ini   /var/www/rutorrent/conf/users/$NEWUSER1/
sudo cp /var/www/rutorrent/conf/config.php  /var/www/rutorrent/conf/users/$NEWUSER1/
sudo cp /var/www/rutorrent/conf/plugins.ini   /var/www/rutorrent/conf/users/$NEWUSER1/

# 24.

sudo cp /etc/scripts/rutorrent.conf.users.config.php.template /var/www/rutorrent/conf/users/$NEWUSER1/config.php

sudo perl -pi -e "s/5995/$SCGIPORT/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php
sudo perl -pi -e "s/RPC123/$NEWRPC1/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php
sudo perl -pi -e "s/<username>/$NEWUSER1/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php
sudo perl -pi -e "s/<homedir>/\/home\/$NEWUSER1/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php

# 25.

sudo cp /etc/scripts/rutorrent.conf.users.plugins.ini.template /var/www/rutorrent/conf/users/$NEWUSER1/plugins.ini

# 26.
cd /tmp
sudo wget http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
sudo tar jxvf MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
cd MediaInfo_CLI_GNU_FromSource/
sudo sh CLI_Compile.sh
cd MediaInfo/Project/GNU/CLI
sudo make install


# 29.

rm -R /home/$NEWUSER1/.irssi
mkdir -p /home/$NEWUSER1/.irssi/scripts/autorun
cd /home/$NEWUSER1/.irssi/scripts
wget --no-check-certificate -O autodl-irssi.zip https://sourceforge.net/projects/autodl-irssi/files/autodl-irssi-v1.31.zip/download
unzip -o autodl-irssi.zip
rm autodl-irssi.zip
cp autodl-irssi.pl autorun/
mkdir -p /home/$NEWUSER1/.autodl
sudo touch /home/$NEWUSER1/.autodl/autodl.cfg

cd /var/www/rutorrent/plugins
sudo svn co https://autodl-irssi.svn.sourceforge.net/svnroot/autodl-irssi/trunk/rutorrent/autodl-irssi
cd autodl-irssi

sudo cp /etc/scripts/rutorrent.conf.users.plugins.autodl-irssi.conf.php.template  /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php
sudo perl -pi -e "s/<PASSWORD>/$IRSSIPASSWORD/g"  /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php
sudo perl -pi -e "s/<PORT>/$IRSSIPORT/g" /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php

#sudo chown -R $NEWUSER1:www-data   /var/www/rutorrent/conf/users/$NEWUSER1
#sudo find /var/www/rutorrent/conf/users/$NEWUSER1 -type d -exec sudo chmod 770 {} \;
#sudo find /var/www/rutorrent/conf/users/$NEWUSER1 -type d -exec sudo chmod 770 {} \;
#chmod 660 {} \;

sudo cp /etc/scripts/home.user.autodl.autodl.cfg.template  /home/$NEWUSER1/.autodl/autodl.cfg

sudo perl -pi -e "s/<PASSWORD>/$IRSSIPASSWORD/g"  /home/$NEWUSER1/.autodl/autodl.cfg
sudo perl -pi -e "s/<PORT>/$IRSSIPORT/g"  /home/$NEWUSER1/.autodl/autodl.cfg
sudo perl -pi -e "s/use Digest\:\:SHA1 qw/use Digest\:\:SHA qw/g" /home/$NEWUSER1/.irssi/scripts/AutodlIrssi/MatchedRelease.pm

sudo chown -R $NEWUSER1:$NEWUSER1  /home/$NEWUSER1/.autodl

# 31.

#clear
#echo "ZNC Configuration"
#echo ""
#znc --makeconf
#/home/antoniocarlos/.znc/configs/znc.conf

# 32.

# Installing poweroff button on ruTorrent

cd /var/www/rutorrent/plugins/
sudo wget http://rutorrent-logoff.googlecode.com/files/logoff-1.0.tar.gz
sudo tar -zxf logoff-1.0.tar.gz
sudo rm logoff-1.0.tar.gz

# Installing Filemanager and MediaStream

sudo rm -R /var/www/rutorrent/plugins/filemanager
sudo rm -R /var/www/rutorrent/plugins/fileupload
sudo rm -R /var/www/rutorrent/plugins/mediastream
sudo rm -R /var/www/stream

cd /var/www/rutorrent/plugins/
sudo svn co http://svn.rutorrent.org/svn/filemanager/trunk/mediastream

cd /var/www/rutorrent/plugins/
sudo svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

sudo cp /etc/scripts/rutorrent.plugins.filemanager.conf.php.template /var/www/rutorrent/plugins/filemanager/conf.php

sudo mkdir -p /var/www/stream/
sudo ln -s /var/www/rutorrent/plugins/mediastream/view.php /var/www/stream/view.php
sudo chown www-data: /var/www/stream
sudo chown www-data: /var/www/stream/view.php

echo "<?php \$streampath = 'http://$NEWHOSTNAME1/stream/view.php'; ?>" | sudo tee /var/www/rutorrent/plugins/mediastream/conf.php > /dev/null

# 32.1 # FILEUPLOAD
cd /var/www/rutorrent/plugins/
sudo svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileupload
sudo chmod 775 /var/www/rutorrent/plugins/fileupload/scripts/upload
sudo cp /etc/scripts/rutorrent.conf.users.plugins.fileupload.conf.php.template  /var/www/rutorrent/conf/users/$NEWUSER1/plugins/fileupload/config.php > /dev/null
sudo chown -R www-data:www-data /var/www/rutorrent/conf/users/$NEWUSER1/plugins/fileupload/
wget -O /tmp/plowshare.deb http://plowshare.googlecode.com/files/plowshare_1~git20120930-1_all.deb
sudo dpkg -i /tmp/plowshare.deb
sudo apt-get --yes -f install

# 32.2
sudo chown -R www-data:www-data /var/www/rutorrent
sudo chmod -R 755 /var/www/rutorrent

#32.3

sudo perl -pi -e "s/\\\$topDirectory\, \\\$fm/\\\$homeDirectory\, \\\$topDirectory\, \\\$fm/g" /var/www/rutorrent/plugins/filemanager/flm.class.php
sudo perl -pi -e "s/\\\$this\-\>userdir \= addslash\(\\\$topDirectory\)\;/\\\$this\-\>userdir \= \\\$homeDirectory \? addslash\(\\\$homeDirectory\) \: addslash\(\\\$topDirectory\)\;/g" /var/www/rutorrent/plugins/filemanager/flm.class.php

# 33.
# createSeedboxUser script creation

# scripts are now in git form :)

sudo chmod +x /etc/scripts/createSeedboxUser
sudo chmod +x /etc/scripts/deleteSeedboxUser
sudo chmod +x /etc/scripts/installOpenVPN
sudo chmod +x /etc/scripts/removeWebmin
sudo chmod +x /etc/scripts/downgradeRTorrent
sudo chmod +x /etc/scripts/upgradeRTorrent
sudo chmod +x /etc/scripts/ovpni

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

sudo reboot

##################### LAST LINE ###########

