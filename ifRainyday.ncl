load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

;fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d01*|tail -n 32|head -n 30")
;filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d01*|tail -n 32|head -n 30")
;198604 9km/3km d02
;=========================
total_all=0.
total_rainy=0.
totalExp_all=0.
totalExp_rainy=0.
do yy=1981,2010
	if yy.eq.1984 then
		continue
	end if
	fils=systemfunc ("ls /work3/L.r02229011/WRF/control_"+yy+"*/*|grep wrfout|grep -- -05-")
	filsExp=systemfunc ("ls /work3/L.r02229011/WRF/irr_"+yy+"*/*|grep wrfout|grep -- -05-")
	
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
	yearlyExp_rainy=0.
	do it=0,numFILS-1
		Var=wrf_user_getvar(in[iFilList(it)],"RAINNC",33)+wrf_user_getvar(in[iFilList(it)],"RAINC",33)\
			-wrf_user_getvar(in[iFilList(it)],"RAINNC",9)-wrf_user_getvar(in[iFilList(it)],"RAINC",9)
		VarExp=wrf_user_getvar(inExp[iFilList(it)],"RAINNC",33)+wrf_user_getvar(inExp[iFilList(it)],"RAINC",33)\
			-wrf_user_getvar(inExp[iFilList(it)],"RAINNC",9)-wrf_user_getvar(inExp[iFilList(it)],"RAINC",9)
		tmp=new((/99,99/),"float")
		tmp(:,:)=0.
		tmpExp=tmp
		do i=42,56
			do j=i-7,i+2	;-7 -2 +2
			if((j.ge.0).and.(j.le.98))then
				tmp(98-i,j)=Var(98-i,j)
				tmpExp(98-i,j)=VarExp(98-i,j)
			end if
			end do
		end do
		daily=dim_sum_n_Wrap(dim_sum_n_Wrap(tmp,0),0)/150.  ;/150 /75
		dailyExp=dim_sum_n_Wrap(dim_sum_n_Wrap(tmpExp,0),0)/150.
;		print(""+daily)
			yearly_all=yearly_all+daily
			yearlyExp=yearlyExp+dailyExp
		;9.42530580889  0.01
		;6.88688901876  0.02
		;4.93581042366  0.03
		;3.87426249861  0.04
		;3.11955616357  0.05
		;2.63294879355  0.06
		;2.21452844352  0.07
		;1.86739452351  0.08
		;1.6550849385   0.09
		;1.47531915849  0.10
		;1.28780485348  0.11
		;1.12973494347  0.12
		;1.00885795346  0.13
		;0.898828898457 0.14
		;0.827542468453 0.15
		;0.506753533437 0.20
		;0.313040408427 0.25
		if daily.gt. 2.21452844352 then 
			rainy_days=rainy_days+1
			yearly_rainy=yearly_rainy+daily
			yearlyExp_rainy=yearlyExp_rainy+dailyExp
;				print(fils(it)+"")
;			print(""+dailyExp)
		end if
;	print(""+dailyExp)
	end do	
;	print("yyyy")
;	print(yy+" rainy days: "+rainy_days)
;	print(yy+" CTR rain on all days: "+(yearly_all))
	print(yy+" IRR rain on all days: "+(yearlyExp))
;	print(yy+" IRR-CTR rain on all days: "+(yearlyExp-yearly_all))
;	print(yy+" IRR-CTR rain on rainy days: "+(yearlyExp_rainy-yearly_rainy))
;	print(yy+" CTR rain on rain days: "+(yearly_rainy))
;	if rainy_days.ne.0 then
;		print(yy+" CTR rain intensity of rain days: "+(yearly_rainy/rainy_days))
;	end if
;	print(yy+"CTR rain on rain days/all rain: "+yearly_rainy/yearly_all)
;	print(yy+" CTR/days: "+(yearly/rainy_days))
	delete(fils)
	delete(filsExp)
	delete(iFilList)
		
	total_all=total_all+yearly_all
	total_rainy=total_rainy+yearly_rainy
	totalExp_all=totalExp_all+yearlyExp
	totalExp_rainy=totalExp_rainy+yearlyExp_rainy
end do
	print("total CTR rain on rain days/all rain: "+total_rainy/total_all)
;	print("total IRR-CTR rain on rain days/IRR-CTR all rain: "+((totalExp_rainy-total_rainy)/(totalExp_all-total_all)))

end


