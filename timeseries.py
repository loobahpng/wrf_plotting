"""
Plot underground runoff (UDROFF) and 4 layers of SMOIS (soil moisture) 
with different y-axis scale and legend
"""
import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys

output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d02_1986-04-* |head -n 1"],shell=True, stdout=sys.PIPE).communicate()[0]
filenames=string.split(output, '\n')
filenames.pop()
Fil=nc.MFDataset(filenames)
#####
output = sys.Popen(["ls /work/L.wenhao/WRF_paddy/WRFV3/run/wrfout_d03_2009-08-20_12:00:00_noah3"],shell=True, stdout=sys.PIPE).communicate()[0]
filenames=string.split(output, '\n')
filenames.pop()
FilTY=nc.MFDataset(filenames)
print(filenames)
print("Total files: "+str(len(filenames)))
tmpString=[]
Var=[]
TimeString=[]
print("Time len: "+str(len(Fil.variables["Times"])))
for i in range(len(Fil.variables["Times"])):
	tmpString.append("".join(Fil.variables["Times"][i,:]))
for i in range(len(filenames)):
#	Var.extend(Fil.variables['Var'][i*61+12:i*61+60,0,109,100]) # 60-hr run
	Var.extend(Fil.variables['SMOIS'][i*37+12:i*37+36,0,109,100])
	TimeString.extend(tmpString[i*37+12:i*37+36])
print("len after discarding spin-up: "+str(len(Var)))
Var=[]  
"""
[31 43 53 99]  [164 140 141  88] Var > 300
[31 35 43 44 53 85 89 98 99]   [164 163 140 140 141  96  94  83  88] Var > 250
[185,95] is Taoyuan in Wen-Hao's experiment
"""
xgrid=31
ygrid=164
print("lat: "+str(Fil.variables["XLAT"][0,xgrid,ygrid]))
print("lon: "+str(Fil.variables["XLONG"][0,xgrid,ygrid]))
#Var=Fil.variables['SFROFF'][:,109,100]
#plt.plot(Var,'-o')
#Var=Fil.variables['UDROFF'][1:,109,100]-Fil.variables['UDROFF'][:-1,109,100]
fig=plt.figure()
ax1=fig.add_subplot(111)
#Var=Fil.variables['UDROFF'][1:,xgrid,ygrid]-Fil.variables['UDROFF'][:-1,xgrid,ygrid] #UDROFF tendency
#Var=Fil.variables['UDROFF'][:,xgrid,ygrid] #UDROFF is accumulated
Var=Fil.variables['ACLHF'][:,xgrid,ygrid]/28.94/86400 #UDROFF is accumulated

#Var=Fil.variables["UDROFF"][:,xgrid,ygrid]
#for i in range(6):
#	Var=np.insert(Var,0,float('nan'))
ax1.plot(Var,'-ko')
#xgrid=185
#ygrid=95
#Var=FilTY.variables["SMOIS"][:,0,xgrid,ygrid]
#ax1.plot(Var,'-o')
fig.suptitle("("+str(xgrid)+", "+str(ygrid)+") 36hr simulation, spin-up included")
#fig.suptitle("Comparison of Taoyuan and Saudi 36hr simulation, spin-up included")
#ax1.set_xlabel('Local Time')
#ax1.ylabel('SMOIS (m3/m3)')
#ax1.set_ylabel('Underground Runoff (mm/hr)')
#ax1.set_ylabel("SMOIS (m3/m3)")
#ax1.legend(["Saudi","Taoyuan"],loc='upper right')

ax2=plt.twinx()
for i in range(4):
	ax2.plot(Fil.variables["SMOIS"][:,i,xgrid,ygrid],'-o')
ax2.set_ylabel('SMOIS (m3/m3)')
#ax1.legend(['Underground Runoff'],loc='upper left')
ax1.legend(['ET'],loc='upper left')
ax2.legend(['layer 1', 'layer 2', 'layer 3', 'layer 4'], loc='lower right')
#plt.legend(['Surface Runoff', 'Underground Runoff'], loc='lower right')
ax1.grid()
#ax1.set_ylim([0.,160.])
ax2.set_ylim([0.1,0.5])
ax1.set_xticks(range(0,49,3))
ax2.set_xticks(range(0,49,3))
timelabel=range(18,25)+range(1,25)+range(1,18)
ax1.set_xticklabels(timelabel[::3])
ax2.set_xticklabels(timelabel[::3])
plt.show()
