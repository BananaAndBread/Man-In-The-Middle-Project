#!/bin/sh
  sudo apt-get update
  sudo apt install quagga
  sudo apt install quagga-doc
  sed -i '/^#.*net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
  cp /usr/share/doc/quagga-core/examples/vtysh.conf.sample\
  /etc/quagga/vtysh.conf
  cp /usr/share/doc/quagga-core/examples/zebra.conf.sample\
  /etc/quagga/zebra.conf
  cp /usr/share/doc/quagga-core/examples/bgpd.conf.sample\
  /etc/quagga/bgpd.conf
  sudo chown quagga:quagga /etc/quagga/*.conf
  sudo chown quagga:quaggavty /etc/quagga/vtysh.conf
  sudo chmod 640 /etc/quagga/*.conf


  sudo service zebra start


  sudo service bgpd start



  sudo systemctl is-enabled zebra.service
  sudo systemctl is-enabled bgpd.service
  sudo systemctl enable zebra.service
  sudo systemctl enable bgpd.service

  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
  ufw disable


  sudo apt install isc-dhcp-server

  echo 'default-lease-time 600;
  max-lease-time 7200;
  ddns-update-style none;
  authoritative;
  subnet 192.168.50.0 netmask 255.255.255.0 {
  range 192.168.50.50 192.168.50.100;
  option routers 192.168.50.1;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 192.168.50.1,   8.8.8.8;
  }' > /etc/dhcp/dhcpd.conf
  sudo systemctl restart isc-dhcp-server



echo '
auto lo
iface lo inet loopback

auto enp0s8
iface enp0s8 inet static
        address 192.168.50.1
        netmask 255.255.255.0
        dns-nameservers 8.8.8.8
' > /etc/network/interfaces


  sudo ip a flush enp0s8
  sudo systemctl restart networking.service
  sudo systemctl restart isc-dhcp-server
