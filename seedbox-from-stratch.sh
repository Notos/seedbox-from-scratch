##################### FIRST LINE
# ---------------------------
#!/bin/bash
# ---------------------------

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

echo "" | sudo tee -a /etc/sudoers
echo "$NEWUSER1  ALL=(ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

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

# 7.
# update and upgrade packages

sudo apt-get --yes update
sudo apt-get --yes upgrade

# 8.
#install all needed packages including webmin

sudo apt-get --yes build-dep znc

sudo apt-get --yes install apache2 apache2-utils autoconf build-essential ca-certificates comerr-dev curl cfv dtach htop irssi libapache2-mod-php5 libcloog-ppl-dev libcppunit-dev libcurl3 libcurl4-openssl-dev libncurses5-dev libterm-readline-gnu-perl libsigc++-2.0-dev libperl-dev libssl-dev libtool libxml2-dev ncurses-base ncurses-term ntp openssl patch pkg-config php5 php5-cli php5-dev  php5-curl php5-geoip php5-mcrypt php5-xmlrpc pkg-config python-scgi screen ssl-cert subversion texinfo unrar-free unzip zlib1g-dev expect joe ffmpeg webmin libarchive-zip-perl libnet-ssleay-perl libhtml-parser-perl libxml-libxml-perl libjson-perl libjson-xs-perl libxml-libxslt-perl libxml-libxml-perl libjson-rpc-perl libarchive-zip-perl znc rar zip

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
sudo mkdir -p /etc/torrent-invites

#permanently adding torrent-invites to PATH to all users and root
echo "PATH=$PATH:/etc/torrent-invites" | sudo tee -a /etc/profile > /dev/null
echo "export PATH" | sudo tee -a /etc/profile > /dev/null
echo "PATH=$PATH:/etc/torrent-invites" | sudo tee -a /root/.bashrc > /dev/null
echo "export PATH" | sudo tee -a /root/.bashrc > /dev/null

sudo rm /etc/torrent-invites/ports.txt
for i in $(seq 51101 51999)
do
  echo "$i" | sudo tee -a /etc/torrent-invites/ports.txt > /dev/null
done

sudo rm /etc/torrent-invites/rpc.txt
for i in $(seq 2 1000)
do
  echo "RPC$i"  | sudo tee -a /etc/torrent-invites/rpc.txt > /dev/null
done

NEWRPC1=`head -n 1 /etc/torrent-invites/rpc.txt | tail -n 1`
sudo perl -pi -e "s/^$NEWRPC1.*\n$//g" /etc/torrent-invites/rpc.txt

IRSSIPORT=`head -n 1 /etc/torrent-invites/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$IRSSIPORT.*\n$//g" /etc/torrent-invites/ports.txt

SCGIPORT=`head -n 1 /etc/torrent-invites/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$SCGIPORT.*\n$//g" /etc/torrent-invites/ports.txt

NETWORKPORT=`head -n 1 /etc/torrent-invites/ports.txt | tail -n 1`
sudo perl -pi -e "s/^$NETWORKPORT.*\n$//g" /etc/torrent-invites/ports.txt

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

BIGLINE=$'<VirtualHost *:80>\n ServerAdmin webmaster@localhost \n DocumentRoot /var/www/ \n \n <Directory /> \n Options FollowSymLinks \n AllowOverride All \n </Directory> \n \n <Directory /var/www/> \n Options -Indexes FollowSymLinks MultiViews \n AllowOverride None \n Order allow,deny \n allow from all \n </Directory> \n \n ErrorLog /var/log/apache2/error.log\n \n # Possible values include: debug, info, notice, warn, error, crit, \n # alert, emerg. \n \n LogLevel warn \n \n CustomLog /var/log/apache2/access.log combined \n \n <Location /rutorrent> \n AuthType Digest\n AuthName "rutorrent"\n AuthDigestDomain /var/www/rutorrent/ http://<server IP>/rutorrent \n AuthDigestProvider file \n AuthUserFile /etc/apache2/htpasswd \n Require valid-user \n SetEnv R_ENV "/var/www/rutorrent" \n </Location> \n</VirtualHost> \n \n \n<VirtualHost *:443> \n ServerAdmin webmaster@localhost\nNameVirtualHost *:443\n SSLEngine on \n SSLCertificateFile /etc/apache2/apache.pem \n DocumentRoot /var/www/ \n \n <Directory /> \n Options FollowSymLinks \n AllowOverride All \n </Directory> \n \n <Directory /var/www/> \n Options -Indexes FollowSymLinks MultiViews \n AllowOverride None \n Order allow,deny \n allow from all \n </Directory> \n \n ErrorLog /var/log/apache2/error.log \n \n # Possible values include: debug, info, notice, warn, error, crit, \n # alert, emerg. \n \n LogLevel warn \n CustomLog /var/log/apache2/access.log combined \n \n <Location /rutorrent> \n AuthType Digest \n AuthName "rutorrent" \n AuthDigestDomain /var/www/rutorrent/ http://<server IP>/rutorrent \n AuthDigestProvider file \n AuthUserFile /etc/apache2/htpasswd \n Require valid-user \n SetEnv R_ENV "/var/www/rutorrent" \n </Location> \n</VirtualHost>\n'

