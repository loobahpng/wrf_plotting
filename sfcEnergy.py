import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys

fils="ls /work3/L.r02229011/WRF/control_1986*/*|grep \"\\-04\\-10\""
filsExp="ls /work3/L.r02229011/WRF/irr_1986*/*|grep \"\\-04\\-10\""
print(fils)
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
ygrid=55
xgrid=41
#xgrid=(raw_input('xgrid? '))
#ygrid=(raw_input('ygrid? '))

print("===\n("+str(ygrid)+", "+str(xgrid)+")")
print("lat: "+str(Fil.variables["XLAT"][0,xgrid,ygrid])+", lon: "+str(Fil.variables["XLONG"][0,xgrid,ygrid]))
fig=plt.figure()
ax1=fig.add_subplot(111)

varlist=['SWDOWN','GLW','HFX','LH']
#varlist=['T2']
for i in range(len(varlist)):
	Var=FilExp.variables[varlist[i]][:,ygrid,xgrid]-Fil.variables[varlist[i]][:,ygrid,xgrid]
	ax1.plot(Var,'-o')
sigma=5.67*10**-8
Var=sigma*((FilExp.variables['TSK'][:,ygrid,xgrid])**4-(Fil.variables['TSK'][:,ygrid,xgrid])**4)
ax1.plot(Var,'-o')

#ax1.plot(yearlyExp,'-bo')
#ax2=plt.twinx()
#ax2.plot(VarAno,'-ro')
#ax2.plot(VarAno*0,'r--')
#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
varlist.append('LWup')
ax1.legend(varlist, loc='upper right')
#ax2.legend(['IRR-CTR'], loc='upper left')
ax1.grid()
#ax1.set_ylabel('Precipitation (mm)')
#ax2.set_ylabel('Anomaly(mm)')
#ax2.set_ylim([-0.2,1.5])
ax1.set_xticks(range(0,37,3))
timelabel=range(21,25)+range(1,25)+range(1,10)
ax1.set_xticklabels(timelabel[::3])
figname= (raw_input('figname? '))
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
