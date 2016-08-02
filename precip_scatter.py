import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats


fils="ls /work3/L.r02229011/WRF/control_*/*|grep wrfout"
filsExp="ls /work3/L.r02229011/WRF/irr_*/*|grep wrfout"
#04 27-km


output = sys.Popen([fils],shell=True, stdout=sys.PIPE).communicate()[0]
outputExp = sys.Popen([filsExp],shell=True, stdout=sys.PIPE).communicate()[0]
#####
filenames=string.split(output, '\n')
filenames.pop()
Fil=nc.MFDataset(filenames)
filenamesExp=string.split(outputExp, '\n')
filenamesExp.pop()
FilExp=nc.MFDataset(filenamesExp)
###
print(filenames)
print("Total files: "+str(len(filenames)))
Var=[]
VarExp=[]
print("Time len: "+str(len(Fil.variables["Times"])))
##########
ygrid=[]
xgrid=[]
for i in range(42,57):
	for j in range (i-2,i+3):
#	for j in range (i-7,i-2):
		if((j>=0)and(j<=98)):
			ygrid.append(98-i)
			xgrid.append(j)
print(str(ygrid)+","+str(xgrid))
############
#ygrid=range(42,57)
#xgrid=range(40,59)
#print(str(ygrid)+","+str(xgrid))
# 27km irigated region

#ygrid=range(39,63)
#xgrid=range(39,63)
# 27km cover whole d02 domain


#ygrid=range(116,187)
#xgrid=range(117,188)
# 9km/3km d01 but cover d02

#ygrid=range(119,146)
#xgrid=range(139,180)
#ygrid=range(27,66)
#xgrid=range(139,230)

#ygrid=range(210)
#xgrid=range(210)
# 9km/3km whole d02 domain
for i in range(len(filenames)):
	Var.append(
			Fil.variables['RAINNC'][i*37+36,ygrid,xgrid]-
			Fil.variables['RAINNC'][i*37+12,ygrid,xgrid]+
			Fil.variables['RAINC'][i*37+36,ygrid,xgrid]-
			Fil.variables['RAINC'][i*37+12,ygrid,xgrid]
			)
	VarExp.append(
			FilExp.variables['RAINNC'][i*37+36,ygrid,xgrid]-
			FilExp.variables['RAINNC'][i*37+12,ygrid,xgrid]+
			FilExp.variables['RAINC'][i*37+36,ygrid,xgrid]-
			FilExp.variables['RAINC'][i*37+12,ygrid,xgrid]
			)
	print(i)
Var=np.array(Var)
VarExp=np.array(VarExp)
print("***")
print(Var.shape)
#Var=np.average(Var,1)
Var=np.average(Var,1)
print("***")
VarExp=np.average(VarExp,1)
VarAno=VarExp-Var
print("==")
print("monthly CTR: "+str(sum(Var)))
print("monthly Ano: "+str(sum(VarAno)))
print("==")
print("==")
print("len after discarding spin-up: "+str(len(Var)))
fig=plt.figure()
ax1=fig.add_subplot(111)
ax1.scatter(Var,VarExp-Var)
#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
ax1.grid()
ax1.set_xlabel('CTR (mm)')
ax1.set_ylabel('IRR-CTR (mm)')
#figname= (raw_input('figname? '))
figname="scatter_local_region"
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
#plt.show()
