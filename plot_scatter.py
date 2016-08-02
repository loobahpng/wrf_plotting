import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats

##########
#number of rainy days 1mm 0.56mm 1.61mm 3.81mm:
#Var=[10,25,21,9,30,15,12,15,6,19,11,30,18,21,12,15,18,15]
#Var=[17,30,28,17,35,25,19,19,17,23,16,37,28,32,19,18,27,24]
#Var=[8,21,14,5,19,11,9,13,4,16,8,24,11,20,9,8,13,5]
VarExp=[6,15,5,2,8,5,5,6,2,8,4,16,2,11,5,3,5,2]


#IRR-CTR total rain:
#VarExp=[3.66595,9.54423,3.61781,1.33933,5.20378,4.59239,3.58113,3.97916,1.48132,2.36922,-1.54355,6.38017,2.74884,4.51502,2.58834,3.84946,0.74498,2.98459]
######################
Var=[1981,1982,1983,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999]

#averaged rain on rainy days 1mm 3.81mm: 
#Var=[6.31831,4.42371,3.74441,2.82554,3.63202,5.06489,3.46659,4.7434,2.95626,4.00963,3.87745,6.07301,2.2442,5.26602,4.56942,3.44118,3.57968,2.24567]
#Var=[9.2263,6.16661,9.66742,6.86782,8.25808,10.9247,5.71568,8.47335,4.91363,6.76367,7.47127,9.7204,4.58955,8.04943,8.09372,9.65547,7.49534,7.43926]

#CTR total rain on rainy days 1mm 3.81mm:
#VarExp=[63.1831,110.593,78.6326,25.4299,108.961,75.9733,41.5991,71.151,17.7375,76.183,42.652,182.19,40.3956,110.586,54.833,51.6177,64.4342,33.685]
#VarExp=[55.3578,92.4991,48.3371,13.7356,66.0646,54.6234,28.5784,50.8401,9.82727,54.1093,29.8851,155.526,9.17909,88.5437,40.4686,28.9664,37.4767,14.8785]

#CTR total rain:
#VarExp=[72.8316,121.927,89.2799,37.5942,118.347,92.0333,52.6218,81.3161,33.5548,84.8699,53.5649,193.992,53.4077,126.963,67.9005,58.6324,73.8284,47.4056]

#####################
xlabel=''
ylabel=''
#xlabel='Rainy days'
#ylabel='IRR-CTR (mm)'
#ylabel='CTR total rain on rainy days'
#xlabel='number of days with rain more than 0.56mm'
#xlabel='Averaged rain on rainy days (mm)'

print("-------------")
print("(Pearson's correlation coefficient,  2-tailed p-value)")
corr,pvalue=(stats.pearsonr(Var,VarExp))
print(stats.pearsonr(Var,VarExp))
print("-------------")
figtitle='r= '+str(corr)+', p-value= '+str(pvalue)

Var=np.array(Var)
VarExp=np.array(VarExp)
print(Var.shape)

fig=plt.figure()
ax1=fig.add_subplot(111)
ax1.scatter(Var,VarExp)
#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
ax1.grid()
ax1.set_xlabel(xlabel)
ax1.set_ylabel(ylabel)
fig.suptitle(figtitle)

figname= (raw_input('figname? '))
#figname="rainy_day_precipAno"
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
