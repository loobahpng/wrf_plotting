import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats
yearly=[]
yearlyExp=[]
for yy in range(1981,2000):
	if yy==1984:
		continue
	fils="ls /work3/L.r02229011/WRF/control_"+str(yy)+"*/*|grep wrfout"
	filsExp="ls /work3/L.r02229011/WRF/irr_"+str(yy)+"*/*|grep wrfout"
	print(str(yy))
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
	tmpString=[]
	Var=[]
	VarExp=[]
	TimeString=[]
	print("Time len: "+str(len(Fil.variables["Times"])))
	for i in range(len(Fil.variables["Times"])):
		tmpString.append("".join(Fil.variables["Times"][i,:]))

	ygrid=[]
	xgrid=[]
	for i in range(42,57):
	#	for j in range (i-2,i+3):
#		for j in range (i-7,i-2):
		for j in range (i-7,i+3):
			if((j>=0)and(j<=98)):
				ygrid.append(98-i)
				xgrid.append(j)
	for i in range(len(filenames)):
		Var.append(
				Fil.variables['RAINNC'][i*37+33,ygrid,xgrid]-
				Fil.variables['RAINNC'][i*37+9,ygrid,xgrid]+
				Fil.variables['RAINC'][i*37+33,ygrid,xgrid]-
				Fil.variables['RAINC'][i*37+9,ygrid,xgrid]
				)
		VarExp.append(
				FilExp.variables['RAINNC'][i*37+33,ygrid,xgrid]-
				FilExp.variables['RAINNC'][i*37+9,ygrid,xgrid]+
				FilExp.variables['RAINC'][i*37+33,ygrid,xgrid]-
				FilExp.variables['RAINC'][i*37+9,ygrid,xgrid]
				)
		TimeString.extend(tmpString[i*37+9:i*37+33])
	Var=np.array(Var)
	VarExp=np.array(VarExp)
	Var=np.average(Var,1)
	VarExp=np.average(VarExp,1)
	yearly.append(sum(Var))
	yearlyExp.append(sum(VarExp))

fig=plt.figure()
ax1=fig.add_subplot(111)
ax1.plot(yearly,'-ko')
ax1.plot(yearlyExp,'-bo')
#ax2=plt.twinx()
#ax2.plot(VarAno,'-ro')
#ax2.plot(VarAno*0,'r--')
#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
ax1.legend(['CTR', 'IRR'], loc='upper right')
#ax2.legend(['IRR-CTR'], loc='upper left')
ax1.grid()
ax1.set_ylabel('Precipitation (mm)')
#ax2.set_ylabel('Anomaly(mm)')
#ax2.set_ylim([-0.2,1.5])
ax1.set_xticks(range(0,18,2))
yy=[1981,1982,1983]
yy.extend(range(1985,2000))
ax1.set_xticklabels(yy[::2])
figname= (raw_input('figname? '))
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
