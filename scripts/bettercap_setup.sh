#!/bin/bash
sudo apt-get update
cd /tmp
wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
sudo tar -xvf go1.11.linux-amd64.tar.gz
sudo mv go /usr/local
echo ' 
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
' >> ~/.profile

source ~/.profile

apt-get install build-essential
apt-get install libpcap-dev
apt-get install libusb-1.0-0-dev
apt-get install libnetfilter-queue-dev

sudo apt-get install git
go get github.com/bettercap/bettercap
cd $GOPATH/src/github.com/bettercap/bettercap
make build
sudo make install 
