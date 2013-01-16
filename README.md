## The Seedbox From Scratch Script
#### Current version = 2.1.9
#### Last stable version = 2.1.8

This is a script I've being working for some time now. I decided to share it here because it has some good things to add:

* A multi-user enviroment, you'll have scripts to add and delete users.
* Linux Quota, to control how much space every user can use in your box.

## Installed software
* ruTorrent 3.4 + official plugins
* rTorrent 0.9.2 or 0.9.3 (you can choose, downgrade and upgrade at any time)
* Deluge 1.3.5 or 0.9.3 (you can choose, downgrade and upgrade at any time)
* libTorrrent 0.13.2 or 0.12.9
* mktorrent
* Fail2ban - to avoid apache and ssh exploits. Fail2ban bans IPs that show malicious signs -- too many password failures, seeking for exploits, etc.
* Apache (SSL)
* OpenVPN
* PHP 5 and PHP-FPM (FastCGI to increase performance)
* Linux Quota
* SSH Server (for SSH terminal and sFTP connections)
* vsftpd (Very Secure FTP Deamon)
* IRSSI
* Webmin (use it to manage your users quota)
* sabnzbd: http://sabnzbd.org/
* Rapidleech (http://www.rapidleech.com)

## Main ruTorrent plugins
autotoolscpuload, diskspace, erasedata, extratio, extsearch, feeds, filedrop, filemanager, geoip, history, logoff, mediainfo, mediastream, rss, scheduler, screenshots, theme, trafic and unpack

## Additional ruTorrent plugins
* Autodl-IRSSI (with an updated list of trackers)
* A modified version of Diskpace to support quota (by me)
* Filemanager (modified to handle rar, zip, unzip, tar and bzip)
* Fileupload
* Fileshare Plugin (http://forums.rutorrent.org/index.php?topic=705.0)
* MediaStream (to watch your videos right from your seedbox)
* Logoff
* Theme: Oblivion

## Before installation
You need to have a "blank" server installation, if you have a Kimsufi, just do a "reinstall" on it, using Ubuntu Server 12.04.
After that access your box using a SSH client, like PuTTY.

## Warnings

####If you don't know Linux ENOUGH:

DO NOT install this script on a non OVH Host. It is doable, but you'll have to know Linux to solve some problems.

DO NOT use capital letters, all your usernames should be written in lowercase.

DO NOT upgrade anything in your box, ask in the thread before even thinking about it.

DO NOT try to reconfigure packages using other tutorials.

## How to install
Just copy and paste those commands on your terminal:

```
wget -N https://raw.github.com/Notos/seedbox-from-scratch/v2.1.9/seedbox-from-scratch.sh
time bash ~/seedbox-from-scratch.sh
```

####You must be logged as root to run this installation or use sudo on it.

## Commands
After installing you will have access to the following commands to be used directly in terminal
* createSeedboxUser
* deleteSeedboxUser
* changeUserPassword
* installRapidleech
* installOpenVPN
* installSABnzbd
* installWebmin
* installDeluge
* updategitRepository
* removeWebmin
* upgradeRTorrent
* installRTorrent
* restartSeedbox

* While executing them, if sudo is needed, they will ask for a password.

## Services
To access services installed on your new server point your browser to the following address:
```
https://<Server IP or Server Name>/seedboxInfo.php
```

####OpenVPN
To use your VPN you will need a VPN client compatible with [OpenVPN](http://openvpn.net/index.php?option=com_content&id=357), necessary files to configure your connection are in this link in your box:
```
http://<Server IP or Server Name>/rutorrent/vpn.zip` and use it in any OpenVPN client.
```

## Supported and tested servers
* Ubuntu Server 12.10.0 - 64bit (on VM environment)
* Ubuntu Server 12.04.x - 64bit (on VM environment)
* Ubuntu Server 12.04.x - 32bit (OVH's Kimsufi 2G and 16G - Precise)
* Ubuntu Server 12.04.x - 64bit (OVH's Kimsufi 2G and 16G - Precise)
* Debian 6.0.6 - 32 and 64bit (OVH's Kimsufi 2G - Squeeze)
* Debian 6.0.6 - 32 and 64bit (on VM environment)

## Quota
Quota is disabled by default in your box. To enable and use it, you'll have to open Webmin, using the address you can find in one of the tables box above this. After you sucessfully logged on Webmin, enable it by clicking

System => Disk and Network Filesystems => /home => Use Quotas? => Select "Only User" => Save

Now you'll have to configure quota for each user, doing

System => Disk Quotas => /home => <username> => Configure the "Soft kilobyte limit" => Update

As soon as you save it, your seedbox will also update the available space to all your users.

## Changelog
Take a look at seedbox-from-scratch.sh, it's all there.

## Support

There is no real support for this script, but people is talking a lot about it [here](http://www.torrent-invites.com/seedbox-tutorials/207635-seedbox-scratch-script-multi-user-quota-sabnzbd-deluge.html) and you may find solutions for your problems in the thread.

