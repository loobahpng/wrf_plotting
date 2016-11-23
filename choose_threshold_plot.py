import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc
import string
import subprocess as sys
from scipy import stats

##########
yearly=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,25]
r_num_days=[0.80067918565262663,0.89867441561618255,0.92102884672854601,0.91722037893784703,0.94402064322226076,0.93135949325273926,0.9342796225611808,0.91010345763646194,0.88731592951359128,0.85068903757247416,0.83933601573919514,0.83355390592688006,0.82368290201776961,0.80294685204816851,0.81328046320383041,0.76828358671111108,0.72649384306455589]
ratio=[0.237623,0.370148,0.468613,0.541172,0.600412,0.648096,0.689424,0.721601,0.751172,0.776743,0.800993,0.821231,0.83934,0.855219,0.869225, 0.924651,0.957773]

r_num_days=np.array(r_num_days)
ratio=np.array(ratio)
r_square=r_num_days*r_num_days
explain_index=(r_square*ratio)

r_intensity=[0.39449479055162473,0.54350847677529202,0.58981438161099964,0.69760840579918992,0.83637840110217598]

#####################
xlabel=''
ylabel=''
#xlabel='Rainy days'
#ylabel='IRR-CTR (mm)'
#ylabel='CTR total rain on rainy days'
#xlabel='number of days with rain more than 0.56mm'
#xlabel='Averaged rain on rainy days (mm)'

#print("-------------")
#print("(Pearson's correlation coefficient,  2-tailed p-value)")
#corr,pvalue=(stats.pearsonr(Var,VarExp))
#print(stats.pearsonr(Var,VarExp))
#print("-------------")
#figtitle='r= '+str(corr)+', p-value= '+str(pvalue)

r_num_days=np.array(r_num_days)
r_intensity=np.array(r_intensity)
print(r_num_days.shape)

fig=plt.figure()
ax1=fig.add_subplot(111)
ax1.plot(yearly,r_square, '-bo')
#ax1.plot(yearly,r_intensity, '-go')
ax1.plot(yearly,ratio, '-ro')
#ax1.plot(yearly,explain_index, '-go')

#fig.suptitle("("+str(ygrid)+", "+str(xgrid)+") Precipitation")
ax1.grid()
ax1.set_xlabel(xlabel)
ax1.set_ylabel(ylabel)
fig.suptitle("choose threshold")
ax1.legend(["r square (num of days)","ratio"],loc='lower right')

for i, txt in enumerate(yearly):
    ax1.annotate(txt, (yearly[i],r_square[i]))
    ax1.annotate(txt, (yearly[i],ratio[i]))

figname= (raw_input('figname? '))
#figname="rainy_day_precipAno"
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
