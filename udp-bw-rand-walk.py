# bg traffic bandwidth decreases from a high to constant value
from __future__ import division
import random
import sys
import os
import math

#os.system("ls")

runTime = 71
maxRate = int(sys.argv[1]) #in Mbps
runNo = sys.argv[2]
minBw = 100 #in Mbps
bwInc = 30 #in Mbps
midBw = 450 #in Mbps
j=0
inc=3
bw = midBw
count=0

while j < runTime:
    toss = random.uniform(0,1)
    if(toss < 0.5):
        bw = bw - bwInc
    else:
        bw = bw + bwInc
    
    if bw < minBw:
        bw = minBw

    if bw > maxRate:
	bw = maxRate

    j = j + inc

    count = count + 1
    log = "echo Bandwidth: " + str(bw) + ", Count = " + str(j)
    #line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bw) + "M -p 5321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    #line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bw) + "M -p 5321 -t " + str(inc)
    if(count%2 == 0):
        line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bw) + "M -p 5321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    else:
	line = "iperf3 -c 10.10.1.4 -u -i 1 -b " + str(bw) + "M -p 6321 -t " + str(inc) + " >> /users/sm8kk/run-" + runNo + "-h2.txt"
    #os.system(log)
    #vary the bw for every 1 second time, linear decrease from maxRate to minBw
    os.system(line) #don't put it in bg, let it block the next iperf3 command
    #os.system("sleep 5s)
    #"iperf3 -c 10.10.1.4 -u -i 1 -b bw -p 5003 -t 1 >> $localDir/run-$runNo-h2.txt" #don't put it in bg, let it block the next iperf3 command
    
