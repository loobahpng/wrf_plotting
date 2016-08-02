load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d02*|tail -n 32|head -n 30")
filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d02*|tail -n 32|head -n 30")
plottype="hourly"
;plottype="daily"
;plotwhich="CTR"
plotwhich="IRR-CTR"
varname="divergence"
if (plottype.eq."hourly")then
	numFILS=dimsizes(fils)
	in = addfiles(fils,"r")  ; Open a file
	inExp = addfiles(filsExp,"r")  ; Open a file
	type = "pdf"
	res = True                           ; Set up some basic plot resources
	res@MainTitle = "Divergence"
	res@Footer = False
;	res@ContourParameters = (/ 0., 40., 2. /)
	pltres = True
	mpres = True
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpGridLineColor = "Black"
	mpres@mpLimbLineColor = "Black"
	mpres@mpNationalLineColor = "Black"
	mpres@mpPerimLineColor = "Black"
	mpres@mpUSStateLineColor = "Black"

    all_lat = wrf_user_getvar(in,"lat",-1)
    all_lon = wrf_user_getvar(in,"lon",-1)
	lat = all_lat(0,:,0)
	lon = all_lon(0,0,:)

	do iFil=0,dimsizes(fils)-1,1
		wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/"+plotwhich+"_"+varname+"_hourly_"+(iFil+1))
		times = wrf_user_getvar(in[iFil],"times",-1) 
		ntimes=dimsizes(times)
		u  = wrf_user_getvar(in[iFil],"U10",-1)    ; 3D U at mass points
		v  = wrf_user_getvar(in[iFil],"V10",-1)    ; 3D V at mass points
		uExp  = wrf_user_getvar(inExp[iFil],"U10",-1)    ; 3D U at mass points
		vExp  = wrf_user_getvar(inExp[iFil],"V10",-1)    ; 3D V at mass points
		u = u*1.94386                    ; Turn wind into knots 
		v = v*1.94386
		u@units = "kts"
		v@units = "kts"
		uExp=uExp*1.94386
		vExp=vExp*1.94386
		u@units="kts"
		v@units="kts"
		conv = u
		conv = uv2dv_cfd(u,v,lat,lon,2)
		Var = conv/1e-5
		conv=uv2dv_cfd(uExp,vExp,lat,lon,2)
		VarExp=conv/1e-5
		opts = res
		opts@cnFillOn            = True
		opts@cnFillMode       = "RasterFill"
		Var = where(Var.gt.1e20, Var@_FillValue, Var)
		if dimsizes(dimsizes(Var)).eq.3 then
			do itime = 12,36
				print("Working on time: " + times(itime) )
				opts@TimeLabel=times(itime)
				if plotwhich.eq."CTR"then
					gsn_define_colormap(wks,"MPL_RdBu")
					contour = wrf_contour(in[iFil],wks,Var(itime,:,:),opts)
					opts@ContourParameters=(/-200.,200.,20./)
				else if	plotwhich.eq."IRR-CTR"then
					gsn_define_colormap(wks,"MPL_RdBu")
					opts@ContourParameters=(/-100.,100.,10./)
					contour = wrf_contour(in[iFil],wks,VarExp(itime,:,:)-Var(itime,:,:),opts)
				end if
				end if
				;==== Vector
				optsVec = res          
				optsVec@FieldTitle = "Wind"    ; overwrite Field Title
				optsVec@NumVectors = 20        ; density of wind barbs
				vector = wrf_vector(in[iFil],wks,u(itime,:,:),v(itime,:,:),optsVec)
				;====
				pltres@PanelPlot = True 
				plot = wrf_map_overlays(in[iFil],wks,(/contour/),pltres,mpres)
				pmres = True
				pmres@gsMarkerColor = "Black"
				pmres@gsMarkerIndex = 16
				pmres@gsMarkerSizeF = 0.01
				plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
				draw(plot)
				frame(wks)
			end do	; itime=12,36
		end if	; dimsizes(dimsizes(Var)).eq.3


	end do	; iFil=0,dimsizes(fils)-1,1
end if	; plottype.eq."hourly"

