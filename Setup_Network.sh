PRIMARY_INTERFACE="em1"
SECONDARY_INTERFACE="p3p1"
SUBNET_ADDR="192.168.10.0/24"
EXTERNAL_FIREWALL_IP="192.168.0.9"

PS3='Is this Firewall Host or Internal Host(Enter number): '
select opt in Firewall Host Reset Exit
do
	case $opt in
		Host)
			ifconfig $PRIMARY_INTERFACE down
			ifconfig $SECONDARY_INTERFACE 192.168.10.2 up
			route add -net 192.168.10.0 gw $EXTERNAL_FIREWALL_IP netmask 255.255.255.0

			echo 'nameserver 8.8.8.8' > /etc/resolv.conf

			echo "Internal Host Setup complete."
			break
			;;

		Firewall)
			ifconfig $SECONDARY_INTERFACE 192.168.10.1 up
			echo "1" > /proc/sys/net/ipv4/ip_forward
			echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
			echo 'nameserver 8.8.8.8' > /etc/resolv.conf

			route add 192.168.10.0/24 gw 192.168.10.1
			route add default gw 192.168.0.100
			route add -net 192.168.0.0/24 gw 0.0.0.0
			
			echo "Firewall setup complete."
			echo "Deploying Firewall Rules.."
			chmod +x A2.sh
			./A2.sh
			break
			;;

		Test)
			route add default gw 192.168.10.1
			route add -net 192.168.10.0/24 gw 0.0.0.0
			break
			;;

		Reset)
			ifconfig $PRIMARY_INTERFACE up
			ifconfig $SECONDARY_INTERFACE down

			iptables -F
			iptables -t nat -F
			iptables -t mangle -F
			iptables -X 

			iptables -P INPUT ACCEPT
			iptables -P FORWARD ACCEPT
			iptables -P OUTPUT ACCEPT

			echo "Reset Complete."

			break
			;;

		Exit)
			echo "Exiting.."
			break
			;;

		*)
			echo "Invalid Option."

	esac
done
