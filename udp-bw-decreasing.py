# bg traffic bandwidth decreases from a high to constant value
from __future__ import division
import sys
import os
import math

#os.system("ls")

runTime = 71
maxRate = int(sys.argv[1]) #in Mbps
runNo = sys.argv[2]
minBw = 100 #in Mbps
j=0
inc=3
count=0

while j < runTime:
    bw = maxRate * (1 - j/runTime)
    bwI = math.ceil(bw)
    if(bwI < minBw):
        bwI = minBw

    j = j + inc
    count = count + 1
    log = "echo Bandwidth: " + str(bwI) + ", Count = " + str(j)
    #line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bwI) + "M -p 5321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    if(count%2 == 0):
        line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bwI) + "M -p 5321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    else:
	line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bwI) + "M -p 6321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    #os.system(log)
    #vary the bw for every 1 second time, linear decrease from maxRate to minBw
    os.system(line) #don't put it in bg, let it block the next iperf3 command
    #os.system("sleep 5s)
    #"iperf3 -c 10.10.1.4 -u -i 1 -b bw -p 5003 -t 1 >> $localDir/run-$runNo-h2.txt" #don't put it in bg, let it block the next iperf3 command
    