if (plottype.eq."daily")
	numFILS=dimsizes(fils)
	in = addfiles(fils,"r")  ; Open a file
	inExp = addfiles(filsExp,"r")  ; Open a file
	type = "pdf"
	res = True                           ; Set up some basic plot resources
	res@MainTitle = varname
	res@Footer = False
	;res@ContourParameters = (/ 0., 200., 10. /)
	;res@ContourParameters = (/ -1., 1.,0.1 /)
	pltres = True
	mpres = True
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpGridLineColor = "Black"
	mpres@mpLimbLineColor = "Black"
	mpres@mpNationalLineColor = "Black"
	mpres@mpPerimLineColor = "Black"
	mpres@mpUSStateLineColor = "Black"
	do iFil=0,dimsizes(fils)-1,1
		wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/"+varname+"_daily_"+(iFil+1))
		times = wrf_user_getvar(in[iFil],"times",-1) 
		ntimes=dimsizes(times)
		Var = wrf_user_getvar(in[iFil],varname,-1)    ; Get skintemp from file
		VarExp = wrf_user_getvar(inExp[iFil],varname,-1)    ; Get skintemp from file
		u  = wrf_user_getvar(in[iFil],"U10",-1)    ; 3D U at mass points
		v  = wrf_user_getvar(in[iFil],"V10",-1)    ; 3D V at mass points
		uExp  = wrf_user_getvar(inExp[iFil],"U10",-1)    ; 3D U at mass points
		vExp  = wrf_user_getvar(inExp[iFil],"V10",-1)    ; 3D V at mass points
		u = u*1.94386                    ; Turn wind into knots 
		v = v*1.94386
		u@units = "kts"
		v@units = "kts"
		if( varname.eq."T2".or.varname.eq."TSK" )then
			Var=Var-273.15
			VarExp=VarExp-273.15
		end if
		if( varname.eq."ACLHF" )then
			Var=Var/36/3600
		end if
		opts = res
		opts@cnFillOn            = True
		opts@cnFillMode       = "RasterFill"
		Var = where(Var.gt.1e20, Var@_FillValue, Var)
		if dimsizes(dimsizes(Var)).eq.3 then
				itime=ispan(12,36,1)
				print("Working on time: " + times(itime) )
				opts@TimeLabel=times(itime)
				if (varname.eq."slp")then
					optsSLP =res
					optsSLP@TimeLabel=times(itime)
					optsSLP@cnLineColor = "Blue"
					wrf_smooth_2d( Var, 3 ); smooth slp
					optsSLP@cnHighLabelsOn = True
					optsSLP@cnLowLabelsOn = True
					optsSLP@ContourParameters = (/ 900., 1100., 2. /)
					optsSLP@cnLineLabelBackgroundColor = -1
					optsSLP@gsnContourLineThicknessesScale = 2.0
					contour = wrf_contour(in[iFil],wks,dim_avg_n_Wrap(Var(itime,:,:),0),optsSLP)
				else
					contour = wrf_contour(in[iFil],wks,dim_avg_n_Wrap(Var(itime,:,:),0),opts)
				end if	; varname.eq."slp"
				;==== Vector
				optsVec = res          
				optsVec@FieldTitle = "Wind"    ; overwrite Field Title
				optsVec@NumVectors = 20        ; density of wind barbs
				vector = wrf_vector(in[iFil],wks,dim_avg_n_Wrap(u(itime,:,:),0),dim_avg_n_Wrap(v(itime,:,:),0),optsVec)
				;====
				pltres@PanelPlot = True 
				plot = wrf_map_overlays(in[iFil],wks,(/contour/),pltres,mpres)
				pmres = True
				pmres@gsMarkerColor = "Black"
				pmres@gsMarkerIndex = 16
				pmres@gsMarkerSizeF = 0.01
				plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
				draw(plot)
				frame(wks)
		end if	; dimsizes(dimsizes(Var)).eq.3

		if dimsizes(dimsizes(Var)).eq.4 then
				itime=ispan(12,36,1)
				;do  soil_layer=0,15
				soil_layer=0
				print("Working on time: " + times(itime) )
				print("soil_layer= "+soil_layer)
				opts@TimeLabel=times(itime)
				contour = wrf_contour(in[0],wks,dim_avg_n_Wrap(Var(itime,soil_layer,:,:),0),opts)
				pltres@PanelPlot = True 
				plot = wrf_map_overlays(in[0],wks,(/contour/),pltres,mpres)
				pmres = True
				pmres@gsMarkerColor = "Black"
				pmres@gsMarkerIndex = 16
				pmres@gsMarkerSizeF = 0.01
				plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
				draw(plot)
				frame(wks)
		;           end do	;soil_layer
		end if	; dimsizes(dimsizes(Var)).eq.4
	end do	; iFil=0,dimsizes(fils)-1,1
end if	; plottype.eq."daily"

end

