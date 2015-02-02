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

ALLOWED_TCP_PORTS="89,86,88,1000:4000"
ALLOWED_UDP_PORTS="89,86,88,1000:4000"
ALLOWED_ICMP_PACKET_TYPES="1,2,3"
INTERNAL_FIREWALL_HOST="192.168.10.1"
EXTERNAL_FIREWALL_IP="192.168.0.17"
EXTERNAL_INTERFACE="em1"
INTERNAL_INTERFACE="p3p1"
FW_PROGRAM_DIR='/sbin/'
FW_NAME='iptables'

#########################################################################################
#                          DO NOT EDIT ANYTHING BELOW                                   #
#########################################################################################

#Clear Rules & Policies
$FW_PROGRAM_DIR$FW_NAME -F
$FW_PROGRAM_DIR$FW_NAME -X

#Set default policies to DROP
$FW_PROGRAM_DIR$FW_NAME -P INPUT DROP
$FW_PROGRAM_DIR$FW_NAME -P FORWARD DROP
$FW_PROGRAM_DIR$FW_NAME -P OUTPUT DROP

#NAT routing rules
$FW_PROGRAM_DIR$FW_NAME -t nat -A POSTROUTING -s $SUBNET_ADDR -o em1 -j SNAT --to-source $EXTERNAL_FIREWALL_IP
$FW_PROGRAM_DIR$FW_NAME -t nat -A PREROUTING -i em1 -j DNAT --to-destination 192.168.10.2

#Block external maliciousness
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -d $INTERNAL_FIREWALL_HOST -j DROP
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -s 192.168.10.0/24 -j DROP
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -p tcp -m multiport --dports 32768:32775,137:139,111,515 -j DROP

#Drop all TCP packets with the SYN and FIN bit set
$FW_PROGRAM_DIR$FW_NAME -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

#Create services and its join
$FW_PROGRAM_DIR$FW_NAME -N services
$FW_PROGRAM_DIR$FW_NAME -A INPUT -j services
$FW_PROGRAM_DIR$FW_NAME -A OUTPUT -j services

#Do not allow Telnet packets at all
$FW_PROGRAM_DIR$FW_NAME -A services -p tcp --dport 23 -j DROP
$FW_PROGRAM_DIR$FW_NAME -A services -p tcp --sport 23 -j DROP

#Inbound/Outbound TCP packets on allowed ports
$FW_PROGRAM_DIR$FW_NAME -A services -p tcp -m state --state ESTABLISHED,NEW -m multiport --dports $ALLOWED_TCP_PORTS -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A services -p tcp -m state --state ESTABLISHED,NEW -m multiport --sports $ALLOWED_TCP_PORTS -j ACCEPT 

#Inbound/Outbound UDP packets on allowed ports
$FW_PROGRAM_DIR$FW_NAME -A services -p udp -m state --state ESTABLISHED,NEW -m multiport --dports $ALLOWED_UDP_PORTS -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A services -p udp -m state --state ESTABLISHED,NEW -m multiport --sports $ALLOWED_UDP_PORTS -j ACCEPT

#Allow DHCP on all adapters
$FW_PROGRAM_DIR$FW_NAME -A INPUT -p udp -m state --state ESTABLISHED,NEW --sport 67:68 --dport 67:68 -j ACCEPT

#Allow DNS on all adapters
$FW_PROGRAM_DIR$FW_NAME -A OUTPUT -p udp -m state --state ESTABLISHED,NEW --dport 53 -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A OUTPUT -p tcp -m state --state ESTABLISHED,NEW --dport 53 -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A INPUT -p udp -m state --state ESTABLISHED,NEW --sport 53 -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A INPUT -p tcp -m state --state ESTABLISHED,NEW --sport 53 -j ACCEPT

#Inbound/Outbound ICMP packets based on type numbers
arr=$(echo $ALLOWED_ICMP_PACKET_TYPES | tr "," "\n")
for TYPE in $arr
	do $FW_PROGRAM_DIR$FW_NAME -A services -p icmp --icmp-type $TYPE -m state --state ESTABLISHED,NEW -j ACCEPT
done

#Accept fragments
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $EXTERNAL_INTERFACE -f -j ACCEPT
$FW_PROGRAM_DIR$FW_NAME -A INPUT -i $INTERNAL_INTERFACE -f -j ACCEPT

#Accept all TCP packets that belong to an existing connection(on allowed ports)

#Set control connections to Minimum delay for FTP and SSH services
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 21 -j TOS --set-tos Minimize-Delay
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 22 -j TOS --set-tos Minimize-Delay

#FTP data to maximum throughput
$FW_PROGRAM_DIR$FW_NAME -A PREROUTING -t mangle -p tcp --sport 20 -j TOS --set-tos Maximize-Throughput
