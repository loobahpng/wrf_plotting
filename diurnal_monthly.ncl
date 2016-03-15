load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/L.r02229011/wrf_plotting/WRFUserARW.ncl"
begin
fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d01*|tail -n 32|head -n 30")
filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d01*|tail -n 32|head -n 30")
;plotwhich="CTR"
plotwhich="IRR-CTR"
varname="cape_2d"

	numFILS=dimsizes(fils)
	in = addfiles(fils,"r")  ; Open a file
	inExp = addfiles(filsExp,"r")  ; Open a file
	type = "pdf"
	res = True                           ; Set up some basic plot resources
	res@MainTitle = "Vector"
	res@Footer = False
	pltres = True
	mpres = True
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpGridLineColor = "Black"
	mpres@mpLimbLineColor = "Black"
	mpres@mpNationalLineColor = "Black"
	mpres@mpPerimLineColor = "Black"
	mpres@mpUSStateLineColor = "Black"
	
	diurnal=ispan(12,35,1)
	iFilList=ispan(0,29,1)
;	iFilList=(/3,5,12,14,17,18,23,24/)
	print("Working on iFilList 0")
	temp= wrf_user_getvar(in[iFilList(0)],varname,diurnal)
	temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
	Var=temp(0,:,:,:)
	temp = wrf_user_getvar(inExp[iFilList(0)],varname,diurnal)
	temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
	VarExp=temp(0,:,:,:)
	u  = wrf_user_getvar(in[iFilList(0)],"U10",diurnal)*1.94386    ; 3D U at mass points
	v  = wrf_user_getvar(in[iFilList(0)],"V10",diurnal)*1.94386    ; 3D V at mass points
	uExp  = wrf_user_getvar(inExp[iFilList(0)],"U10",diurnal)*1.94386    ; 3D U at mass points
	vExp  = wrf_user_getvar(inExp[iFilList(0)],"V10",diurnal)*1.94386    ; 3D V at mass points
	u@units = "kts"
	v@units = "kts"
	times = wrf_user_getvar(in[0],"times",diurnal) 
	do iFil=1,dimsizes(iFilList)-1,1
		print("Working on iFilList "+iFil)
		temp= wrf_user_getvar(in[iFilList(iFil)],varname,diurnal)
		temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
		Var = Var+temp(0,:,:,:)
		temp= wrf_user_getvar(inExp[iFilList(iFil)],varname,diurnal)
		temp(0,:,:,:)=where(ismissing(temp(0,:,:,:)),0,temp(0,:,:,:))
		VarExp = VarExp+temp(0,:,:,:)
		u  = u+wrf_user_getvar(in[iFilList(iFil)],"U10",diurnal)*1.94386    ; 3D U at mass points
		v  = v+wrf_user_getvar(in[iFilList(iFil)],"V10",diurnal)*1.94386    ; 3D V at mass points
		uExp  = uExp+wrf_user_getvar(inExp[iFilList(iFil)],"U10",diurnal)*1.94386    ; 3D U at mass points
		vExp  = vExp+wrf_user_getvar(inExp[iFilList(iFil)],"V10",diurnal)*1.94386    ; 3D V at mass points
	end do
	Var=Var/30
	VarExp=VarExp/30
	u=u/30
	v=v/30
	uExp=uExp/30
	vExp=vExp/30
	opts = res
	opts@cnFillOn            = True
	opts@cnFillMode       = "RasterFill"
	wks = gsn_open_wks(type,"fig/"+plotwhich+"_"+varname+"_monthly")
;	wks = gsn_open_wks(type,"fig/Both_vector_monthly")
	do idiurnal=0,23
	opts@TimeLabel=times(idiurnal)
		print("Working on idiurnal "+idiurnal)
		if plotwhich.eq."CTR"then
			opts@ContourParameters = (/ 200., 3200., 150. /)
			contour = wrf_contour(in[0],wks,Var(idiurnal,:,:),opts)
		else if	plotwhich.eq."IRR-CTR"then
			gsn_define_colormap(wks,"MPL_RdBu")
			opts@ContourParameters = (/ -500., 500., 50. /)
			contour = wrf_contour(in[0],wks,VarExp(idiurnal,:,:)-Var(idiurnal,:,:),opts)
		end if
		end if
		;==== Vector
		optsVec = res          
		optsVec@TimeLabel=times(idiurnal)
		optsVec@vcRefAnnoOn=True
		optsVec@vcGlyphStyle="LineArrow"
		optsVec@NumVectors = 20        ; density of wind barbs
		optsVec@FieldTitle = "Wind"    ; overwrite Field Title
;		if plotwhich.eq."CTR"then
			optsVec@vcRefMagnitudeF=5.
			vector = wrf_vector(in[0],wks,u(idiurnal,:,:),v(idiurnal,:,:),optsVec)
;		else if plotwhich.eq."IRR-CTR"then
			optsVecAno=optsVec
			optsVecAno@vcLineArrowColor        = "blue"
			optsVecAno@vcRefMagnitudeF=5.
			vectorAno = wrf_vector(in[0],wks,uExp(idiurnal,:,:)-u(idiurnal,:,:),vExp(idiurnal,:,:)-v(idiurnal,:,:),optsVecAno)
;		end if
;		end if
		pltres@PanelPlot = True 
		plot = wrf_map_overlays(in[0],wks,(/contour/),pltres,mpres)
		pmres = True
		pmres@gsMarkerColor = "Black"
		pmres@gsMarkerIndex = 16
		pmres@gsMarkerSizeF = 0.01
		plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
		draw(plot)
		frame(wks)
	end do	; idiurnal
end

