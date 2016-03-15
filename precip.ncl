load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d01*|tail -n 32|head -n 30")
filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d01*|tail -n 32|head -n 30")
;filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both_75/wrfout_d01*|tail -n 32|head -n 30")
plottype="daily"
;plottype="hourly"
if (plottype.eq."daily")then
	in = addfiles(fils,"r")
	inExp = addfiles(filsExp,"r")
	ListSetType (in,"join")
	ListSetType (inExp,"join")
	case="WRF3.5.1 9km 3km Control"
	type = "pdf"
	wks = gsn_open_wks(type,"fig/daily_Precip")
	wksAno = gsn_open_wks(type,"fig/daily_PrecipAno")
	res = True
	res@MainTitle = case
	pltres = True
	mpres = True
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpNationalLineColor    = "Black"
	mpres@mpUSStateLineColor     = "Black"
	mpres@mpGridLineColor        = "Black"
	mpres@mpLimbLineColor        = "Black"
	mpres@mpPerimLineColor       = "Black"
	do iFil=0,dimsizes(fils)-1,1
		times = wrf_user_getvar(in[iFil],"times",-1)  ; get all times in the file
		ntimes = dimsizes(times)         ; number of times in the file
		it=12
		print("Working on time: " + times(it) )
		print("iFil: "+iFil)
		times_sav=times(it)
		res@TimeLabel = times(it)   ; Set Valid time to use on plots
		rain_exp_save = wrf_user_getvar(in[iFil],"RAINNC",it)
		rain_con_save = wrf_user_getvar(in[iFil],"RAINC",it)
		rain_tot_save = rain_exp_save + rain_con_save
		rain_tot_save@description = "Total Precipitation"
		rain_exp_saveExp = wrf_user_getvar(inExp[iFil],"RAINNC",it)
		rain_con_saveExp = wrf_user_getvar(inExp[iFil],"RAINC",it)
		rain_tot_saveExp = rain_exp_saveExp + rain_con_saveExp
		rain_tot_saveExp@description = "Total Precipitation"
		it=36
		rain_exp = wrf_user_getvar(in[iFil],"RAINNC",it)
		rain_con = wrf_user_getvar(in[iFil],"RAINC",it)
		rain_tot = rain_exp + rain_con
		rain_tot_tend = rain_tot - rain_tot_save
		rain_tot_tend@description = "Precipitation Tendency"
		rain_expExp = wrf_user_getvar(inExp[iFil],"RAINNC",it)
		rain_conExp = wrf_user_getvar(inExp[iFil],"RAINC",it)
		rain_totExp = rain_expExp + rain_conExp
		rain_tot_tendExp = rain_totExp - rain_tot_saveExp
		rain_tot_tendExp@description = "Precipitation Tendency"
		opts_r = res                        
		opts_r@UnitLabel            = "mm"
		opts_r@cnInfoLabelOn        = False
		opts_r@cnConstFLabelOn      = False
		opts_r@cnFillOn             = True
		opts_r@SubFieldTitle = "from " + times_sav + " to " + times(it)
		opts_r2=opts_r
		opts_r2@cnLevelSelectionMode = "ExplicitLevels"
		opts_r2@cnLevels             = (/ .1, .2, .4, .8, 1.6, 3.2, 6.4, \
										12.8, 25.6, 51.2, 102.4/)
		opts_r2@cnFillColors         = (/"White","White","DarkOliveGreen1", \
										"DarkOliveGreen3","Chartreuse", \
										"Chartreuse3","Green","ForestGreen", \
										"Yellow","Orange","Red","Violet"/)
		contour_tend = wrf_contour(in[iFil],wks, rain_tot_tend,opts_r2) ; total (color)
		plot = wrf_map_overlays(in[iFil],wks,contour_tend,pltres,mpres)
		opts_rAno=opts_r
		opts_rAno@ContourParameters=(/-20.,20.,2./)
		gsn_define_colormap(wksAno,"precip4_diff_19lev")
		contour_tendAno = wrf_contour(in[iFil],wksAno, rain_tot_tendExp-rain_tot_tend,opts_rAno) ; total (color)
		plotAno=wrf_map_overlays(in[iFil],wksAno,contour_tendAno,pltres,mpres)
		if (iFil.eq.0)then
			total_rain=rain_tot_tend
			total_rainAno=rain_tot_tendExp-rain_tot_tend
			total_rainAno@description=""
			total_rain@description=""
		else
			total_rain=total_rain+rain_tot_tend
			total_rainAno=total_rainAno+rain_tot_tendExp-rain_tot_tend
		end if
	end do
		wks = gsn_open_wks(type,"fig/total_Precip")
		opts_r@ContourParameters=(/0.,200.,10./)
		gsn_define_colormap(wks,"precip3_16lev")
		opts_r@cnFillMode           = "RasterFill"
		opts_r@cnSpanFillPalette=True
		opts_r@SubFieldTitle = "Monthly Precipitation"
		contour_total = wrf_contour(in[0],wks, total_rain,opts_r) 
		plot_total = wrf_map_overlays(in[0],wks,contour_total,pltres,mpres)

		wksAno = gsn_open_wks(type,"fig/total_PrecipAno")
		opts_r@ContourParameters=(/-50.,50.,5./)
		gsn_define_colormap(wksAno,"precip4_diff_19lev")
		opts_r@MainTitle="IRR-CTR"
		opts_r@cnSpanFillPalette=True
		opts_r@SubFieldTitle = "Monthly Precipitation"
