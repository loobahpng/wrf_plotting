import numpy as np
import matplotlib.pyplot as plt
import csv
f = open('qaseem_1980_2012.csv', 'r')

def replace(l, X, Y):
  for i,v in enumerate(l):
     if v == X:
        l.pop(i)
        l.insert(i, Y)

for row in csv.reader(f):
	print(row)
	continue
f.close()
print("len of row: "+str(len(row)))
feb=(row[2:len(row):12])
mar=(row[3:len(row):12])
apr=(row[4:len(row):12])
may=(row[5:len(row):12])
replace(feb, '999', np.nan)
replace(feb, '-1', 0)
replace(mar, '999', np.nan)
replace(mar, '-1', 0)
replace(apr, '999', np.nan)
replace(apr, '-1', 0)
replace(may, '999', np.nan)
replace(may, '-1', 0)
feb=np.array([float(i) for i in feb])
mar=np.array([float(i) for i in mar])
apr=np.array([float(i) for i in apr])
may=np.array([float(i) for i in may])

FMAM=(feb+mar+apr+may)/4.0
print("len of FMAM: "+str(len(FMAM)))
#print(feb)
#print(mar)
#print(apr)
#print(may)

fig=plt.figure()
fig.suptitle(row[0])
ax1=fig.add_subplot(111)
ax1.plot(FMAM,'-ko')
#ax2.legend(['IRR-CTR'], loc='upper left')
ax1.set_xticks(range(0,len(FMAM),3))
ax1.set_xticklabels(range(1980,2013,3))
ax1.grid()
#ax2.set_ylabel('Anomaly(mm)')
#ax2.set_ylim([-0.2,1.5])
figname= (raw_input('figname? '))
if figname!="no":
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.png',bbox_inches=0)
	plt.savefig('/home/L.r02229011/wrf_fig/'+figname+'.pdf',bbox_inches=0)
plt.show()
