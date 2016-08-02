load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

;fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d01*|tail -n 32|head -n 30")
;filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d01*|tail -n 32|head -n 30")
;198604 9km/3km d02
;=========================
total_all=0.
total_rainy=0.
do yy=1981,1999
	if yy.eq.1984 then
		continue
	end if
	fils=systemfunc ("ls /work3/L.r02229011/WRF/control_"+yy+"*/*|grep wrfout");-- -04-")
	filsExp=systemfunc ("ls /work3/L.r02229011/WRF/irr_"+yy+"*/*|grep wrfout");-- -04- ")
	
	in = addfiles(fils,"r")
	inExp = addfiles(filsExp,"r")
	ListSetType (in,"join")
	ListSetType (inExp,"join")
	numFILS=dimsizes(fils)
	iFilList=ispan(0,numFILS-1,1)
	rainy_days=0
	yearly_all=0.
	yearly_rainy=0.
	yearlyExp=0.
	do it=0,numFILS-1
		Var=wrf_user_getvar(in[iFilList(it)],"RAINNC",33)+wrf_user_getvar(in[iFilList(it)],"RAINC",33)\
			-wrf_user_getvar(in[iFilList(it)],"RAINNC",9)-wrf_user_getvar(in[iFilList(it)],"RAINC",9)
		VarExp=wrf_user_getvar(inExp[iFilList(it)],"RAINNC",33)+wrf_user_getvar(inExp[iFilList(it)],"RAINC",33)\
			-wrf_user_getvar(inExp[iFilList(it)],"RAINNC",9)-wrf_user_getvar(inExp[iFilList(it)],"RAINC",9)
		tmp=new((/99,99/),"float")
		tmp(:,:)=0.
		tmpExp=tmp
		do i=42,56
			do j=i-7,i+2
			if((j.ge.0).and.(j.le.98))then
				tmp(98-i,j)=Var(98-i,j)
				tmpExp(98-i,j)=VarExp(98-i,j)
			end if
			end do
		end do
		daily=dim_sum_n_Wrap(dim_sum_n_Wrap(tmp,0),0)/150.
		dailyExp=dim_sum_n_Wrap(dim_sum_n_Wrap(tmpExp,0),0)/150.
;		print("day "+it+": "+daily)
			yearly_all=yearly_all+daily
			yearlyExp=yearlyExp+dailyExp
		if daily.ge.3.81 then
			rainy_days=rainy_days+1
			yearly_rainy=yearly_rainy+daily
;				print(fils(it)+"")
		end if
;	print(""+daily)
	end do	
;	print(yy+" rainy days: "+rainy_days)
;	print(yy+" CTR rain on all days: "+(yearly_all))
;	print(yy+" CTR rain on rain days: "+(yearly_rainy))
	print(yy+"CTR rain on rain days/all rain: "+yearly_rainy/yearly_all)
;	print(yy+" CTR/days: "+(yearly/rainy_days))
	delete(fils)
	delete(filsExp)
	delete(iFilList)
		
	total_all=total_all+yearly_all
	total_rainy=total_rainy+yearly_rainy
end do
	print("total CTR rain on rain days/all rain: "+total_rainy/total_all)

end