echo "$BIGLINE" | sudo tee  /etc/apache2/sites-available/default > /dev/null

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
curl http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz | tar xz
curl http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz | tar xz

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
sudo rm /home/$NEWUSER1/.rtorrent.rc

BIGLINE=$'# this is an example resource file for rtorrent\n# copy to /home/$NEWUSER1/.rtorrent.rc and enable/modify the options as needed\n# remember to uncomment the options you wish to enable\n#\n# based on original .rtorrent.rc file from The libTorrent and rTorrent Project\n# this assumes the following directory structure:\n#\n# /torrents/downloading - temporary location for torrents while downloading (see "directory")\n# /torrents/complete - torrents are moved here when complete (see "on_finished")\n# /torrents/torrentfiles/auto - the "autoload" directory for rtorrent to use\n# rtorrent will automatically load .torrents placed here. (see "schedule = watch_directory")\n# /torrents/downloading/rtorrent.session - for storing rtorrent session information\n#\n\n \n# Downloads Settings \n# \n# maximum number of simultaneous uploads per torrent \n# throttle.max_uploads.set = 30\nmax_uploads = 30 \n \n# maximum and minimum number of peers to connect to per torrent \n# throttle.min_peers.normal.set = 40 \n# throttle.max_peers.normal.set = 100 \nmin_peers = 40 \nmax_peers = 100 \n \n# same as above but for seeding completed torrents (-1 = same as downloading) \n# throttle.min_peers.seed.set = 25\n# throttle.max_peers.seed.set = 60 \nmin_peers_seed = 25 \nmax_peers_seed = 60 \n \n# tracker_numwant = -1\ntrackers.numwant.set = -1\n \n# check hash for finished torrents. might be useful until the bug is \n# fixed that causes lack of diskspace not to be properly reported \n# pieces.hash.on_completion.set = yes \ncheck_hash = yes \n \n# default directory to save the downloaded torrents \n# directory.default.set = /home/downloads/<username> \ndirectory = /home/downloads/<username> \n \n# default session directory. make sure you don"t run multiple instances \n# of rtorrent using the same session directory \n# perhaps using a relative path? \n# session.path.set = /home/downloads/<username>/.session \nsession = /home/downloads/<username>/.session \n \n \n# Connection Settings \n# \n# port range to use for listening \n# network.port_range.set = 99888-99888 \nport_range = 99888-99888 \n \n# start opening ports at a random position within the port range \n# network.port_random.set = yes \nport_random = yes\n\n# global upload and download rate in KiB. "0" for unlimited\n# throttle.global_up.max_rate.set_kb = 0 \n# throttle.global_down.max_rate.set_kb = 0 \nupload_rate = 0 \ndownload_rate = 0 \n \n# max mapped memory \n# nb does not refer to physical memory \n# max_memory_usage = 3500M \npieces.memory.max.set = 3500M \n \n# max number of files to keep open simultaneously \n# max_open_files = 192 \nnetwork.max_open_files.set = 192 \n \n# max_open_http = 32 \nnetwork.http.max_open.set = 32\n \n \n# BitTorrent Settings \n# \n# enable DHT support for trackerless torrents or when all trackers are down \n# may be set to "disable" (completely disable DHT), "off" (do not start DHT), \n# "auto" (start and stop DHT as needed), or "on" (start DHT immediately) \n# the default is "off". for DHT to work, a session directory must be defined \n# \n# dht.mode.set = disable\ndht = disable \n \n# UDP port to use for DHT. \n# \n# dht_port = 6881 \n# dht.port.set = 6881 \n \n# enable peer exchange (for torrents not marked private) \n# protocol.pex.set = no \npeer_exchange = no \n \n# the IP address reported to the tracker \n# network.local_address.set = rakshasa.no \n# network.local_address.set = 127.0.0.1 \n# ip = rakshasa.no \n# ip = 127.0.0.1 \n \n# schedule syntax: id,start,interval,command \n# call cmd every interval seconds, starting from start. an interval of zero calls the task once \n# while a start of zero calls it immediately. start and interval may optionally use a time format \n# dd:hh:mm:ss e.g. to start a task every day at 18:00, use 18:00:00,24:00:00. \n# commands: stop_untied =, close_untied =, remove_untied = \n# stop, close or remove the torrents that are tied to filenames that have been deleted \n \n# watch a directory for new torrents, and stop those that have been deleted \nschedule = watch_directory,5,5,load_start=/home/downloads/<username>/watch/*.torrent \nschedule = untied_directory,5,5,stop_untied= \n \n# close torrents when diskspace is low. */ \nschedule = low_diskspace,5,60,close_low_diskspace=100M \n \n# stop torrents when reaching upload ratio in percent,\n# when also reaching total upload in bytes, or when\n# reaching final upload ratio in percent\n# example: stop at ratio 2.0 with at least 200 MB uploaded, or else ratio 20.0 \n# schedule = ratio,60,60,stop_on_ratio=200,200M,2000 \n \n# load = file, load_verbose = file, load_start = file, load_start_verbose = file \n# load and possibly start a file, or possibly multiple files by using the wild-card "*" \n# this is meant for use with schedule, though ensure that the start is non-zero \n# the loaded file will be tied to the filename provided. \n \n# when the torrent finishes, it executes "mv -n <base_path> /home/$NEWUSER1/Download/" \n# and then sets the destination directory to "/home/$NEWUSER1/Download/". (0.7.7+) \n# on_finished = move_complete,"execute=mv,-u,$d.get_base_path=,/home/downloads/<username>/complete/ ;d.set_directory=/home/downloads/<username>/complete/" \n \n# network.scgi.open_port = 127.0.0.1:5995 \nscgi_port = 127.0.0.1:5995 \n \n# alternative calls to bind and IP that should handle dynamic IP"s\n# schedule = ip_tick,0,1800,ip=rakshasa \n# schedule = bind_tick,0,1800,bind=rakshasa \n \n# encryption options, set to none (default) or any combination of the following: \n# allow_incoming, try_outgoing,require,require_RC4,enable_retry,pref er_plaintext \n# \n# the example value allows incoming encrypted connections, starts unencrypted \n# outgoing connections but retries with encryption if they fail, preferring \n# plaintext to RC4 encryption after the encrypted handshake \n#\n# protocol.encryption.set = \nencryption = allow_incoming,enable_retry,prefer_plaintext \n \n \n# Advanced Settings \n# \n# do not modify the following parameters unless you know what you"re doing \n# \n \n# example of scheduling commands: Switch between two ip"s every 5 seconds \n# schedule = "ip_tick1,5,10,ip=torretta" \n# schedule = "ip_tick2,10,10,ip=lampedusa" \n \n# remove a scheduled event \n# schedule_remove = "ip_tick1" \n \n# hash read-ahead controls how many MB to request the kernel to read ahead ahead \n# if the value is too low the disk may not be fully utilized, \n# while if too high the kernel might not be able to keep the read pages \n# in memory thus end up trashing. \n# hash_read_ahead = 8 \n# system.hash.read_ahead.set = 8 \n \n# interval between attempts to check the hash, in milliseconds \n# hash_interval = 50 \n# system.hash.interval.set = 50 \n \n# number of attempts to check the hash while using the mincore status, before forcing \n# overworked systems might need lower values to get a decent hash checking rate \n# hash_max_tries = 3 \n# system.hash.max_tries.set = 3 \n\n# SSL certificate name\n# http_cacert =\n# SSL certificate path \n# http_capath = \n \n# throttle.max_downloads.div.set = \n# max_downloads_div = \n \n# throttle.max_uploads.div.set = \n# max_uploads_div = \n \nsystem.file.max_size.set = -1 \n \n# preload type 0 = Off, 1 = madvise, 2 = direct paging \npieces.preload.type.set = 1 \npieces.preload.min_size.set = 262144\npieces.preload.min_rate.set = 5120\nnetwork.send_buffer.size.set = 1M\nnetwork.receive_buffer.size.set = 131072\n\npieces.sync.always_safe.set = no\npieces.sync.timeout.set = 600\npieces.sync.timeout_safe.set = 900\n\n# scgi_dont_route =\n# network.scgi.dont_route.set =\n\n# session.path.set =\nsession.name.set =\nsession.use_lock.set = yes\nsession.on_completion.set = yes\n\nsystem.file.split_size.set = -1\nsystem.file.split_suffix.set = .part\n\n# set whether the client should try to connect to UDP trackers\n# use_udp_trackers = yes\ntrackers.use_udp.set = yes\n\n# use a http proxy. [url] ;an empty string disables this setting\n# http_proxy =\n# network.http.proxy_address.set =\n\n# The IP address the listening socket and outgoing connections is bound to\n# network.bind_address.set = rakshasa.no\n# network.bind_address.set = 127.0.0.1\n# bind = rakshasa.no\n# bind = 127.0.0.1\n\n# number of sockets to simultaneously keep open\n# max_open_sockets = 65023\n# network.max_open_sockets.set = 65023\n\n# set the umask applied to all files created by rtorrent\n# system.umask.set =\n\n# alternate keyboard mappings\n# qwerty | azerty | qwertz | dvorak\n# key_layout = dvorak\n# keys.layout.set = dvorak'

