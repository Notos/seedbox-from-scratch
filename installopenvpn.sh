#!/bin/bash
# Quick and dirty OpenVPN install script
# Tested on debian 5.0 32bit, openvz minimal debian OS template
# and Ubuntu 9.04 32 bit minimal, should work on 64bit images as well
# Please submit feedback and questions at support@vpsnoc.com
# John Malkowski vpsnoc.com 01/18/2010

#Install OPENVPN
dpkg --purge remove openvpn
apt-get --purge remove openvpn
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1  | awk '{print $2}'`
apt-get update
apt-get install openvpn libssl-dev  openssl
cd /etc/openvpn/
cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0/
chmod +rwx *
. ./vars
./clean-all
source ./vars

echo -e "\n\n\n\n\n\n\n" | ./build-ca
clear
echo "####################################"
echo "Feel free to accept default values"
echo "Wouldn't recommend setting a password here"
echo "Then you'd have to type in the password each time openVPN starts/restarts"
echo "####################################"
./build-key-server server
./build-dh
cp keys/{ca.crt,ca.key,server.crt,server.key,dh1024.pem} /etc/openvpn/

clear
echo "####################################"
echo "Feel free to accept default values"
echo "This is your client key, you may set a password here but it's not required"
echo "####################################"
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
dhcp-option DNS 208.67.222.222
verb 3"

echo "$client" > $HOSTNAME.ovpn

tar czf keys.tgz ca.crt ca.key client1.crt client1.csr client1.key $HOSTNAME.ovpn
mv keys.tgz /root

opvpn='
dev tun
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
push "route 10.8.0.0 255.255.255.0"
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
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o venet0 -j MASQUERADE
iptables-save > /etc/iptables.conf
echo "#!/bin/sh" > /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables.conf" >> /etc/network/if-up.d/iptables
chmod +x /etc/network/if-up.d/iptables
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

/etc/init.d/openvpn start
cd
rm installopenvpn.sh
clear
echo "Download /root/keys.tgz to use OpenVPN"