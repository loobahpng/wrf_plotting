load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/L.r02229011/wrf_plotting/WRFUserARW.ncl"
begin
;plotres="9km3km"
plotres="27km"

ensmean=1

if ensmean .eq.0 then
	fils=systemfunc("ls /work3/L.r02229011/WRF/control_1986*/*|grep "+quote+"\-03\-10"+quote)
	filsExp=systemfunc("ls /work3/L.r02229011/WRF/irr_1986*/*|grep "+quote+"\-03\-10"+quote)
end if
if ensmean.eq.1 then
	fils=systemfunc ("ls /work3/L.r02229011/WRF/control_ensmean_1981_2010.nc")
	filsExp=systemfunc ("ls /work3/L.r02229011/WRF/irr_ensmean_1981_2010.nc")
;	filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/irr_2010_half.nc")
	fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/ctr_2010.nc")
	filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/saudi/irr_2010_75.nc")

end if

;plotwhich="CTR"
plotwhich="IRR-CTR"
;varname="vec_pres"
;varname="slp"
;varname="precip"
;varname="T2"
;varname="ua"
varname="LH"
composite="all"
level=0


	numFILS=dimsizes(fils)
	print("number of files: "+numFILS)
	in = addfiles(fils,"r")  ; Open a file
	inExp = addfiles(filsExp,"r")  ; Open a file
	type = "png"
	res = True                           ; Set up some basic plot resources

	res@MainTitle = "Vector"
	res@Footer = False
	pltres = True
	mpres = True
    mpres@mpOutlineBoundarySets       = "National"
	mpres@mpNationalLineThicknessF=1.
    mpres@mpGeophysicalLineThicknessF =5.
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpGridLineColor = "Black"
	mpres@mpLimbLineColor = "Black"
	mpres@mpNationalLineColor = "Black"
	mpres@mpPerimLineColor = "Black"
	mpres@mpUSStateLineColor = "Black"
	
	diurnal=ispan(9,32,1)
	if composite.eq."event"then
		iFilList=(/3,5,12,14,17,18,23,24/)
	else if composite.eq."all"then
		iFilList=ispan(0,numFILS-1,1)
	end if	end if
	print("Working on iFilList 0")
	u10  = wrf_user_getvar(in[iFilList(0)],"U10",diurnal)    ; 3D U at mass points
	v10  = wrf_user_getvar(in[iFilList(0)],"V10",diurnal)    ; 3D V at mass points
	u10Exp  = wrf_user_getvar(inExp[iFilList(0)],"U10",diurnal)    ; 3D U at mass points
	v10Exp  = wrf_user_getvar(inExp[iFilList(0)],"V10",diurnal)    ; 3D V at mass points
	if ensmean.eq.1 then
		times = wrf_user_getvar(in[iFilList(0)],"Times",diurnal) 
	end if
	if ensmean.eq.0 then	
		times = wrf_user_getvar(in[iFilList(0)],"times",diurnal) 
	end if
	
	if varname.eq."cape_2d"then
		temp= wrf_user_getvar(in[iFilList(0)],varname,diurnal)
		temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
		Var=temp(0,:,:,:)
		temp = wrf_user_getvar(inExp[iFilList(0)],varname,diurnal)
		temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
		VarExp=temp(0,:,:,:)
	else if varname.eq."divergence"then
		all_lat = wrf_user_getvar(in,"lat",-1)
		all_lon = wrf_user_getvar(in,"lon",-1)
		lat = all_lat(0,:,0)
		lon = all_lon(0,0,:)
		conv = u10
		conv = uv2dv_cfd(u10,v10,lat,lon,2)
		Var = conv/1e-5
		conv=uv2dv_cfd(u10Exp,v10Exp,lat,lon,2)
		VarExp=conv/1e-5
	else if level.ne.0.and.varname.ne."vec_pres" then
		Var4d=wrf_user_getvar(in[iFilList(0)],varname,diurnal)
		print("Var4d ok")
		Var4d=wrf_user_getvar(in[iFilList(0)],varname,diurnal)
		print("Var4d ok")
		VarExp4d=wrf_user_getvar(inExp[iFilList(0)],varname,diurnal)
		print("VarExp4d ok")
		p=wrf_user_getvar(in[iFilList(0)],"pressure",diurnal)
		pExp=wrf_user_getvar(inExp[iFilList(0)],"pressure",diurnal)
		printVarSummary(Var4d)
		Var = wrf_user_intrp3d( Var4d,p,"h",level,0.,False)
		print("Var ok")
		delete(Var4d)
		VarExp = wrf_user_intrp3d( VarExp4d,pExp,"h",level,0.,False)
		print("VarExp ok")
		delete(VarExp4d)
	else if varname.eq."vec_pres"then
		u4d=wrf_user_getvar(in[iFilList(0)],"ua",diurnal)
		print("u4d ok")
		v4d=wrf_user_getvar(in[iFilList(0)],"va",diurnal)
		print("v4d ok")
		uExp4d=wrf_user_getvar(inExp[iFilList(0)],"ua",diurnal)
		print("uExp4d ok")
		vExp4d=wrf_user_getvar(inExp[iFilList(0)],"va",diurnal)
		print("vExp4d ok")
		p=wrf_user_getvar(in[iFilList(0)],"pressure",diurnal)
		pExp=wrf_user_getvar(inExp[iFilList(0)],"pressure",diurnal)
		u = wrf_user_intrp3d( u4d,p,"h",level,0.,False)
		print("u ok")
		delete(u4d)
		v = wrf_user_intrp3d( v4d,p,"h",level,0.,False)
		print("v ok")
		delete(v4d)
		uExp = wrf_user_intrp3d( uExp4d,pExp,"h",level,0.,False)
		print("uExp ok")
		delete(uExp4d)
		vExp = wrf_user_intrp3d( vExp4d,pExp,"h",level,0.,False)
		print("vExp ok")
		delete(vExp4d)

		all_lat = wrf_user_getvar(in,"lat",-1)
		all_lon = wrf_user_getvar(in,"lon",-1)
		if ensmean.eq.0 then
			lat = all_lat(0,:,0)
			lon = all_lon(0,0,:)
		end if
		if ensmean.eq.1 then
			lat = all_lat(:,0)
			lon = all_lon(0,:)
		end if
		conv = u
		conv = uv2dv_cfd(u,v,lat,lon,2)
		Var = conv/1e-5
		conv=uv2dv_cfd(uExp,vExp,lat,lon,2)
		VarExp=conv/1e-5
	else if varname.eq."precip"then
		Var=wrf_user_getvar(in[iFilList(0)],"RAINNC",diurnal+1)\
		+wrf_user_getvar(in[iFilList(0)],"RAINC",diurnal+1)\
		-wrf_user_getvar(in[iFilList(0)],"RAINNC",diurnal)\
		-wrf_user_getvar(in[iFilList(0)],"RAINC",diurnal)

		VarExp=wrf_user_getvar(inExp[iFilList(0)],"RAINNC",diurnal+1)\
		+wrf_user_getvar(inExp[iFilList(0)],"RAINC",diurnal+1)\
		-wrf_user_getvar(inExp[iFilList(0)],"RAINNC",diurnal)\
		-wrf_user_getvar(inExp[iFilList(0)],"RAINC",diurnal)
	else	
		Var=wrf_user_getvar(in[iFilList(0)],varname,diurnal)
		VarExp=wrf_user_getvar(inExp[iFilList(0)],varname,diurnal)
	end if	end if	end if	end if	end if
