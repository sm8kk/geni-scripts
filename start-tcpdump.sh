#change the interface name
#you can change the IP addresss based on the flows you want to capture,
#we are capturing flows from all IP addresses at host4 interface eth1
sudo tcpdump -B 4096 -i eth1 src 10.10.1.1 or src 10.10.1.2 or src 10.10.1.3 -s 74 -w run-$1.pcap