echo "$BIGLINE" | sudo tee  /home/$NEWUSER1/.rtorrent.rc > /dev/null

sudo perl -pi -e "s/<username>/$NEWUSER1/g" /home/$NEWUSER1/.rtorrent.rc/g /home/$NEWUSER1/.rtorrent.rc
sudo perl -pi -e "s/5995/$SCGIPORT/g" /home/$NEWUSER1/.rtorrent.rc
sudo perl -pi -e "s/99888/$NETWORKPORT/g" /home/$NEWUSER1/.rtorrent.rc

sudo chown $NEWUSER1:$NEWUSER1   /home/$NEWUSER1/.rtorrent.rc:$NEWUSER1 /home/$NEWUSER1/.rtorrent.rc

# 20.
sudo mkdir -p /home/downloads/$NEWUSER1/watch
sudo mkdir -p /home/downloads/$NEWUSER1/.session
sudo chown -R $NEWUSER1:$NEWUSER1 /home/downloads/$NEWUSER1

# 21.

BIGLINE=$'description "ncurses BitTorrent client based on LibTorrent"\nstart on stopped rc RUNLEVEL=[2345]\nstop on runlevel [016]\n\nchdir /home/<username>\nscript\n  su <username> -c \"screen -d -m -S rtorrent rtorrent\"\n  sleep 3\n  su <username> -c \"screen -d -m -S irssi irssi\"\nend script\n\n#do not remove or edit this line\n'