if( ensmean.eq.0 )then
	do iFil=1,dimsizes(iFilList)-1,1
		print("Working on iFilList "+iFil)
		if varname.eq."cape_2d"then
			temp= wrf_user_getvar(in[iFilList(iFil)],varname,diurnal)
			temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
			Var = Var+temp(0,:,:,:)
			temp= wrf_user_getvar(inExp[iFilList(iFil)],varname,diurnal)
			temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
			VarExp = VarExp+temp(0,:,:,:)
		else if varname.eq."divergence"then
			u10temp=wrf_user_getvar(in[iFilList(iFil)],"U10",diurnal)
			v10temp=wrf_user_getvar(in[iFilList(iFil)],"V10",diurnal)
	        conv = uv2dv_cfd(u10temp,v10temp,lat,lon,2)
	        Var = Var+conv/1e-5
			u10temp=wrf_user_getvar(inExp[iFilList(iFil)],"U10",diurnal)
			v10temp=wrf_user_getvar(inExp[iFilList(iFil)],"V10",diurnal)
	        conv=uv2dv_cfd(u10temp,v10temp,lat,lon,2)
	        VarExp=VarExp+conv/1e-5
		else if level.ne.0.and.varname.ne."vec_pres"then
			Var4d=wrf_user_getvar(in[iFilList(iFil)],varname,diurnal)
			print("Var4d ok")
			VarExp4d=wrf_user_getvar(inExp[iFilList(iFil)],varname,diurnal)
			print("VarExp4d ok")
			p=wrf_user_getvar(in[iFilList(iFil)],"pressure",diurnal)
			pExp=wrf_user_getvar(inExp[iFilList(iFil)],"pressure",diurnal)
			Var=Var+  wrf_user_intrp3d( Var4d,p,"h",level,0.,False)
			print("Var ok")
			delete(Var4d)
			VarExp =VarExp+ wrf_user_intrp3d( VarExp4d,pExp,"h",level,0.,False)
			print("VarExp ok")
			delete(VarExp4d)
		else if varname.eq."vec_pres"then
			u4d=wrf_user_getvar(in[iFilList(iFil)],"ua",diurnal)
			print("u4d ok")
			v4d=wrf_user_getvar(in[iFilList(iFil)],"va",diurnal)
			print("v4d ok")
			uExp4d=wrf_user_getvar(inExp[iFilList(iFil)],"ua",diurnal)
			print("uExp4d ok")
			vExp4d=wrf_user_getvar(inExp[iFilList(iFil)],"va",diurnal)
			print("vExp4d ok")
			p=wrf_user_getvar(in[iFilList(iFil)],"pressure",diurnal)
			pExp=wrf_user_getvar(inExp[iFilList(iFil)],"pressure",diurnal)
			utemp=wrf_user_intrp3d( u4d,p,"h",level,0.,False)
			u = u+utemp
			print("u ok")
			delete(u4d)
			vtemp=wrf_user_intrp3d( v4d,p,"h",level,0.,False)
			v = v+vtemp
			print("v ok")
			delete(v4d)
	        conv = uv2dv_cfd(utemp,vtemp,lat,lon,2)
			delete(utemp)
			delete(vtemp)
	        Var = Var+conv/1e-5
            utemp=wrf_user_intrp3d( uExp4d,pExp,"h",level,0.,False)			
			uExp =uExp+ utemp
			print("uExp ok")
			delete(uExp4d)
			vtemp=wrf_user_intrp3d( vExp4d,pExp,"h",level,0.,False)
			vExp = vExp+vtemp
			print("vExp ok")
			delete(vExp4d)
	        conv=uv2dv_cfd(utemp,vtemp,lat,lon,2)
			delete(utemp)
			delete(vtemp)
	        VarExp=VarExp+conv/1e-5
		else if varname.eq."precip"
			Var=Var+wrf_user_getvar(in[iFilList(iFil)],"RAINNC",diurnal+1)\
			+wrf_user_getvar(in[iFilList(iFil)],"RAINC",diurnal+1)\
			-wrf_user_getvar(in[iFilList(iFil)],"RAINNC",diurnal)\
			-wrf_user_getvar(in[iFilList(iFil)],"RAINC",diurnal)

			VarExp=VarExp+wrf_user_getvar(inExp[iFilList(iFil)],"RAINNC",diurnal+1)\
			+wrf_user_getvar(inExp[iFilList(iFil)],"RAINC",diurnal+1)\
			-wrf_user_getvar(inExp[iFilList(iFil)],"RAINNC",diurnal)\
			-wrf_user_getvar(inExp[iFilList(iFil)],"RAINC",diurnal)

		else if varname.ne."cape_2d".and.varname.ne."divergence"then
	        Var=Var+wrf_user_getvar(in[iFilList(iFil)],varname,diurnal)
	        VarExp=VarExp+wrf_user_getvar(inExp[iFilList(iFil)],varname,diurnal)
		end if	end if	end if	end if	end if	end if
		u10  = u10+wrf_user_getvar(in[iFilList(iFil)],"U10",diurnal)    ; 3D U at mass points
		v10  = v10+wrf_user_getvar(in[iFilList(iFil)],"V10",diurnal)    ; 3D V at mass points
		u10Exp  = u10Exp+wrf_user_getvar(inExp[iFilList(iFil)],"U10",diurnal)    ; 3D U at mass points
		v10Exp  = v10Exp+wrf_user_getvar(inExp[iFilList(iFil)],"V10",diurnal)    ; 3D V at mass points
	end do
