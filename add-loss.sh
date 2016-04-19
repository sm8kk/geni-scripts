#change the name of the interface based on each host
#you can inject loss and delay with one tc command as follows:
#sudo tc qdisc add dev eth1 root netem delay $1 loss $2
#note that losses should have %, e.g., sudo tc qdisc add dev eth1 root netem loss 0.1%
sudo tc qdisc del dev eth1 root
sudo tc qdisc add dev eth1 root netem loss $1

