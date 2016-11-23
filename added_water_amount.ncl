load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

ensmean=1

if ensmean.eq.1 then
;	fils=systemfunc ("ls /work3/L.r02229011/WRF/control_ensmean_1981_2010.nc")
;	filsExp=systemfunc ("ls /work3/L.r02229011/WRF/irr_ensmean_1981_2010.nc")

    filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/irr_2010_half.nc")
    filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/irr_2010_75.nc")
    fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/ctr_2010.nc")

end if
	
	in = addfiles(fils,"r")
	inExp = addfiles(filsExp,"r")
	ListSetType (in,"join")
	ListSetType (inExp,"join")
	Var=wrf_user_getvar(in[:],"SMOIS",-1)
	VarExp=wrf_user_getvar(inExp[:],"SMOIS",-1)
		tmp=new((/99,99/),"float")
		tmp(:,:)=0.
		tmpExp=tmp
		do i=42,56
			do j=i-2,i+2	;-7 -2 +2
			if((j.ge.0).and.(j.le.98))then
				tmp(98-i,j)=Var(0,0,98-i,j)
				tmpExp(98-i,j)=VarExp(0,0,98-i,j)
			end if
			end do
		end do
		daily=dim_sum_n_Wrap(dim_sum_n_Wrap(tmp,0),0)/75.  ;/150 /75
		dailyExp=dim_sum_n_Wrap(dim_sum_n_Wrap(tmpExp,0),0)/75.
;		print(""+daily)
		print (""+daily)
		print(""+dailyExp)
;		print((dailyExp-daily)/28.94/86400)
;		print((dailyExp-daily)/86400)
		print((dailyExp-daily)*100)
end