end if
 	days=numFILS
	Var=Var/days
	VarExp=VarExp/days
	if varname.eq."vec_pres"then
		u=u/days
		v=v/days
		uExp=uExp/days
		vExp=vExp/days
	end if
	u10=u10/days
	v10=v10/days
	u10Exp=u10Exp/days
	v10Exp=v10Exp/days
	opts = res
	opts@InitTime=False
	opts@cnFillOn            = True
	opts@cnFillMode       = "RasterFill"
    opts@lbLabelFontHeightF=.02
	wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/"+plotwhich+"_"+varname+"_monthly")
;	wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/Both_vector_monthly")
	CTR_diurnal=new(24,"float")
	IRR_diurnal=CTR_diurnal
	do idiurnal=0,23
		if ensmean.eq.0 then
			opts@TimeLabel=times(idiurnal)
		end if
		if ensmean.eq.1 then
			aa=tostring(toint(times(idiurnal)-mod(times(idiurnal),1)))
			bb=tostring(sprinti("%0.2i",round(mod(times(idiurnal),1)*24,3)))
			timestring=bb+"Z"
			opts@TimeLabel = timestring   ; Set Valid time to use on plots
		end if
		print("Working on idiurnal "+idiurnal)
		if plotwhich.eq."CTR"then
			if varname.eq."cape_2d"then
				opts@ContourParameters = (/ 200., 3200., 150. /)
			else if varname.eq."T2"then
				opts@ContourParameters = (/ 270., 305., 1.75 /)
			else if varname.eq."vec_pres"then
				opts@ContourParameters = (/ -10., 10., 1. /)
			else if varname.eq."LH"then
				opts@ContourParameters=(/0.,50.,2.5/)
			end if	end if	end if	end if
			contour = wrf_contour(in[0],wks,Var(idiurnal,:,:),opts)
		else if	plotwhich.eq."IRR-CTR"then
			gsn_define_colormap(wks,"MPL_RdBu")
			if varname.eq."cape_2d"then
				opts@ContourParameters = (/ -500., 500., 50. /)
			else if varname.eq."LH"then
				opts@ContourParameters = (/ -200., 200., 200./10. /)
			else if varname.eq."slp"then
				opts@ContourParameters = (/ -1, 1, 1/10. /)
			else if varname.eq."T2"then
				gsn_define_colormap(wks,"temp_19lev")
				opts@ContourParameters = (/ -4., 4., 0.4 /)
			else if varname.eq."tc"then
				gsn_define_colormap(wks,"temp_19lev")
				opts@ContourParameters = (/ -2., 2., 0.2 /)
			else if varname.eq."divergence".or.varname.eq."vec_pres"then
				opts@ContourParameters = (/ -4., 4., 4./10. /)
			else if varname.eq."precip"then
				gsn_define_colormap(wks,"precip4_diff_19lev")
				opts@ContourParameters = (/ -0.1, 0.1, 0.1/10. /)
			end if end if end if end if end if end if end if
			if varname.eq."SMOIS"then
				gsn_define_colormap(wks,"temp_19lev")
				opts@ContourParameters = (/ -0.2, 0.2, 0.2/10. /)
                contour = wrf_contour(in[0],wks,VarExp(idiurnal,0,:,:)-Var(idiurnal,0,:,:),opts)
			else
				contour = wrf_contour(in[0],wks,VarExp(idiurnal,:,:)-Var(idiurnal,:,:),opts)
			end if
		end if

			tmp=new((/99,99/),"float")
			tmp(:,:)=0.
			tmpExp=tmp
			do i=42,56
				do j=i-2,i+2    ;-7 -2 +2
				if((j.ge.0).and.(j.le.98))then
					tmp(98-i,j)=Var(idiurnal,98-i,j)
					tmpExp(98-i,j)=VarExp(idiurnal,98-i,j)
				end if
				end do
			end do
			CTR_diurnal(idiurnal)=dim_sum_n_Wrap(dim_sum_n_Wrap(tmp,0),0)/75.
			IRR_diurnal(idiurnal)=dim_sum_n_Wrap(dim_sum_n_Wrap(tmpExp,0),0)/75.
		end if
		;==== Vector
		optsVec = res          
