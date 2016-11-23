import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats

file = open("ctr_daily.txt", 'r')
content = file.read()
file.close()
file = open("irr_daily.txt", 'r')
contentExp = file.read()
file.close()
Vartext=content.split('\n')
Vartext.pop()
VartextExp=contentExp.split('\n')
VartextExp.pop()
numFils=len(Vartext)
Var=[]
VarExp=[]
for i in range(numFils):
		if float(Vartext[0])>-1:
			Var.append(float(Vartext[0]))
			VarExp.append(float(VartextExp[0]))
		Vartext.pop(0)
		VartextExp.pop(0)

print("##############")
print(np.var(Var))
print(np.var(VarExp))
F=(np.var(Var))/(np.var(VarExp))
p_value = stats.f.cdf(F, len(Var)-1, len(VarExp)-1)
print("p="+str(p_value))
print("##############")
#####################
xlabel=''
ylabel=''
#xlabel='Rainy days'
#ylabel='IRR-CTR (mm)'
#ylabel='CTR total rain on rainy days'
#xlabel='number of days with rain more than 0.56mm'
#xlabel='Averaged rain on rainy days (mm)'

Var=np.array(Var)
VarExp=np.array(VarExp)
print(Var.shape)

print("-------------")
print("(Pearson's correlation coefficient,  2-tailed p-value)")
corr,pvalue=(stats.pearsonr(Var,VarExp-Var))
print(stats.pearsonr(Var,VarExp-Var))
print("-------------")
figtitle='r= '+str(corr)+', p-value= '+str(pvalue)+', N='+str(len(Var))


fig=plt.figure(figsize=(16, 6))
ax1=fig.add_subplot(111)
#ax1.plot(Var, VarExp-Var, 'o',markersize=3)
ax1.plot(Var,'-b')
ax1.plot(Var*0+2.21452844352,'--b')
ax2=plt.twinx()
ax2.plot(VarExp-Var,'-r')
ax2.plot(VarExp*0,'--r')
ax1.set_xlim([0,1800])
#ax1.set_ylim([0,20])
#ax2.set_ylim([-0.5,2])


#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
ax1.grid()
ax1.set_xlabel(xlabel)
ax1.set_ylabel(ylabel)
fig.suptitle(figtitle)
#ax1.set_xscale('log')
#ax1.set_xlim([0,1])
#ax1.set_ylim([-2,2])

figname= (raw_input('figname? '))
#figname="rainy_day_precipAno"
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
