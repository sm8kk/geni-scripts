# -*- coding: utf-8 -*-
"""
Created on Tue Jan 12 15:27:34 2016

@author: souravmaji
"""

from __future__ import division
import sys
import numpy as np

fruns=open(sys.argv[1], 'r')
runs=fruns.readlines()

runNo = 0
for l in runs:
    val = l.split(",")
    bgRate = int(val[2])
    bgType = int(val[3])
    loss = float(val[4])
    rtt = int(val[5])
    htcpRate = int(val[6])
    tcpRmem = float(val[7])
    netDevLog = float(val[8])
    tcpWmem = float(val[9])
    txqlen = float(val[10])
    tcpLimOpBy = float(val[11])
    runNo = runNo + 1
    print "Run Number: " + str(runNo)
    print "Maximum bg traffic rate: " + str(bgRate) + " Mbps"
    if(bgType == 1):
        print "bg traffic type: Decreasing rate"
    if(bgType == 2):
        print "bg traffic type: Increasing rate"
    if(bgType == 3):
        print "bg traffic type: Random-walk rate"
    if(bgType == 4):
        print "bg traffic type: Constant rate"

    print "Loss : " + str(loss) + "%"
    print "RTT :" + str(2*rtt) + "ms"
    print "Maximum htcp rate: " + str(htcpRate) + " Mbps"
    op = "tcp-wmem(" + str(tcpWmem/1000000) + ")--> txqueuelen(" + str(txqlen*1500/1000000) + ")--> tcp-limit-output-bytes(" + str(tcpLimOpBy/1000000) +\
         ")--> est-BDP(" + str(2*rtt*htcpRate/(8*1000)) + ")--> (LRO off)--> netdev_max_backlog(" + str(netDevLog*1500/1000000) + ")--> tcp-rmem(" + str(tcpRmem/1000000) + ") in MB\n"
    print op
    