;		optsVec@TimeLabel=times(idiurnal)
		optsVec@vcRefAnnoOn=True
		optsVec@vcGlyphStyle="LineArrow"
		optsVec@NumVectors = 20        ; density of wind barbs
		optsVec@FieldTitle = "Wind"    ; overwrite Field Title
		if plotwhich.eq."CTR"then
			optsVec@vcRefMagnitudeF=2.
			;vector = wrf_vector(in[0],wks,u(idiurnal,:,:),v(idiurnal,:,:),optsVec)
		else if plotwhich.eq."IRR-CTR"then
			optsVecAno=optsVec
			optsVecAno@vcLineArrowColor        = "blue"
			optsVecAno@vcRefMagnitudeF=5.
			if level.ne.0 then
				;vector = wrf_vector(in[0],wks,uExp(idiurnal,:,:)-u(idiurnal,:,:),vExp(idiurnal,:,:)-v(idiurnal,:,:),optsVecAno)
				;vector = wrf_vector(in[0],wks,u(idiurnal,:,:),v(idiurnal,:,:),optsVecAno)
			end if
		end if	end if
		pltres@PanelPlot = True 
	if varname.eq."vec_pres"then
		plot = wrf_map_overlays(in[0],wks,(/contour,vector/),pltres,mpres)
	else
		plot = wrf_map_overlays(in[0],wks,(/contour/),pltres,mpres)
	end if
		pmres = True
		pmres@gsMarkerColor = "Red"
		pmres@gsMarkerIndex = 16
		pmres@gsMarkerSizeF = 0.01
		;plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
		plotstn1=gsn_add_polymarker(wks,plot,41.69,27.44,pmres)
		plotstn2=gsn_add_polymarker(wks,plot,43.77,26.30,pmres)
		plotstn3=gsn_add_polymarker(wks,plot,46.73,24.71,pmres)
		draw(plot)
		frame(wks)
	end do	; idiurnal
	print(" CTR_diurnal: "+CTR_diurnal)
	print(" IRR_diurnal: "+IRR_diurnal)
	;======================
	;For plotting irrigation region
	if plotres.eq."27km"then
		tmp=new((/99,99/),"float")
		tmp(:,:)=0.
		do i=42,56
			do j=i-2,i+2  ;i-2,i+2 is irrigated i-7,i+2 includes its neighborhood
			if((j.ge.0).and.(j.le.98))then
				tmp(98-i,j)=19
			end if
			end do
		end do
	else if plotres.eq."9km3km"then
		tmp=new((/210,210/),"float")
		tmp(:,:)=0.
		do i=50,180
			do j=i-30,i+20
			if((j.ge.0).and.(j.le.209))then
				tmp(209-i,j)=19
			end if
			end do
		end do
	end if	end if
