# Have to define add-delay.sh and start-tcpdump.sh
fdt="sm8kk@fdt-uva.dynes.virginia.edu"
fdtDir="/home/sm8kk/pcaps-alpha-flow"
localDir="/users/sm8kk" #also change the local dir in python scripts
host1="sm8kk@pc21.utahddc.geniracks.net"
host2="sm8kk@pc16.utahddc.geniracks.net"
host3="sm8kk@pc19.utahddc.geniracks.net"
host4="sm8kk@pc32.utahddc.geniracks.net"
#ovs="sm8kk@pc63.uky.emulab.net"

paramFile=$1 #contains the different parameters in each line
wc_out=$(wc -l $paramFile)
length=($wc_out)
runNo=0

#make sure lro/gro is off at ovs and h4 to collect the pcap files
#host 4
#ssh $host4 "sudo ethtool -K eth1 lro off"
#ssh $host4 "sudo ethtool -K eth1 gro off"

#ovs
#ssh $ovs "sudo ethtool -K eth0 lro off"
#ssh $ovs "sudo ethtool -K eth0 gro off"
#For each runs use parameters from a csv file that are arranged as columns as given below:
#tsoOn,mtuSz,bgUdpMaxRate,bgType,pcntLoss,rtt,htcpRate,tcpRmem,netDevLog,tcpWmem,txqlen.
# not all the parameters can be fixed within the loop

echo Delete all older pcap and txt files
ssh $host1 "sudo rm *.txt"
ssh $host2 "sudo rm *.txt"
ssh $host3 "sudo rm *.txt"
ssh $host4 "sudo rm *.pcap"

echo "start udp(5321) and tcp(4321) iperf3 server at Host4"
#ssh $host4 "iperf3 -s -p 5321 -D"
#ssh $host4 "iperf3 -s -p 4321 -D"

