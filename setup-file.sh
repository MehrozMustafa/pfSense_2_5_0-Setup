echo PermitRootLogin yes >> /etc/ssh/sshd_config
service sshd restart

pkg install -y pkg nano

pkg install -y git nginx poudriere-devel rsync sudo

pkg install -y vmdktool curl qemu-user-static gtar xmlstarlet pkgconf openssl

portsnap fetch extract

pkg install -y open-vm-tools

set pfSense_gui_branch=v2_5_0
set pfSense_port_branch=v2_5_0
set product_name=libreSense

cd /usr/local/www/nginx/
rm -rf *
mkdir -p packages
ln -s /root/pfsense/tmp/${product_name}_${pfSense_gui_branch}_amd64-core/.latest packages/${product_name}_${pfSense_gui_branch}_amd64-core
ln -s /usr/local/poudriere/data/packages/${product_name}_${pfSense_gui_branch}_amd64-${product_name}_${pfSense_port_branch} packages/${product_name}_${pfSense_gui_branch}_amd64-${product_name}_${pfSense_port_branch} 
ln -s /usr/local/poudriere/data/logs/bulk/${product_name}_${pfSense_gui_branch}_amd64-${product_name}_${pfSense_port_branch}/latest poudriere

sed -i '' 's+/usr/local/www/nginx;+/usr/local/www/nginx; autoindex on;+g' /usr/local/etc/nginx/nginx.conf
echo nginx_enable=\"YES\" >> /etc/rc.conf
service nginx restart

mkdir -p /root/sign/
cd /root/sign/
openssl genrsa -out repo.key 2048
chmod 0400 repo.key
openssl rsa -in repo.key -out repo.pub -pubout
printf "function: sha256\nfingerprint: `sha256 -q repo.pub`\n" > fingerprint
curl -o /root/sign/sign.sh https://raw.githubusercontent.com/freebsd/pkg/master/scripts/sign.sh
chmod +x /root/sign/sign.sh

cd /root
git clone https://github.com/MehrozMustafa/pfsense.git
cd pfsense
git checkout RELENG_2_5_0

rm src/usr/local/share/libreSense/keys/pkg/trusted/*
cp /root/sign/fingerprint src/usr/local/share/libreSense/keys/pkg/trusted/fingerprint