;		pltres@PanelPlot = True
;		pltres@FramePlot = False
		contour_total = wrf_contour(in[0],wksAno, total_rainAno,opts_r) 
		plot_total = wrf_map_overlays(in[0],wksAno,contour_total,pltres,mpres)

		wksRatio=gsn_open_wks(type,"fig/total_PrecipAnoRatio")
		opts_r@ContourParameters=(/-1.,1.,0.1/)
		contour_total = wrf_contour(in[0],wksRatio, total_rainAno/where(total_rain.ne.0,total_rain,total_rain@_FillValue),opts_r)
		plot_total = wrf_map_overlays(in[0],wksRatio,contour_total,pltres,mpres)
	;===============
;	print("sum ano: "+dim_avg_n_Wrap(dim_avg_n_Wrap(total_rainAno,0),0))
	XLAT = wrf_user_getvar(in[0],"XLAT",it)
	XLONG = wrf_user_getvar(in[0],"XLONG",it)
	ygrid1=119
	ygrid2=145
	xgrid1=139
	xgrid2=179
	ypoint1=XLAT(ygrid1,xgrid1)
	xpoint1=XLONG(ygrid1,xgrid1)
	print("lat: "+ypoint1+", lon: "+xpoint1)
	ypoint2=XLAT(ygrid1,xgrid2)
	xpoint2=XLONG(ygrid2,xgrid2)
	print("lat: "+ypoint2+", lon: "+xpoint2)
	ypoint3=XLAT(ygrid2,xgrid1)
	xpoint3=XLONG(ygrid2,xgrid1)
	print("lat: "+ypoint3+", lon: "+xpoint3)
	ypoint4=XLAT(ygrid2,xgrid2)
	xpoint4=XLONG(ygrid2,xgrid2)
	print("lat: "+ypoint4+", lon: "+xpoint4)
	;===============
	;resp                  = True                      ; polyline mods desired
	;resp@gsLineColor      = "black"                     ; color of lines
	;resp@gsLineThicknessF = 4.0                       ; thickness of lines
	;latstart=25
	;latend=26
	;lonstart=43.5
	;lonend=44.5
	;location=latstart+"-"+latend+"N "+lonstart+"-"+lonend+"E "
	;ypts=(/latstart,latstart,latend,latend,latstart/)
	;xpts=(/lonstart,lonend,lonend,lonstart,lonstart/)
	;dum = new(4,graphic)  
	;do i = 0 , 3
	;	dum(i)=gsn_add_polyline(wks,plot_total,xpts(i:i+1),ypts(i:i+1),resp)      
	;end do 
	;draw(plot_total)
	;frame(wks)
	;===============
		pmres = True
		pmres@gsMarkerColor = "Black"
		pmres@gsMarkerIndex = 16
		pmres@gsMarkerSizeF = 0.01
		plotstn=gsn_add_polymarker(wks,plot_total,xpoint1,ypoint1,pmres)
		plotstn2=gsn_add_polymarker(wks,plot_total,xpoint2,ypoint2,pmres)
		plotstn3=gsn_add_polymarker(wks,plot_total,xpoint3,ypoint3,pmres)
		plotstn4=gsn_add_polymarker(wks,plot_total,xpoint4,ypoint4,pmres)
		draw(plot_total)
		frame(wksAno)
