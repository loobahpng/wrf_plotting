import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys

output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr/wrfout_d02_1986-02-* |head -n 1"],shell=True, stdout=sys.PIPE).communicate()[0]
filenames=string.split(output, '\n')
filenames.pop()
Fil=nc.MFDataset(filenames)
print("===")
print(filenames)
print("Total files: "+str(len(filenames)))
############
output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d02_1986-02-* |head -n 1"],shell=True, stdout=sys.PIPE).communicate()[0]
filenames=string.split(output, '\n')
filenames.pop()
FilExp=nc.MFDataset(filenames)
print(filenames)
print("Total files: "+str(len(filenames)))
############
tmpString=[]
Var=[]
TimeString=[]
print("Time len: "+str(len(Fil.variables["Times"])))
Var=[]  
"""
[31 43 53 99]  [164 140 141  88] Var > 300
[31 35 43 44 53 85 89 98 99]   [164 163 140 140 141  96  94  83  88] Var > 250
[185,95] is Taoyuan in Wen-Hao's experiment
"""
xgrid=31
ygrid=164
print("===\n("+str(xgrid)+", "+str(ygrid)+")")
print("lat: "+str(Fil.variables["XLAT"][0,xgrid,ygrid])+", lon: "+str(Fil.variables["XLONG"][0,xgrid,ygrid]))
dSM1=FilExp.variables['SMOIS'][0,0,xgrid,ygrid]-Fil.variables['SMOIS'][0,0,xgrid,ygrid]
dSM2=FilExp.variables['SMOIS'][0,1,xgrid,ygrid]-Fil.variables['SMOIS'][0,1,xgrid,ygrid]
dSM3=FilExp.variables['SMOIS'][0,2,xgrid,ygrid]-Fil.variables['SMOIS'][0,2,xgrid,ygrid]
dSM4=FilExp.variables['SMOIS'][0,3,xgrid,ygrid]-Fil.variables['SMOIS'][0,3,xgrid,ygrid]
dSM1e=FilExp.variables['SMOIS'][36,0,xgrid,ygrid]-Fil.variables['SMOIS'][36,0,xgrid,ygrid]
dSM2e=FilExp.variables['SMOIS'][36,1,xgrid,ygrid]-Fil.variables['SMOIS'][36,1,xgrid,ygrid]
dSM3e=FilExp.variables['SMOIS'][36,2,xgrid,ygrid]-Fil.variables['SMOIS'][36,2,xgrid,ygrid]
dSM4e=FilExp.variables['SMOIS'][36,3,xgrid,ygrid]-Fil.variables['SMOIS'][36,3,xgrid,ygrid]
dUDROFF=FilExp.variables['UDROFF'][36,xgrid,ygrid]-Fil.variables['UDROFF'][36,xgrid,ygrid]
dSFROFF=FilExp.variables['SFROFF'][36,xgrid,ygrid]-Fil.variables['SFROFF'][36,xgrid,ygrid]
dPrec=FilExp.variables['RAINNC'][36,xgrid,ygrid]-Fil.variables['RAINNC'][36,xgrid,ygrid]
dET=FilExp.variables['ACLHF'][36,xgrid,ygrid]-Fil.variables['ACLHF'][36,xgrid,ygrid]
ET_ctr=Fil.variables['ACLHF'][36,xgrid,ygrid]

print("===\ndPrec (mm): "+str(dPrec))
print("I = Irrgation amount / soil moisture diff at 0th hr (mm): "+str((0.1*dSM1+0.3*dSM2+0.6*dSM3+1*dSM4)*1000))
print("dET (mm): "+str(dET/28.94/86400))
print("dSM = Soil moisture diff at 36th hr (mm): "+str((0.1*dSM1e+0.3*dSM2e+0.6*dSM3e+1*dSM4e)*1000))
print("dUDROFF (mm): "+str(dUDROFF))
print("dSFROFF (mm): "+str(dSFROFF))
residual=dPrec+(0.1*dSM1+0.3*dSM2+0.6*dSM3+1*dSM4)-dET/28.94/86400/1000-(0.1*dSM1e+0.3*dSM2e+0.6*dSM3e+1*dSM4e)-dUDROFF/1000-dSFROFF/1000#residual is in m
print("dPrec + I -dET - dSM- dUDROFF - dSFROFF = residual (mm): "+str(residual*1000))
print("===\nET_ctr (mm): "+str(ET_ctr/28.94/86400))
