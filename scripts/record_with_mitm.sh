#!/bin/bash

if [ -z "${MITMDUMP}" ]; then
  MITMDUMP=./mitmdump
fi

echo "! Using mitmdump from '$MITMDUMP'"

#prepare inputs for the mitmengine
rm /tmp/01_encrypted.pcap
touch /tmp/01_encrypted.pcap

rm /tmp/02_decrypted.pcap
touch /tmp/02_decrypted.pcap

rm /tmp/03_headers.json
touch /tmp/03_headers.json


#prepare to launch mitmproxy
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.send_redirects=0
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to-port 8080
ip6tables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j REDIRECT --to-port 8080
ip6tables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to-port 8080

#launch mitmdump (same as mitmproxy, but can be launched in background) in transparent mode
MITMPROXY_SSLKEYLOGFILE=/tmp/ssl_key_log $MITMDUMP --mode transparent --showhost &
export MITMPROXY_PID=$!

#record data with tshark

#enp0s8 - interface before mitmproxy
tshark -i enp0s8 -w /tmp/01_encrypted.pcap &
export TSHARK_RX_CAP_PID=$!

#enp0s3 - interface which goes to internet
tshark -i enp0s3 -w /tmp/01_uplink_encrypted.pcap &
export TSHARK_TX_CAP_PID=$!

echo "waiting on requests"
sleep 30
echo "lol, ne uspel"

kill $MITMPROXY_PID
kill $TSHARK_RX_CAP_PID
kill $TSHARK_TX_CAP_PID

iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1

#decrypt victim's data in order to get user agents
tshark -nr /tmp/01_encrypted.pcap -Y http -o tls.keylog_file:/tmp/ssl_key_log -w /tmp/02_decrypted.pcap

#parse decrypted data to json (this json is used by mitmengine as an input)
tshark -nr /tmp/02_decrypted.pcap -T json -Y http -e http.request.line > /tmp/03_headers.json

#run mitmengine with prepared data
chmod a+rw /tmp/01_uplink_encrypted.pcap /tmp/03_headers.json
sudo -i -u linuxlite /bin/bash -c "(cd /home/linuxlite/mitmengine && go run cmd/demo/my_main.go -handshake /tmp/01_uplink_encrypted.pcap -header /tmp/03_headers.json)"