;	print("^^^^^^^^^^^^^^")
;	print("lat: "+in[0]->XLAT(56,35))
;	print("lon: "+in[0]->XLONG(56,35))
;	print("lat: "+in[0]->XLAT(56,44))
;	print("lon: "+in[0]->XLONG(56,44))
;	print(ind(tmp(56,:).eq.19))
;	print("^^^^^^^^^^^^^^")
	res2=opts
	res2@ValidTime=False
	res2@MainTitle=""
	res@SubFieldTitle=""
	res2@cnFillOn=False
	res2@cnInfoLabelOn       = False       ; turn off info label
	res2@cnLinesOn           = True       ; do not draw contour lines
	res2@cnLineLabelsOn      = False       ; do not draw contour labels
	res2@cnLevelSelectionMode="ExplicitLevels"
	res2@ContourParameters=(/0.,50.,5./)
	res2@gsnContourZeroLineThicknessF=10.
	res2@cnLineColor="red"
	;======================
	wks2 = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/CTR_"+varname+"_monthly_mean_"+plotres)
	opts@TimeLabel="Monthly mean"
    gsn_define_colormap(wks2,"MPL_RdBu")
    gsn_define_colormap(wks2,"BlAqGrYeOrRe")
	opts@ContourParameters = (/ 0., 50., 50./20. /)
	if varname.eq."T2"then
		opts@ContourParameters = (/ 273., 313., 20./10. /)
		gsn_define_colormap(wks2,"temp_19lev")
	end if
	contour = wrf_contour(in[0],wks2,dim_avg_n_Wrap(Var,0),opts)
	if varname.eq."precip"then
		gsn_define_colormap(wks2,"precip3_16lev")
		opts@ContourParameters = (/ 0, 40., 40./20. /)
		if numFILS.eq.1 then
			Var2=Var*3486./4./29.
			VarExp2=VarExp*3486./4./29.  ;3486 days 4 month(FMAM) 29years
		end if
		contour = wrf_contour(in[0],wks2,dim_sum_n_Wrap(Var2,0),opts)
	end if
	contour_irri=wrf_contour(in[0],wks2,tmp,res2)
	pltres@PanelPlot = True 
	if varname.eq."vec_pres"then
		vector = wrf_vector(in[0],wks2,dim_avg_n_Wrap(u,0),dim_avg_n_Wrap(v,0),optsVec)
		plot2 = wrf_map_overlays(in[0],wks2,(/contour,contour_irri,vector/),pltres,mpres)
	else
		plot2 = wrf_map_overlays(in[0],wks2,(/contour,contour_irri/),pltres,mpres)
	end if
	pmres = True
	pmres@gsMarkerColor = "Black"
	pmres@gsMarkerIndex = 16
	pmres@gsMarkerSizeF = 0.01
	plotstn=gsn_add_polymarker(wks2,plot,43.97,26.33,pmres)
	draw(plot2)
	frame(wks2)

	wks2 = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/IRR-CTR_"+varname+"_monthly_mean_"+plotres)
	gsn_define_colormap(wks2,"MPL_RdBu")