echo "$BIGLINE" | sudo tee  /etc/torrent-invites/rtorrent.conf.template > /dev/null

sudo cp /etc/torrent-invites/rtorrent.conf.template /etc/init/rtorrent.$NEWUSER1.conf

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

echo '<?php $topDirectory = "/home"; ?>' | sudo tee -a /var/www/rutorrent/conf/users/$NEWUSER1/plugins/diskspace/conf.php > /dev/null

#some of those files will be changed later in this script
sudo cp /var/www/rutorrent/conf/access.ini   /var/www/rutorrent/conf/users/$NEWUSER1/
sudo cp /var/www/rutorrent/conf/config.php  /var/www/rutorrent/conf/users/$NEWUSER1/
sudo cp /var/www/rutorrent/conf/plugins.ini   /var/www/rutorrent/conf/users/$NEWUSER1/

# 23.
cd /var/www
sudo chown -R www-data:www-data rutorrent
sudo chmod -R 755 rutorrent

# 24.

#### old file location ---> sudo rm /var/www/rutorrent/conf/config.php

BIGLINE=$'<?php\n// configuration parameters\n// for snoopy client\n@define("HTTP_USER_AGENT", "Mozilla/5.0 (Windows; U; Windows NT 5.1; pl; rv:1.9) Gecko/2008052906 Firefox/3.0", true);\n@define("HTTP_TIME_OUT", 30, true); // in seconds\n@define("HTTP_USE_GZIP", true, true);\n$httpIP = null; // IP string. Or null for any.\n@define("RPC_TIME_OUT", 5, true); // in seconds\n@define("LOG_RPC_CALLS", false, true);\n@define("LOG_RPC_FAULTS", true, true);\n// for php\n@define("PHP_USE_GZIP", false, true);\n@define("PHP_GZIP_LEVEL", 2, true);\n$do_diagnostic = true;\n$log_file = "/tmp/rutorrent_errors.log"; // path to log file (comment or leave blank to disable logging)\n$saveUploadedTorrents = true; // Save uploaded torrents to profile/torrents directory or not\n$overwriteUploadedTorrents = false; // Overwrite existing uploaded torrents in profile/torrents directory or make unique name\n$topDirectory = "/home"; // Upper available directory. Absolute path with trail slash.\n$forbidUserSettings = false;\n$scgi_port = 5995;\n$scgi_host = "127.0.0.1";\n// For web->rtorrent link through unix domain socket\n// (scgi_local in rtorrent conf file), change variables\n// above to something like this:\n//\n//$scgi_port = 0;\n//$scgi_host = "unix:///tmp/rtorrent.sock";\n$XMLRPCMountPoint = "/RPC123"; // DO NOT DELETE THIS LINE!!! DO NOT COMMENT THIS LINE!!!\n$pathToExternals = array(\n"php" => "/usr/bin/php", // Something like /usr/bin/php. If empty, will be found in PATH.\n"curl" => "/usr/bin/curl", // Something like /usr/bin/curl. If empty, will be found in PATH.\n"gzip" => "/bin/gzip", // Something like /usr/bin/gzip. If empty, will be found in PATH.\n"id" => "/usr/bin/id", // Something like /usr/bin/id. If empty, will be found in PATH.\n"stat" => "/usr/bin/stat", // Something like /usr/bin/stat. If empty, will be found in PATH.\n);\n$localhosts = array( // list of local interfaces\n"127.0.0.1",\n"localhost",\n);\n$profilePath = "../share"; // Path to user profiles\n$profileMask = 0777; // Mask for files and directory creation in user profiles.\n// Both Webserver and rtorrent users must have read-write access to it.\n// For example, if Webserver and rtorrent users are in the same group then the value may be 0770.\n?>'

