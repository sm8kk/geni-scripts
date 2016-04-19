The script is run using ./run-script.sh file.txt
file.txt contains the parameters to be changed and is arranged into columns as:
#tsoOn,mtuSz,bgUdpMaxRate,bgType,pcntLoss,rtt,htcpRate,tcpRmem,netDevLog,tcpWmem,txqlen

tsoOn: Whether TSO is on or off for the sending HTCP host (Host3)
mtuSz: Not implemented, but objective was to vary the MTU of the frame
bgUdpMaxRate: Is the maximum background UDP traffic generated from Host2 to Host4 in Mbps
bgType: background UDP traffic is generated according to, a. rate increasing, b. rate decreasing, c. rate following a random walk pattern
        (The script files for these different UDP background traffic generators are the udp... python files)
pcntLoss: Includes the loss percentage of the HTCP connection, yet to include that
rtt: Delay of the HTCP connection, represents half the path RTT
htcpRate: is the maximum rate of the htcp connection
tcpRmem: tcp-rmem value
netDevLog: netdev_max_backlog value
tcpWmem: tcp-wmem
txqlen: txqueuelen value
