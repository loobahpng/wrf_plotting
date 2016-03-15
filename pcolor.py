import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys

#output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr/wrfout_d02_1986-02-* |head -n 2"],shell=True, stdout=sys.PIPE).communicate()[0]
output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_fixed_fixed/wrfout_d02_1986-02-* |head -n 2"],shell=True, stdout=sys.PIPE).communicate()[0]

filenames=string.split(output, '\n')  # --> ['Line 1', 'Line 2', 'Line 3']
#filname="/work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986/wrfout_d02_1986-02-*"
filenames.pop()
print(filenames)
print("Total files: "+str(len(filenames)))
Fil=nc.MFDataset(filenames)
#for v in Fil.variables: print(v)
TimesChar=Fil.variables['Times']
TimesString=[]
SMOIS=[]
#for i in range(61):
#	TimesString.append("".join(TimesChar[i,:]))
varname= (raw_input('Variable? '))
Var=Fil.variables[varname][36,:,:]
print("Valid time: "+"".join(Fil.variables["Times"][36,:]))

print("max: "+str(Var.max()))
print("min: "+str(Var.min()))
infposition=np.where(Var==Var.max())
print("equal to max: "+str(infposition))
print("number of points of inf: "+str(len(infposition[0]))+"\n===")

for i in range(len(infposition[0])):
	Var[infposition[0][i],infposition[1][i]]=float('nan')
Var = np.ma.array (Var, mask=np.isnan(Var))
print("max: "+str(Var.max()))
print("min: "+str(Var.min()))
infposition=np.where(Var==Var.max())
print("equal to max: "+str(infposition))
print("number of points of inf: "+str(len(infposition[0]))+"\n===")

infposition=[]
infposition=np.where(Var>250)
print("larger than 250: "+str(infposition))

infposition=[]
infposition=np.where(Var>150)
print("larger than 150: "+str(infposition))

plt.pcolormesh(Var,vmin=Var.min(), vmax=Var.max())
plt.colorbar()
#plt.show()