sudo rm /var/www/rutorrent/conf/users/$NEWUSER1/config.php
echo "$BIGLINE" | sudo tee  /var/www/rutorrent/conf/users/$NEWUSER1/config.php > /dev/null

sudo perl -pi -e "s/5995/$SCGIPORT/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php
sudo perl -pi -e "s/RPC123/$NEWRPC1/g" /var/www/rutorrent/conf/users/$NEWUSER1/config.php

# 25.
sudo rm /var/www/rutorrent/conf/users/$NEWUSER1/plugins.ini

BIGLINE=$';; Plugins permissions.\n;; If flag is not found in plugin section, corresponding flag from "default" section is used.\n;; If flag is not found in "default" section, it is assumed to be "yes".\n;;\n;; For setting individual plugin permissions you must write something like that:\n;;\n;; [ratio]\n;; enabled = yes ;; also may be "user-defined", in this case user can control plugins state from UI\n;; canChangeToolbar = yes\n;; canChangeMenu = yes\n;; canChangeOptions = no\n;; canChangeTabs = yes\n;; canChangeColumns = yes\n;; canChangeStatusBar = yes\n;; canChangeCategory = yes\n;; canBeShutdowned = yes\n\n[default]\nenabled = user-defined\ncanChangeToolbar = yes\ncanChangeMenu = yes\ncanChangeOptions = yes\ncanChangeTabs = yes\ncanChangeColumns = yes\ncanChangeStatusBar = yes\ncanChangeCategory = yes\ncanBeShutdowned = yes\n\n;; Default\n\n[_getdir]\nenabled = yes\n[cpuload]\nenabled = user-defined\n[create]\nenabled = user-defined\n[datadir]\nenabled = yes\n[diskspace]\nenabled = user-defined\n[erasedata]\nenabled = user-defined\n[show_peers_like_wtorrent]\nenabled = user-defined\n[theme]\nenabled = yes\n[tracklabels]\nenabled = user-defined\n[trafic]\nenabled = user-defined\n\n;; Enabled\n\n[autotools]\nenabled = user-defined\n[cookies]\nenabled = user-defined\n[data]\nenabled = user-defined\n[edit]\nenabled = user-defined\n[extratio]\nenabled = user-defined\n[extsearch]\nenabled = user-defined\n[filedrop]\nenabled = user-defined\n[filemanager]\nenabled = user-defined\n[geoip]\nenabled = user-defined\n[httprpc]\nenabled = yes\ncanBeShutdowned = no\n[pausewebui]\nenabled = yes\n[ratio]\nenabled = user-defined\n[ratiocolor]\nenabled = user-defined\n[rss]\nenabled = user-defined\n[_task]\nenabled = yes\n[throttle]\nenabled = user-defined\n[titlebar]\nenabled = user-defined\n[unpack]\nenabled = user-defined\n\n;; Disabled\n\n[chat]\nenabled = no\n[chunks]\nenabled = no\n[feeds]\nenabled = no\n[fileshare]\nenabled = no\n[fileupload]\nenabled = no\n[history]\nenabled = no\n[instantsearch]\nenabled = no\n[ipad]\nenabled = no\n[logoff]\nenabled = yes\n[loginmgr]\nenabled = no\n[mediainfo]\nenabled = yes\n[mediastream]\nenabled = yes\n[check_port]\nenabled = no\n[retrackers]\nenabled = no\n[rpc]\nenabled = no\n[rssurlrewrite]\nenabled = no\n[rutracker_check]\nenabled = no\n[scheduler]\nenabled = no\n[screenshots]\nenabled = yes\n[seedingtime]\nenabled = yes\n[source]\nenabled = no\n'

