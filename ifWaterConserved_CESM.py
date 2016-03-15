import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
proc1 = sys.Popen(["ls /work3/mlo/cesm1/archive/F2000_CAM5/lnd/hist/*.nc |head -n 2"],shell=True, stdout=sys.PIPE)
output=proc1.communicate()[0]
filenames=string.split(output, '\n')
filenames.pop()
Fil=nc.MFDataset(filenames)
print("===")
print(filenames)
print("Total files: "+str(len(filenames)))
############
#output = sys.Popen(["ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_fixed_fixed/wrfout_d02_1986-02-* |head -n 1"],shell=True, stdout=sys.PIPE).communicate()[0]
#filenames=string.split(output, '\n')
#filenames.pop()
#FilExp=nc.MFDataset(filenames)
#print(filenames)
#print("Total files: "+str(len(filenames)))
############
tmpString=[]
Var=[]
TimeString=[]
Var=[]  
xgrid=140
ygrid=100
print("===\n("+str(xgrid)+", "+str(ygrid)+")")
print("lat: "+str(Fil.variables["lat"][xgrid])+", lon: "+str(Fil.variables["lon"][ygrid]))
QOVER=Fil.variables['QOVER'][0,xgrid,ygrid]*86400.
QRUNOFF=Fil.variables['QRUNOFF'][0,xgrid,ygrid]*86400.
QDRAI=Fil.variables['QDRAI'][0,xgrid,ygrid]*86400.
RAIN=Fil.variables["RAIN"][0,xgrid,ygrid]*86400.
SNOW=Fil.variables["SNOW"][0,xgrid,ygrid]*86400.
RAINATM=Fil.variables["RAINATM"][0,xgrid,ygrid]*86400.
SNOWATM=Fil.variables["SNOWATM"][0,xgrid,ygrid]*86400.
WT=Fil.variables["WT"][0,xgrid,ygrid]
QSOIL=Fil.variables["QSOIL"][0,xgrid,ygrid]*86400.
QVEGE=Fil.variables["QVEGE"][0,xgrid,ygrid]*86400.
QVEGT=Fil.variables["QVEGT"][0,xgrid,ygrid]*86400.
QINFL=Fil.variables["QINFL"][0,xgrid,ygrid]*86400.
QDRIP=Fil.variables["QDRIP"][0,xgrid,ygrid]*86400.
QINTR=Fil.variables["QINTR"][0,xgrid,ygrid]*86400.
H2OCAN=Fil.variables["H2OCAN"][0,xgrid,ygrid]
H2OCAN2=Fil.variables["H2OCAN"][1,xgrid,ygrid]


print("WT (mm)"+str(WT))
print("H2OCAN  (mm)"+str(H2OCAN))
print("H2OCAN2 (mm)"+str(H2OCAN2))
print("H2OCAN diff: "+str(H2OCAN2-H2OCAN))
print("interception-VegEvap *30 days: "+str((QINTR-QVEGE)*30))
print("===")
print("RAIN  (mm/day): "+str(RAIN))
print("SNOW  (mm/day): "+str(SNOW))
print("QSOIL (mm/day): "+str(QSOIL))
print("QVEGE (mm/day): "+str(QVEGE))
print("QVEGT (mm/day): "+str(QVEGT))
print("QRUNOFF (mm/day): "+str(QRUNOFF))
print("QOVER (mm/day): "+str(QOVER))
print("QDRAI (mm/day): "+str(QDRAI))
print("QINFL infiltration(mm/day): "+str(QINFL))
print("QDRIP throughfall(mm/day): "+str(QDRIP))
print("QINTR interception(mm/day): "+str(QINTR))
print("(snow+rain)-(throughfall+interception): "+str(SNOW+RAIN-QDRIP-QINTR))
"""
QRUNOFF:long_name = "total liquid runoff (does not include QSNWCPICE)" ;
QOVER:long_name = "surface runoff" ;
QDRAI:long_name = "sub-surface drainage" ;
QSOIL:long_name = "ground evaporation" ;
QVEGE:long_name = "canopy evaporation" ;
QVEGT:long_name = "canopy transpiration" ;
RAIN:long_name = "atmospheric rain" ;
H2OSOI:long_name = "volumetric soil water" ;
H2OCAN:long_name = "intercepted water" ;
WT:long_name = "total water storage (unsaturated soil water + groundwater)" ;
QDRIP:long_name = "throughfall" ;
QINTR:long_name = "interception" ;
QINFL:long_name = "infiltration" ;
"""
