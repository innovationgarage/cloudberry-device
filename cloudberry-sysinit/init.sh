#! /bin/sh

uci delete network.lan
uci commit
/etc/init.d/network restart

echo -n "Wiating for network..."
while ! ping -c 1 -W 1 google.com > /dev/null 2>&1; do
  echo -n "."
  sleep 1
done
echo

opkg update
opkg install ca-certificates
opkg install ca-bundle
opkg install libustream-openssl
opkg install rsync
opkg install openvpn-openssl
opkg install openwisp-config-openssl

if ! grep "INIT-OPENWISP DONE" /usr/sbin/openwisp_config > /dev/null; then
  sed \
    -i /usr/sbin/openwisp_config \
    -e 's+\(FETCH_COMMAND=".*\) --capath $CAPATH"+if echo $URL | grep http:// > /dev/null; then \1"; else \1 --capath $CAPATH"; fi+g'
  echo "# INIT-OPENWISP DONE" >> /usr/sbin/openwisp_config
fi

rsync -a --progress /cloudberry-sysinit/files/ /