;	opts@ContourParameters=opts@ContourParameters*0.6
	opts@ContourParameters=(/-5.,5.,5./10./)
	if varname.eq."T2" then
		gsn_define_colormap(wks2,"temp_19lev")
	end if
	contour = wrf_contour(in[0],wks2,dim_avg_n_Wrap(VarExp(6:12,:,:),0)-dim_avg_n_Wrap(Var(6:12,:,:),0),opts)
	if varname.eq."precip"then
		gsn_define_colormap(wks2,"precip4_diff_19lev")
		opts@ContourParameters=(/-4.,4.,0.4/)
		if numFILS.ne.1 then
			Var=Var*days/12./18.
			VarExp=VarExp*days/12./18.
		end if
		if numFILS.eq.1 then
			Var=Var*3486/4./29.
			VarExp=VarExp*3486/4./29.  ;3486 days 4 month(FMAM) 29years
		end if
		contour = wrf_contour(in[0],wks2,dim_sum_n_Wrap(VarExp(6:12,:,:),0)-dim_sum_n_Wrap(Var(6:12,:,:),0),opts)
	end if
	contour_irri=wrf_contour(in[0],wks2,tmp,res2)
	pltres@PanelPlot = True 
	if varname.eq."vec_pres"then
		vector = wrf_vector(in[0],wks2,dim_avg_n_Wrap(uExp(6:12,:,:),0)-dim_avg_n_Wrap(u(6:12,:,:),0),dim_avg_n_Wrap(vExp(6:12,:,:),0)-dim_avg_n_Wrap(v(6:12,:,:),0),optsVecAno)
;		vector = wrf_vector(in[0],wks2,dim_avg_n_Wrap(u(6:12,:,:),0),dim_avg_n_Wrap(v(6:12,:,:),0),optsVecAno)
		plot2 = wrf_map_overlays(in[0],wks2,(/contour,vector,contour_irri/),pltres,mpres)
	else
		plot2 = wrf_map_overlays(in[0],wks2,(/contour,contour_irri/),pltres,mpres)
	end if
	pmres = True
	pmres@gsMarkerColor = "Black"
	pmres@gsMarkerIndex = 16
	pmres@gsMarkerSizeF = 0.01
	plotstn=gsn_add_polymarker(wks2,plot,43.97,26.33,pmres)
	draw(plot2)
	frame(wks2)
	
end

