#!/bin/sh

#Test Script

#-------------------------------------------------
#			User Configurable Section
#-------------------------------------------------
ALLOWED_TCP_PORTS="89,86,88,443,80,53"
ALLOWED_UDP_PORTS="89,86,88,443,80,53,67,68"
ALLOWED_ICMP_PACKET_TYPES="1,2,3"
EXTERNAL_IP="localhost"
SECONDARY_INTERFACE="p3p1"

#-------------------------------------------------
#			Test Script - DO NOT TOUCH
#------------------------------------------------
echo "Firewall Test started at `date`"
echo "------------------------------------------"
echo "Testing NMAP"
echo "Open ports should show as: $ALLOWED_TCP_PORTS"
nmap -v $EXTERNAL_IP
echo "------------------------------------------"
echo ""
echo "------------------------------------------"
echo "Testing TCP"
echo ""
arr=$(echo $ALLOWED_TCP_PORTS | tr "," "\n")
for PORT in $arr
	do echo ""
	   echo "------------------------------------------"
	   echo "Testing TCP Packets allowed on port $PORT"
	   echo "Expected result: 0% packet loss"
	   echo ""
	   hping3 $EXTERNAL_IP -c 3 -k -S -p $PORT
done
echo "------------------------------------------\n"
echo "------------------------------------------"
echo "Testing UDP"
echo ""
arr=$(echo $ALLOWED_UDP_PORTS | tr "," "\n")
for PORT in $arr
	do echo ""
	   echo "------------------------------------------"	
	   echo "Testing TCP Packets allowed on port $PORT"
	   echo "Expected result: 0% packet loss"
	   echo ""
	   hping3 $EXTERNAL_IP -c 3 -k -p $PORT
done
echo "------------------------------------------"
echo ""
echo "------------------------------------------"
echo "Testing ICMP packets"
echo ""
arr=$(echo $ALLOWED_ICMP_PACKET_TYPES | tr "," "\n")
for TYPE in $arr
	do echo ""
	   echo "------------------------------------------"
	   echo "Testing ICMP packets of type $TYPE"
	   echo "Expected result: 0% packet loss"
	   echo ""
	   hping3 $EXTERNAL_IP -c 2 -k --icmp --icmptype $TYPE
done
echo "------------------------------------------"
echo ""
echo "------------------------------------------"
echo "Testing packets from internal IP on an external interface"
echo "Expected result: 100% packet loss"
echo ""
hping3 $EXTERNAL_IP -c 1 -S --spoof 192.168.10.2
echo "------------------------------------------"
echo "Testing fragment receiving"
echo "Expected result: 0% packet losss"
echo ""
hping3 $EXTERNAL_IP -c 1 -f -p 80
echo "------------------------------------------"
echo "Testing SYNs on a high port"
echo "Expected result: 100% packet loss"
echo ""
hping3 $EXTERNAL_IP -c 1 -S -p 33924
echo "------------------------------------------"
echo "Testing blocked TCP Ports"
echo "Expected result: 100% packet loss"
echo ""
hping3 $EXTERNAL_IP -c 1 -S -p 22
echo "------------------------------------------"
echo "Testing SYN FIN packets to port 80"
echo "Expected result: 100% packet loss"
echo ""
hping3 $EXTERNAL_IP -c 1 -S -F -p 80
echo "------------------------------------------"
echo "Testing Telnet"
echo "Expected result: 100% packet loss"
echo ""
hping3 $EXTERNAL_IP -c 1 -p 23
echo "------------------------------------------"
echo "Testing blocked ports"
echo "Expected result: 100% packet loss"
echo ""
echo "Testing ports 32768-32775"
echo ""
hping3 $EXTERNAL_IP -c 8 -S -p ++32768
hping3 $EXTERNAL_IP -2 -c 8 -p ++32768
echo ""
echo "Testing ports 137-139"
echo ""
hping3 $EXTERNAL_IP -c 3 -p ++137
hping3 $EXTERNAL_IP -2 -c 3 -p ++137
echo ""
echo "Testing TCP port 111"
echo ""
hping3 $EXTERNAL_IP -c 1 -S -p 111
echo ""
echo "Testing TCP port 515"
echo ""
hping3 $EXTERNAL_IP -c 1 -S -p 515
echo "------------------------------------------"
echo ""
echo "Firewall Test completed at `date`"


