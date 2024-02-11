

echo 'Make sure you are running this script as root, use sudo -s'

echo 'This script will install Proxmox VE 8.x for Debian Bookworm (latest raspbian OS)'

echo 'Set your root password'
passwd root

read -p "Enter ip address: " ipaddress
read -p "Enter gateway ip: " gateway
read -p "Enter DNS ip: " dns
read -p "Enter hostname: " hostname

printf "auto lo
iface lo inet loopback

iface eth0 inet manual

auto vmbr0
iface vmbr0 inet static
        address $ipaddress
        gateway $gateway
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0 \n" > /etc/network/interfaces.new

hostfilecontent="
127.0.0.1\tlocalhost.localdomain localhost\n$ipaddress\t$hostname.proxmox.com ${hostname}\n::1\tlocalhost ip6-localhost ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters"
echo -e $hostfilecontent > /etc/hosts

echo 'deb [arch=arm64] https://mirrors.apqa.cn/proxmox/debian/pve bookworm port'>/etc/apt/sources.list.d/pveport.list
curl https://mirrors.apqa.cn/proxmox/debian/pveport.gpg -o /etc/apt/trusted.gpg.d/pveport.gpg

apt update && apt full-upgrade

apt install ifupdown2
apt install proxmox-ve postfix open-iscsi

nmcli con up 'Wired connection 1'

echo 'Rebooting now, the web insterface will be at https://$ipaddress:8006'
reboot