for i in `seq 1 ${length[0]}`; do
    params=`head -$i file.txt | tail -1`
    IFS=',' read -a param <<< "$params"
    tsoOn=${param[0]}
    mtuSz=${param[1]}
    bgUdpMaxRate=${param[2]}
    bgType=${param[3]}
    pcntLoss=${param[4]}
    hfRtt=${param[5]}
    htcpRate=${param[6]}
    tcpRmem=${param[7]}
    netDevLog=${param[8]}
    tcpWmem=${param[9]}
    txqlen=${param[10]}
    tcpLimOpBy=${param[11]}

    runNo=$((runNo+1))

        
    echo Begin run $runNo
    echo "Host1: $host1"
    echo "Host2: $host2"
    echo "Host3: $host3"
    echo "Host4: $host4"

    echo "add delay to all the hosts"
    #Host1
    #echo "Add delay: $hfRtt to Host1"
    #ssh $host1 sh add-delay.sh $hfRtt

    #Host2
    #echo "Add delay: $hfRtt to Host2"
    #ssh $host2 sh add-delay.sh $hfRtt

    #Host3
    #Modify tcpWmem and txqlen, use a shell script
    echo "Change Host3 params, delay: $hfRtt, tcp-wmem: $tcpWmem, txqueuelen: $txqlen"
    ssh $host3 "sudo sh txlen-wmem.sh $tcpWmem $txqlen"
    ssh $host3 sh add-delay.sh $hfRtt
    loss=${pcntLoss}%
    echo "Add loss to Host3: $loss"
    ssh $host3 sh add-loss.sh $loss

    #Host4
    #Modify tcpRmem and netdev_max_backlog, use shell script
    echo "Change Host4 params, delay: $hfRtt, tcp-rmem: $tcpRmem, netdev_max_backlog: $netDevLog"
    ssh $host4 "sudo sh netdev-rmem.sh $tcpRmem $netDevLog"
    ssh $host4 sh add-delay.sh $hfRtt


    #give some time to ssh to the hosts and start tcpdump
    echo "start tcpdump at Host4"
    ssh $host4 sh start-tcpdump.sh $runNo &
    sleep 5

    #Host1
    echo "ping from Host1 to Host4"
    ssh $host1 "ping 10.10.1.4 -w 72 >> $localDir/run-$runNo-h1.txt" &
    #ssh $host1 ping 10.10.1.4 -w 72 &

    sleep 1

    echo "start udp test from Host2 to Host4, background test"
    #Host2
    #TODO: Add a time variant UDP flow
    # a. bgBw(time): high->low : 1, b. bgBw(time): low->high : 2, c. change bwBw(t secs, rand(0, bgUdpMaxRate)) : 3
    if [[ $bgType -eq 1 ]]; then
    echo "udp-bw-decreasing; maxrate: $bgUdpMaxRate Mbps"
    ssh $host2 python udp-bw-decreasing.py $bgUdpMaxRate $runNo &
    fi
    if [[ $bgType -eq 2 ]]; then
    echo "udp-bw-increasing; maxrate: $bgUdpMaxRate Mbps"
    ssh $host2 python udp-bw-increasing.py $bgUdpMaxRate $runNo &
    fi
    if [[ $bgType -eq 3 ]]; then
    echo "udp-bw-random-walk; maxrate: $bgUdpMaxRate Mbps"
    ssh $host2 python udp-bw-rand-walk.py $bgUdpMaxRate $runNo &
    fi
    if [[ $bgType -eq 4 ]]; then
    udpRate=${bgUdpMaxRate}M
    echo "udp-bw-constant; maxrate: $bgUdpMaxRate Mbps"
    ssh $host2 "iperf3 -c 10.10.1.4 -u -i 1 -b $udpRate -p 5321 -t 71 >> $localDir/run-$runNo-h2.txt" &
    fi

    sleep 2

    echo "start HTCP flow (alpha flow) from Host3 to Host4"
    echo "Change congestion control to HTCP at host3"
    ssh $host3  "sudo sh congestion-control.sh"
    #Host3
    #Turn on/off tso based on the value in tsoOn for the sending host

    if [[ $tsoOn -eq 1 ]]; then 
    echo "tso On"
    ssh $host3 "sudo ethtool -K eth1 tso on"
    ssh $host3 "sudo ethtool -K eth1 gso on"
    echo change the buffer size of tcp_limit_output_bytes
    ssh $host3 "sudo sh tcp-limit-output-bytes.sh $tcpLimOpBy"
    else 
    echo "tso Off"
    ssh $host3 "sudo ethtool -K eth1 tso off"
    ssh $host3 "sudo ethtool -K eth1 gso off"
    fi
    #host 3 send at the remaining bandwidth or try with max htcp rate
    echo "send htcp flow from Host3 to Host4, with maxrate $htcpRate Mbps"
    rate=${htcpRate}M
    ssh $host3 "iperf3 -c 10.10.1.4 -i 1 -b $rate -p 4321 -t 70 >> $localDir/run-$runNo-h3.txt" &

    echo "Sleep 70s"
    sleep 70

    echo "kill tcpdump at host 4"
    ssh $host4 "sudo killall tcpdump"
    
    echo "Sleep 2s"
    sleep 2

    echo "copy the result to my local machine from all hosts, and then to FDT"
    scp $host1:$localDir/run-$runNo-h1.txt .
    scp $host2:$localDir/run-$runNo-h2.txt .
    scp $host3:$localDir/run-$runNo-h3.txt .
    scp $host4:$localDir/run-$runNo-h4.pcap .

    scp run-$runNo-h1.txt $fdt:$fdtDir
    scp run-$runNo-h2.txt $fdt:$fdtDir
    scp run-$runNo-h3.txt $fdt:$fdtDir
    scp run-$runNo-h4.pcap $fdt:$fdtDir

    echo "delete the pcap and txt files from the hosts"
    ssh $host1 "sudo rm run-$runNo-h1.txt"
    ssh $host2 "sudo rm run-$runNo-h2.txt"
    ssh $host3 "sudo rm run-$runNo-h3.txt"
    ssh $host4 "sudo rm run-$runNo-h4.pcap"

    echo delete the pcap and txt files from the local machine
    rm run-$runNo-h1.txt
    rm run-$runNo-h2.txt
    rm run-$runNo-h3.txt
    rm run-$runNo-h4.pcap

    echo finish run $runNo
    echo ""

done
