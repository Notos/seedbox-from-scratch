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
# OpenVPN in beta --- Tested on Ubuntu 12.04 64Bit
#

dpkg --purge remove openvpn
apt-get --yes --purge remove openvpn
rm -r /etc/openvpn
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | head -1 | awk '{print $2}'`
apt-get update
apt-get --yes install openvpn libssl-dev  openssl
cd /etc/openvpn/
cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0/
mkdir /etc/openvpn/easy-rsa/2.0/keys
chmod +rwx *
cp openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
source ./vars

echo -e "\n\n\n\n\n\n\n" | ./build-ca
clear
echo ""
echo "If you don't want to be asked for a password, do not type one in the next fields. "
echo ""
echo ""
echo ""
./build-key-server server
./build-dh
cp keys/{ca.crt,ca.key,server.crt,server.key,dh1024.pem} /etc/openvpn/

clear
echo ""
echo "Here you can type a password but you're not forced to. "
echo ""
echo ""
echo ""
./build-key client1
cd keys/

client="
client
remote $ip 1194
dev tun
comp-lzo
ca ca.crt
cert client1.crt
key client1.key
route-delay 2
route-method exe
redirect-gateway def1
dhcp-option DNS 8.8.8.8
verb 3"

echo "$client" > $HOSTNAME.ovpn

zip vpn.zip ca.crt ca.key client1.crt client1.csr client1.key $HOSTNAME.ovpn
mv vpn.zip /var/www/rutorrent

opvpn='
dev tun
server 10.191.12.0 255.255.255.0
ifconfig-pool-persist ipp.txt
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
push "route 10.191.12.0 255.255.255.0"
push "redirect-gateway"
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
group daemon
daemon'

echo "$opvpn" > /etc/openvpn/openvpn.conf

echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables -t nat -A POSTROUTING -s 10.191.12.0/24 -o venet0 -j MASQUERADE
/sbin/iptables-save > /etc/iptables.conf
echo "#\!/bin/sh" > /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables.conf" >> /etc/network/if-up.d/iptables
chmod +x /etc/network/if-up.d/iptables
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

/etc/init.d/openvpn start
cd
rm installopenvpn.sh
clear
echo "Download http://your-box-ip/vpn.zip to use OpenVPN"
