#!/usr/bin/env python
# Copyright (C) 2012 Freescale Semiconductor, Inc. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#
# Revision History:
#                          Modification     Tracking
# Author                       Date          Number    Description of Changes
#-----------------------   ------------    ----------  ---------------------
# Andy Tian                 05/08/2012       n/a        Initial ver.
#

'''
Function: abstract the skip timeout and failed cases;
          sort the auto test output to three types;
            1, failed case
            2, timeout case
            3, potential error case: success case but having error information (in plan)
Usage:
        aRsult.py caseSet result ouput
Input:
        The input is the case set, result and output file of auto test
Output:
        The output is a html file named with the output file of the auto test cycle.
        The format for the html file is:
            Title part:
                list all the cases under the type
            log part:
                each log owns its seperated space, we can quick get the log of one case just by click the case number in Title part
'''

import os
import sys

caseSet=sys.argv[1]
resFile=sys.argv[2]
outFile=sys.argv[3]
htmlFile=outFile+".html"

reFp=open(resFile,'r')
outFp=open(outFile,'r')
htmlFp=open(htmlFile,'w')
caseFp=open(caseSet, 'r')

#set up the caseset list from caseSet file
caseList=[]
for line in caseFp:
    if 'TGE-LV-' in line:
        caseList.append(line)


#deal with the resultFile including:
#delete 'Test Start Time' line
#delete ' --------' line
#delete 'Testcase' line
#ignore all lines after 'Total Tests: '

timeoutList=[]
missList=[]
errorList=[]
preLine=''
endLineHead=''
preLineHead=''
startIndex=0
bIndex=0
eIndex=0

for line in reFp:
    #deal with 'Test Start Time' line and find out the missing cases
    if 'Test Start Time:' in line:
        if 'TGE-' in preLine:
            preLineHead=preLine.split()[0]

    #deal with the missing cases
    if ' ------ ' in line:
        if preLineHead != '':
            try:
                line=reFp.next()
                endLineHead=line.split()[0]
            except StopIteration:
                break
            for i in range(startIndex,len(caseList)):
                if preLineHead in caseList[i]:
                    bIndex=i
                if endLineHead in caseList[i]:
                    eIndex=i
                    break
            missList.extend(caseList[bIndex+1:eIndex])
            startIndex=eIndex
            bIndex,eIndex=0,0

    #deal with the timeout case
    if ' TIMEOUT ' in line:
        head=line.split()[0]
        for i in range(startIndex, len(caseList)):
            if head in caseList[i]:
                tid, cmd=caseList[i].split(None, 1)
                if tid.rstrip("_LHU") != tid:
                    #case already have long running tag
                    newline=tid+'HH'+'    '+cmd
                else:
                    newline=tid+'_HH'+'    '+cmd
                timeoutList.append(newline)
                startIndex=i
                break

    #deal with the error case
    if ' FAIL ' in line:
        head=line.split()[0]
        for i in range(startIndex,len(caseList)):
            if head in caseList[i]:
                errorList.append(caseList[i])
                startIndex=i
                break
    preLine=line

#add tags in re-run list
missList.insert(0,"skipped cases: \n")
timeoutList.insert(0,"\nTimeout cases: \n")
errorList.insert(0,"\nFailed cases: \n")

#generate the re-run test case string
allList=missList+timeoutList+errorList
reRunStr=""
for i in allList:
    reRunStr+=i

caseFp.close()


failDic={}
timeoutDic={}
passDic={}

def singleLog(line, fp):
    '''
    abstract a single case log from fp
    '''
    match=0
    while line:
        if 'TGE-LV' in line:
            #abstract the TID
            #****maybe need change here for Hake already remove the _L and _H tag in output file****
            #****but in output file, it maybe still existing****
            orgTid=line.split()[0].split('=')[1]
            tid=orgTid.rstrip("_LHU")
        #    match=1
        #if "<test_output>" in line and match==1:
            #beginning of the single log
            log=80*'-'+'\n'
            while "<test_start>" not in line:
                log+=line
                line=fp.next()
            log += 80*'-'
         #   log += '<br>'
            return tid, log
        line=fp.next()

