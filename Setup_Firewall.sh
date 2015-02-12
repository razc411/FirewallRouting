#!/bin/bash

#########################################################################################
# Assignment 2 - Standalone Linux Firewall & Packet Filter                              #
#																						#
# Authors: Brij Shah | A00717689  &&  Ramzi Chennafi | A00123456                        #
#																						#
# Usage:				                                                #
#########################################################################################

#########################################################################################
#                          USER CONFIGUREABLE SECTION                                   #
#########################################################################################

ALLOWED_TCP_PORTS="89,86,88,443,80,53"
ALLOWED_UDP_PORTS="89,86,88,443,80,53,67,68"
BLOCKED_TCP="32768,32769,32770,32771,32772,32773,32774,32775,137,138,139,515,111,23"
BLOCKED_UDP="32768,32769,32770,32771,32772,32773,32774,32775,137,138,139"
ALLOWED_ICMP_PACKET_TYPES="1,2,3"
INTERNAL_FIREWALL_HOST="192.168.10.1"
EXTERNAL_FIREWALL_IP="192.168.0.9"
EXTERNAL_INTERFACE="em1"
SUBNET_ADDR="192.168.10.0/24"
INTERNAL_INTERFACE="p3p1"
FW_PROGRAM_DIR='/sbin/'
FW_NAME='iptables'

#########################################################################################
#                          DO NOT EDIT ANYTHING BELOW                                   #
#########################################################################################

#Clear Rules & Policies
$FW_PROGRAM_DIR$FW_NAME -F
$FW_PROGRAM_DIR$FW_NAME -t nat -F
$FW_PROGRAM_DIR$FW_NAME -t mangle -F
$FW_PROGRAM_DIR$FW_NAME -X

#Set default policies to DROP
$FW_PROGRAM_DIR$FW_NAME -P INPUT DROP
$FW_PROGRAM_DIR$FW_NAME -P FORWARD DROP
$FW_PROGRAM_DIR$FW_NAME -P OUTPUT DROP

#Block external maliciousness
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -d $INTERNAL_FIREWALL_HOST -j DROP
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -s 192.168.10.0/24 -j DROP
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -p tcp -m multiport --dports $BLOCKED_TCP -j DROP
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -p udp -m multiport --dports $BLOCKED_UDP -j DROP

#Drop all TCP packets with the SYN and FIN bit set
$FW_PROGRAM_DIR$FW_NAME -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

#Do not allow Telnet packets at all
$FW_PROGRAM_DIR$FW_NAME -A FORWARD -p tcp --sport 23 -j DROP

#Inbound/Outbound TCP packets on allowed ports
arr=$(echo $ALLOWED_TCP_PORTS | tr "," "\n")
for PORT in $arr
	do $FW_PROGRAM_DIR$FW_NAME -A FORWARD -p tcp -m state --state ESTABLISHED,NEW --dport $PORT -j ACCEPT
	   $FW_PROGRAM_DIR$FW_NAME -A FORWARD -p tcp -m state --state ESTABLISHED,NEW --sport $PORT -j ACCEPT 
done

#Inbound/Outbound UDP packets on allowed ports
arr=$(echo $ALLOWED_UDP_PORTS | tr "," "\n")
for PORT in $arr
	do $FW_PROGRAM_DIR$FW_NAME -A FORWARD -p udp --dport $PORT -j ACCEPT
	   $FW_PROGRAM_DIR$FW_NAME -A FORWARD -p udp --sport $PORT -j ACCEPT
done

#Inbound/Outbound ICMP packets based on type numbers
arr=$(echo $ALLOWED_ICMP_PACKET_TYPES | tr "," "\n")
for TYPE in $arr
	do $FW_PROGRAM_DIR$FW_NAME -A FORWARD -p icmp --icmp-type $TYPE -m state --state ESTABLISHED,NEW,RELATED -j ACCEPT
done

#Accept fragments
$FW_PROGRAM_DIR$FW_NAME -A FORWARD -i $EXTERNAL_INTERFACE -f -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A FORWARD -i $INTERNAL_INTERFACE -f -j ACCEPT

#Set control connections to Minimum delay for FTP and SSH services
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 21 -j TOS --set-tos Minimize-Delay
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 22 -j TOS --set-tos Minimize-Delay

#FTP data to maximum throughput
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 20 -j TOS --set-tos Maximize-Throughput
