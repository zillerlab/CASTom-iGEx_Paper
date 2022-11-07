#!/usr/bin/python
 
import sys
import os 
inFile=open(sys.argv[1]+'.gen','r').readlines()
outFile=open(sys.argv[1]+"_matrixeQTL.geno", 'w')
# outFile=open(outName,'w')
#outFile.writelines(inFile[0])
thres=0.1
for i in range(0,len(inFile)):
	line=inFile[i].strip()
	line=line.split()
	tmp=line[1]
	line=line[5:]
	for j in range(3,len(line)+3,3):
		p=(2*float(line[j-1])+float(line[j-2]))
		if (p<=thres):
			p=0
		tmp+="\t"+'%.2f'%p
	outFile.writelines(tmp+"\n")
outFile.close()

