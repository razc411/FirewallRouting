#!/bin/sh

#Test Script

#-------------------------------------------------
			User Configurable Section
#-------------------------------------------------
ALLOWED_TCP_PORTS="89,86,88,443,80,53"
ALLOWED_UDP_PORTS="89,86,88,443,80,53,67,68"
ALLOWED_ICMP_PACKET_TYPES="1,2,3"
EXTERNAL_IP="192.168.0.9"
SECONDARY_INTERFACE="p3p1"

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

arr=$(echo $ALLOWED_TCP_PORTS | tr "," "\n")
for PORT in $arr
	do echo "Testing TCP Packets allowed on port $PORT"
	   echo "Expected result: 0% packet loss"
	   hping3 $EXTERNAL_IP -c 1 -p $PORT
done
echo "------------------------------------------"
echo "Testing UDP"
arr=$(echo $ALLOWED_UDP_PORTS | tr "," "\n")
for PORT in $arr
	do echo "Testing TCP Packets allowed on port $PORT"
	   echo "Expected result: 0% packet loss"
	   hping3 $EXTERNAL_IP -c 1 -p $PORT
done
echo "------------------------------------------"
echo "Testing ICMP packets"
arr=$(echo $ALLOWED_ICMP_PACKET_TYPES | tr "," "\n")
for TYPE in $arr
	do echo "Testing ICMP packets of type $TYPE"
	   echo "Expected result: 0% packet loss"
	   hping3 $EXTERNAL_IP --icmp --icmptype $TYPE
done
echo "------------------------------------------"
echo "Testing packets from internal IP on an external interface"
hping3 $EXTERNAL_IP -c 1 --spoof 192.168.10.2
echo "------------------------------------------"
echo "Testing fragment receiving"
hping3 $EXTERNAL_IP -c 1 -f -p 80
echo "------------------------------------------"
echo "Testing SYNs on a high port"
hping3 $EXTERNAL_IP -c 1 -S -p 33924
echo "------------------------------------------"
echo "Testing blocked TCP Ports"
echo "Expected result: 100% packet loss"
hping3 $EXTERNAL_IP -c 1 -S -p 22
echo "------------------------------------------"
echo "Testing SYN FIN packets to port 80"
hping3 $EXTERNAL_IP -c 1 -S -F -p 80
echo "------------------------------------------"
echo "Testing Telnet"
hping3 $EXTERNAL_IP -c 1 -p 23
echo "------------------------------------------"
echo "Testing blocked ports"
hping3 $EXTERNAL_IP -c 8 -p 32768
hping3 $EXTERNAL_IP -c 3 -p 137
hping3 $EXTERNAL_IP -c 1 -p 111
hping3 $EXTERNAL_IP -c 1 -p 515
echo "------------------------------------------"
echo "Firewall Test completed at `date`"


