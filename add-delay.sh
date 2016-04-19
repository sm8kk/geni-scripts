#change the name of the interface based on each host
sudo tc qdisc del dev eth1 root
sudo tc qdisc add dev eth1 root netem delay $1