echo "$BIGLINE" | sudo tee  /var/www/rutorrent/conf/users/$NEWUSER1/plugins.ini > /dev/null


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
sudo cp _conf.php /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php

sudo rm /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php
BIGLINE=$'<?php\n$autodlPort = <PORT>;\n$autodlPassword = "<PASSWORD>";\n?>'
echo "$BIGLINE" | sudo tee  /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php > /dev/null

sudo perl -pi -e "s/<PASSWORD>/$IRSSIPASSWORD/g"  /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php
sudo perl -pi -e "s/<PORT>/$IRSSIPORT/g" /var/www/rutorrent/conf/users/$NEWUSER1/plugins/autodl-irssi/conf.php

#sudo chown -R $NEWUSER1:www-data   /var/www/rutorrent/conf/users/$NEWUSER1
#sudo find /var/www/rutorrent/conf/users/$NEWUSER1 -type d -exec sudo chmod 770 {} \;
#sudo find /var/www/rutorrent/conf/users/$NEWUSER1 -type d -exec sudo chmod 770 {} \;
#chmod 660 {} \;

sudo rm /home/$NEWUSER1/.autodl/autodl.cfg
BIGLINE=$'[options]\ngui-server-port = <PORT>\ngui-server-password = <PASSWORD>\n'
echo "$BIGLINE" | sudo tee  /home/$NEWUSER1/.autodl/autodl.cfg > /dev/null

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
sudo rm -R /var/www/rutorrent/plugins/mediastream
sudo rm -R /var/www/stream

cd /var/www/rutorrent/plugins/
sudo svn co http://svn.rutorrent.org/svn/filemanager/trunk/mediastream

cd /var/www/rutorrent/plugins/
sudo svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