def htmlGen(fp1, fp2, tid, log):
    tempTid='''
        <p>
            <a href="#%(TID)s">%(TID)s</a>
        </p>
        '''
    tempLog='''
        <p>
            <a name="%(TID)s">%(TID)s</a>
        </p>
        <xmp>%(LOG)s</xmp>
        <p>
            <a href="#TOP">Return Top</a>
        </p>

        '''
    data1={"TID":tid}
    data2={"TID":tid,"LOG":log}
    fp1.write(tempTid % data1)
    fp2.write(tempLog % data2)

#analyze the result file
reFp.seek(0)
for line in reFp:
    if "PASS" in line:
        passDic[line.split()[0]]=line
    elif "FAIL" in line:
        failDic[line.split()[0]]=line
    elif "TIMEOUT" in line:
        timeoutDic[line.split()[0]]=line
reFp.close()

#analyze the output file
'''
It is the difficult part. The output file is very large(about 10M size). We need go though it.
What I think it we can just go through it one time for efficience.
First we need a function to abstract the case id and its output, it works like:
    for line in outFp:
        try:
            caseID, log=singleLog(outFp)
            deal with caseID and log
        except StopIterator:
            break
'''

failFp1=open(  os.environ['HOME'] +  "/failTid",'w')
failFp2=open(  os.environ['HOME'] +  "/failLog",'w')
timeoutFp1=open(  os.environ['HOME'] +  "/toTid",'w')
timeoutFp2=open(  os.environ['HOME'] + "/toLog",'w')


for line in outFp:
    try:
        tid, log=singleLog(line, outFp)
        if tid in failDic:
            htmlGen(failFp1, failFp2, tid, log)
        if tid in timeoutDic:
            htmlGen(timeoutFp1, timeoutFp2, tid, log)
#        if tid in passDic:
#            htmlGen(ptFp1, ptFp2, tid, log)
    except StopIteration:
        break

failFp1.close()
failFp2.close()
timeoutFp1.close()
timeoutFp2.close()
failFp1=open( os.environ['HOME'] + "/failTid",'r')
failFp2=open( os.environ['HOME'] + "/failLog",'r')
timeoutFp1=open( os.environ['HOME'] +  "/toTid",'r')
timeoutFp2=open(  os.environ['HOME'] +  "/toLog",'r')

htmlFp.write("<html>\n")
topLink='''
    <p>
        <h1>
        <a name="TOP">Top Menu</a>
        </h1>
    </p>
    '''

menu='''
    <p>
        <a href="#rerun">Re-run List</a>
    </p>
    <p>
        <a href="#fail">Fail Case List</a>
    </p>
    <p>
        <a href="#timeout">TimeOut Case List</a>
    </p>
    '''

htmlFp.write(topLink)
htmlFp.write(menu)
failHead='''
    <head>
        <title>LOG analyzer</title>
        <h3><a name="fail">Failed Case</a></h3>
    </head>
    '''
htmlFp.write(failHead)

for line in failFp1:
    htmlFp.write(line)

timeoutHead='''
        <h3><a name="timeout">Timeout Case</a></h3>
    '''
htmlFp.write(timeoutHead)


for line in timeoutFp1:
    htmlFp.write(line)


rerun='''
    <p>
        <h3><a name="rerun">Re-run list</a></h3>
    </p>
    <xmp>%(rerunStr)s</xmp>
    <p>
        <a href="#TOP">Return Top</a>
    </p>

    '''
htmlFp.write(rerun % {"rerunStr":reRunStr})


for line in failFp2:
    htmlFp.write(line)

for line in timeoutFp2:
    htmlFp.write(line)
htmlFp.write("</html>\n")
failFp1.close()
failFp2.close()
timeoutFp1.close()
timeoutFp2.close()
htmlFp.close()
os.remove(os.environ['HOME'] + "/failTid")
os.remove(os.environ['HOME'] +  "/failLog")
os.remove(os.environ['HOME'] +  "/toTid")
os.remove(os.environ['HOME'] + "/toLog")