end if	; plottype.eq."daily"

if (plottype.eq."hourly")then
	in = addfiles(fils,"r")
	inExp = addfiles(filsExp,"r")
	ListSetType (in,"join")
	ListSetType (inExp,"join")
	case="WRF3.5.1 9km 3km Control"
	type = "pdf"
	res = True
	res@MainTitle = case
	pltres = True
	mpres = True
	mpres@mpGeophysicalLineColor = "Black"
	mpres@mpNationalLineColor    = "Black"
	mpres@mpUSStateLineColor     = "Black"
	mpres@mpGridLineColor        = "Black"
	mpres@mpLimbLineColor        = "Black"
	mpres@mpPerimLineColor       = "Black"
	do iFil=0,dimsizes(fils)-1,1
		wks = gsn_open_wks(type,"fig/hourly_Precip_"+(iFil+1))
		wksAno = gsn_open_wks(type,"fig/hourly_PrecipAno_"+(iFil+1))
		times = wrf_user_getvar(in[iFil],"times",-1)  ; get all times in the file
		ntimes = dimsizes(times)         ; number of times in the file
		it=12
		do it=12,36
		print("Working on time: " + times(it) )
		print("iFil: "+iFil)
		res@TimeLabel = times(it)   ; Set Valid time to use on plots
		rain_tot_tend = wrf_user_getvar(in[iFil],"RAINNC",it)-wrf_user_getvar(in[iFil],"RAINNC",it-1)
		rain_tot_tend@description = "Precipitation Tendency"
		rain_tot_tendExp = wrf_user_getvar(inExp[iFil],"RAINNC",it)-wrf_user_getvar(inExp[iFil],"RAINNC",it-1)
		rain_tot_tendExp@description = "Precipitation Tendency"
		opts_r = res                        
		opts_r@UnitLabel            = "mm"
		opts_r@cnInfoLabelOn        = False
		opts_r@cnConstFLabelOn      = False
		opts_r@cnFillOn             = True
		opts_r@SubFieldTitle = "from " + times(it-1) + " to " + times(it)
		opts_r2=opts_r
		opts_r2@cnLevelSelectionMode = "ExplicitLevels"
		opts_r2@cnLevels             = (/ .1, .2, .4, .8, 1.6, 3.2, 6.4, \
										12.8, 25.6, 51.2, 102.4/)
		opts_r2@cnFillColors         = (/"White","White","DarkOliveGreen1", \
										"DarkOliveGreen3","Chartreuse", \
										"Chartreuse3","Green","ForestGreen", \
										"Yellow","Orange","Red","Violet"/)
		contour_tend = wrf_contour(in[iFil],wks, rain_tot_tend,opts_r2) ; total (color)
		plot = wrf_map_overlays(in[iFil],wks,contour_tend,pltres,mpres)
		opts_rAno=opts_r
		opts_rAno@ContourParameters=(/-10.,10.,1./)
		gsn_define_colormap(wksAno,"precip4_diff_19lev")
		contour_tendAno = wrf_contour(in[iFil],wksAno, rain_tot_tendExp-rain_tot_tend,opts_rAno) ; total (color)
		plotAno=wrf_map_overlays(in[iFil],wksAno,contour_tendAno,pltres,mpres)
	end do
	end do
end if
end