BIGLINE=$'<?php\n\n$fm["tempdir"] = "/tmp";                // path were to store temporary data ; must be writable\n$fm["mkdperm"] = 755;           // default permission to set to new created directories\n\n// set with fullpath to binary or leave empty\n$pathToExternals["rar"] = "/usr/bin/rar";\n$pathToExternals["zip"] = "/usr/bin/zip";\n$pathToExternals["unzip"] = "/usr/bin/unzip";\n$pathToExternals["tar"] = "/bin/tar";\n$pathToExternals["bzip"] = "/bin/bzip2";\n$pathToExternals["bzip2"] = "/bin/bzip2";\n\n// archive mangling, see archiver man page before editing\n$fm["archive"]["types"] = array("rar", "zip", "tar", "gzip", "bzip2");\n\n$fm["archive"]["compress"][0] = range(0, 5);\n$fm["archive"]["compress"][1] = array("-0", "-1", "-9");\n$fm["archive"]["compress"][2] = $fm["archive"]["compress"][3] = $fm["archive"]["compress"][4] = array(0);\n\n?>'

echo "$BIGLINE" | sudo tee /var/www/rutorrent/plugins/filemanager/conf.php > /dev/null

sudo mkdir -p /var/www/stream/
sudo ln -s /var/www/rutorrent/plugins/mediastream/view.php /var/www/stream/view.php
sudo chown www-data: /var/www/stream
sudo chown www-data: /var/www/stream/view.php

echo "<?php \$streampath = 'http://$NEWHOSTNAME1/stream/view.php'; ?>" | sudo tee /var/www/rutorrent/plugins/mediastream/conf.php > /dev/null

# 33.
# createSeedboxUser script creation

echo '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' | base64 --decode | sudo tee -a /etc/torrent-invites/createSeedboxUser.gz > /dev/null

sudo gunzip /etc/torrent-invites/createSeedboxUser.gz

sudo chmod +x /etc/torrent-invites/createSeedboxUser

echo 'IyMjIyMjIyMjIyMjIyMjIyMjIyMjIEZJUlNUIExJTkUKIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KIyEvYmluL2Jhc2gKIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCiMgMy4xCgpORVdVU0VSMT1hCk5FV1VTRVIyPWIKCndoaWxlIFsgISAkTkVXVVNFUjEgPSAkTkVXVVNFUjIgXTsKZG8KICBjbGVhcgogICBlY2hvIC1uICJUeXBlIHVzZXJuYW1lIHRvIGJlIERFTEVURUQ6ICIKICAgcmVhZCBORVdVU0VSMQogICBlY2hvIC1uICJSZXR5cGUgdXNlcm5hbWU6ICIKICAgcmVhZCBORVdVU0VSMgogICBlY2hvICIiCmRvbmUKCiMgMy4xLjEKCiNraWxsIGFsbCBwcm9jZXNzZXMgcmVsYXRlZCB0byB0aGF0IHVzZXIKc3VkbyBraWxsIC05ICQoIHBzIC1lZiB8IGdyZXAgJE5FV1VTRVIxIHwgYXdrICd7IHByaW50ICQyIH0nICkKCiMgMy4yCgpzdWRvIHVzZXJkZWwgLS1yZW1vdmUgLS1mb3JjZSAkTkVXVVNFUjEgCgojIDEyLgoKI3JlbW92ZSBjdXJyZW50IHBhc3N3b3JkIGZyb20gaHRwYXNzd29yZApzdWRvIHBlcmwgLXBpIC1lICJzL14kTkVXVVNFUjFcOi4qXG4kLy9nIiAvZXRjL2FwYWNoZTIvaHRwYXNzd2QKCiMgMjAuCnN1ZG8gcm0gLXIgL2hvbWUvZG93bmxvYWRzLyRORVdVU0VSMQoKIyAyMS4Kc3VkbyBybSAvZXRjL2luaXQvcnRvcnJlbnQuJE5FV1VTRVIxLmNvbmYKCiMgMjkuCnN1ZG8gcm0gLXIgL3Zhci93d3cvcnV0b3JyZW50L2NvbmYvdXNlcnMvJE5FV1VTRVIxCgojIyMjIyMjIyMjIyMjIyMjIyMjIyMgTEFTVCBMSU5FICMjIyMjIyMjIyMjCgoK' | base64 --decode | sudo tee -a /etc/torrent-invites/deleteSeedboxUser > /dev/null

sudo chmod +x /etc/torrent-invites/deleteSeedboxUser

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