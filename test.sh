#!/bin/sh

#Test Script

#-------------------------------------------------
			User Configurable Section
#-------------------------------------------------

EXTERNAL_IP=
SECONDARY_INTERFACE=

#-------------------------------------------------
			Test Script - DO NOT TOUCH
#------------------------------------------------

echo "Firewall Test started at `date`"

echo "------------------------------------------"
echo "Testing NMAP"
echo "Open ports should show as: 80,86,88,89,443"
nmap -v $EXTERNAL_IP
echo "------------------------------------------"


echo "------------------------------------------"
echo "Testing TCP"

echo "Testing TCP Packets allowed on port 80"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 80

echo "Testing TCP Packets allowed on port 86"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 86

echo "Testing TCP Packets allowed on port 88"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 80

echo "Testing TCP Packets allowed on port 89"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 80

echo "Testing TCP Packets allowed on port 443"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 80

echo "Testing blocked TCP Ports"
echo "Expected result: 100% packet loss"
hping3 $EXTERNAL_IP -c 4 -S -p 22
echo "------------------------------------------"


echo "------------------------------------------"
echo "Testing UDP"

echo "Testing UDP Packets allowed on port 80"
echo "Expected result: 0% packet loss"
hping3 $EXTERNAL_IP --udp -c 4 -p 80

echo "Testing blocked UDP Ports"
echo "Expected result: 100% packet loss"
hping3 $EXTERNAL_IP --udp -c 4 -S -p 22




echo "------------------------------------------"
