import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats
file = open("temp.txt", 'r')
content = file.read()
file.close()
Var=content.split('\n')
Var.pop()
numFils=len(Var)
for i in range(numFils):
	Var.append(float(Var[0]))
	Var.pop(0)

Var=np.array(Var)
xx,yy,zz=plt.hist(Var,bins=1000,color='blue',cumulative=True,normed=True)
#print(xx/numFils)
for i in range(len(xx)):
#	print(str(yy[i])+" to "+str(yy[i+1])+": "+str(xx[i]))
	print("more than "+str(yy[i+1])+" mm: "+str(1-xx[i]))
plt.show()
