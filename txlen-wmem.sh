echo $1 $1 $1 > /proc/sys/net/ipv4/tcp_wmem
ifconfig eth1 txqueuelen $2
