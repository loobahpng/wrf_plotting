import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats
file = open("ctr_daily.txt", 'r')
content = file.read()
file.close()
Vartext=content.split('\n')
Vartext.pop()
numFils=len(Vartext)
Var=[]
for i in range(numFils):
	if Vartext[0]!="yyyy":
		Var.append(float(Vartext[0]))
	if Vartext[0]=="yyyy":
		Var=np.array(Var)
		xx,yy,zz=plt.hist(Var,bins=100,color='blue',log=True,cumulative=False,normed=True)
		#print(xx/numFils)
		for i in range(len(xx)-1):
		#	print(str(yy[i])+" to "+str(yy[i+1])+": "+str(xx[i]))
			if ((1-xx[i])-0.25)*((1-xx[i+1])-0.25)<0:
				print("more than "+str(yy[i+1])+" mm: "+str(1-xx[i]))
		Var=[]
	Vartext.pop(0)
plt.show()
plt.grid()
