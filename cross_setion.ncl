
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot data on a cross section
;   This script will plot data from a a given point A to point B
;   Vertical coordinate is pressure

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/L.r02229011/wrf_plotting/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;ls /work3/L.r02229011/WRF/control_1986*/*|grep "\-04\-10"
quote = inttochar(34) 
ensmean=1
ip=2

plotwhich="IRR-CTR"
;plotwhich="CTR"
varname="tc"
;varname="specific humidity"

if ensmean .eq.0 then
	fils=systemfunc("ls /work3/L.r02229011/WRF/control_1986*/*|grep "+quote+"\-03\-10"+quote)
	filsExp=systemfunc("ls /work3/L.r02229011/WRF/irr_1986*/*|grep "+quote+"\-03\-10"+quote)
end if
if ensmean.eq.1 then
	fils=systemfunc ("ls /work3/L.r02229011/WRF/control_ensmean_1981_2010.nc")
	filsExp=systemfunc ("ls /work3/L.r02229011/WRF/irr_ensmean_1981_2010.nc")
end if

print(fils)
in = addfiles(fils,"r")  ; Open a file
inExp = addfiles(filsExp,"r")  ; Open a file
; We generate plots, but what kind do we prefer?
  type = "png"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/plt_CrossSection4")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"
  res@Footer = False
  pltres = True
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  FirstTime = True
  FirstTimeMap = True
  mdims = getfilevardimsizes(in[0],"P") ; get some dimension sizes for the file
  nd = dimsizes(mdims)
	if ensmean.eq.1 then
		times  = wrf_user_getvar(in[0],"Times",-1) ; get times in the file
		xlat = wrf_user_getvar(in[0], "XLAT",-1)
		xlon = wrf_user_getvar(in[0], "XLONG",-1)
	end if
	if ensmean.eq.0 then
		times  = wrf_user_getvar(in[0],"times",-1) ; get times in the file
		xlat = wrf_user_getvar(in[0], "XLAT",0)
		xlon = wrf_user_getvar(in[0], "XLONG",0)
	end if
	ntimes = dimsizes(times)         ; number of times in the file
  ter = wrf_user_getvar(inExp[0], "LH",15)
;---------------------------------------------------------------
average=new((/37,100,98/),"float")
averageExp=average
avgu=average
avguExp=average
avgw=average
avgwExp=average
do it = 0,ntimes-1,1             ; TIME LOOP
	if ensmean.eq.0 then
		print("Working on time: " + times(it) )
		res@TimeLabel = times(it)   ; Set Valid time to use on plots
	end if
	if ensmean.eq.1 then
		aa=tostring(toint(times(it)-mod(times(it),1)))
		bb=tostring(sprinti("%0.2i",round(mod(times(it),1)*24,3)))
		timestring=bb+"Z"
		print("Working on time: " + timestring )
		res@TimeLabel = timestring   ; Set Valid time to use on plots
	end if
    tc   = wrf_user_getvar(in[0],"tc",it)      ; T in C
	if varname.eq."specific humidity"then
		rh=wrf_user_getvar(in[0],"QVAPOR",it)
		rh(:,:,:)=rh(:,:,:)/(rh(:,:,:)+1)
	else
		rh   = wrf_user_getvar(in[0],varname,it)      ; relative humidity
	end if
    wa   = wrf_user_getvar(in[0],"wa",it)      

    tcExp   = wrf_user_getvar(inExp[0],"tc",it)      ; T in C
	if varname.eq."specific humidity"then
		rhExp=wrf_user_getvar(inExp[0],"QVAPOR",it)
		rhExp(:,:,:)=rhExp(:,:,:)/(rhExp(:,:,:)+1)
	else
		rhExp   = wrf_user_getvar(inExp[0],varname,it)      ; relative humidity
	end if
	if ip.eq.2 then
	    uaExp   = wrf_user_getvar(inExp[0],"va",it)      
		ua   = wrf_user_getvar(in[0],"va",it)      
	end if
	if ip.eq.1 then
		ua   = wrf_user_getvar(in[0],"ua",it)      
	    uaExp   = wrf_user_getvar(inExp[0],"ua",it)      
	end if
    waExp   = wrf_user_getvar(inExp[0],"wa",it)      

    z    = wrf_user_getvar(in[0], "z",it)      ; grid point height
    if ( FirstTime ) then                ; get height info for labels
      zmin = 0.
      zmax = 6.                          ; We are only interested in the first 6km
      nz   = floattoint(zmax + 1)
    end if
;---------------------------------------------------------------
;    do ip = 1, 3      	; we are doing 3 plots
			; all with the pivot point (plane) in the center of the domain
			; at angles 0, 45 and 90
 ;  
 ;                   |
 ;       angle=0 is  |
 ;                   |
 ; 
        plane = new(2,float)
;        plane = (/ mdims(nd-1)/2, mdims(nd-2)/2 /)    ; pivot point is center of domain (x,y)
		plane=(/50,48/)
        opts = False
		if(ip .eq. 1) then
			angle = 90.
			X_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
			X_desc = "longitude"
		end if
        if(ip .eq. 2) then
			angle = 0.
			X_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
			X_desc = "latitude"
        end if
        if(ip .eq. 3) then
			angle = 45.
			X_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
			X_desc = "longitude"
        end if
        rh_plane = wrf_user_intrp3d(rh,z,"v",plane,angle,opts)
        tc_plane = wrf_user_intrp3d(tc,z,"v",plane,angle,opts)
        ua_plane = wrf_user_intrp3d(ua,z,"v",plane,angle,opts)
        wa_plane = wrf_user_intrp3d(wa,z,"v",plane,angle,opts)

        rh_planeExp = wrf_user_intrp3d(rhExp,z,"v",plane,angle,opts)
        tc_planeExp = wrf_user_intrp3d(tcExp,z,"v",plane,angle,opts)
        ua_planeExp = wrf_user_intrp3d(uaExp,z,"v",plane,angle,opts)
        wa_planeExp = wrf_user_intrp3d(waExp,z,"v",plane,angle,opts)

      ; Find the index where 6km is - only need to do this once
        if ( FirstTime ) then
			zz = wrf_user_intrp3d(z,z,"v",plane,angle,opts)
			b = ind(zz(:,0) .gt. zmax*1000. )
			zmax_pos = b(0) - 1
			if ( abs(zz(zmax_pos,0)-zmax*1000.) .lt. abs(zz(zmax_pos+1,0)-zmax*1000.) ) then
				zspan = b(0) - 1
			else
				zspan = b(0)
			end if
			delete(zz)
			delete(b)
			FirstTime = False
        end if
      ; X-axis lables
      dimsX = dimsizes(X_plane)
;      xmin  = X_plane(0)
;      xmax  = X_plane(dimsX(0)-1)
;      xspan = dimsX(0)-1
;      nx    = floattoint( (xmax-xmin)/2 + 1)
	xmin  = X_plane(40)
	xmax  = X_plane(60-1)
	xspan = 60-40+1-1
	nx=5
      ;---------------------------------------------------------------
      ; Options for XY Plots
        opts_xy                         = res
        opts_xy@tiXAxisString           = X_desc
        opts_xy@tiYAxisString           = "Height (km)"
        opts_xy@cnMissingValPerimOn     = True
        opts_xy@cnMissingValFillColor   = 0
        opts_xy@cnMissingValFillPattern = 11
        opts_xy@tmXTOn                  = False
        opts_xy@tmYROn                  = False
        opts_xy@tmXBMode                = "Explicit"
        opts_xy@tmXBValues              = fspan(0,xspan,nx)                    ; Create tick marks
        opts_xy@tmXBLabels              = sprintf("%.1f",fspan(xmin,xmax,nx))  ; Create labels
        opts_xy@tmXBLabelFontHeightF    = 0.015
        opts_xy@tmYLMode                = "Explicit"
        opts_xy@tmYLValues              = fspan(0,zspan,nz)                    ; Create tick marks
        opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))  ; Create labels
        opts_xy@tiXAxisFontHeightF      = 0.020
        opts_xy@tiYAxisFontHeightF      = 0.020
        opts_xy@tmXBMajorLengthF        = 0.02
        opts_xy@tmYLMajorLengthF        = 0.02
        opts_xy@tmYLLabelFontHeightF    = 0.015
        opts_xy@PlotOrientation         = tc_plane@Orientation

      ; Plotting options for RH
        opts_rh = opts_xy
;        opts_rh@ContourParameters       = (/ 10., 90., 10. /)
        opts_rh@pmLabelBarOrthogonalPosF = -0.1 
        opts_rh@cnFillOn                = True
;        opts_rh@cnFillColors            = (/"White","White","White", \
;                                            "White","Chartreuse","Green", \
;                                            "Green3","Green4", \
;                                            "ForestGreen","PaleGreen4"/)

      ; Plotting options for Temperature
        opts_tc = opts_xy
        opts_tc@cnInfoLabelZone = 1
        opts_tc@cnInfoLabelSide = "Top"
        opts_tc@cnInfoLabelPerimOn = True
        opts_tc@cnInfoLabelOrthogonalPosF = -0.00005
;        opts_tc@ContourParameters  = (/ 5. /)
        opts_tc@ContourParameters  = (/ 0.5 /)

		opts_uw = opts_xy
        delete(opts_uw@cnMissingValPerimOn  ) 
        delete(opts_uw@cnMissingValFillColor  )
        delete(opts_uw@cnMissingValFillPattern)
		opts_uw@FieldTitle = "Wind" ; overwrite Field Title
		opts_uw@NumVectors = 20 ; density of wind barbs
		opts_uw@vcRefMagnitudeF=0.4
		opts_uw@vcRefAnnoOn=True
		opts_uw@vcGlyphStyle ="LineArrow";"WindBarb"
		wa_planeExp=wa_planeExp*10.
		wa_plane=wa_plane*10.
		vector = wrf_vector(in[0],wks,ua_planeExp(0:zmax_pos,40:60)-ua_plane(0:zmax_pos,40:60),wa_planeExp(0:zmax_pos,40:60)-wa_plane(0:zmax_pos,40:60),opts_uw)
		if it.ne.ntimes-1 then
			delete(opts_uw)
		end if

      ; Get the contour info for the rh and temp

if varname .eq."specific humidity"then
	rh_planeExp=rh_planeExp*1000.
	rh_plane=rh_plane*1000.
end if
; multiplied by 1000 if humidity

	if plotwhich.eq."CTR"then
		if varname.eq."special humidity"then
			opts_rh@ContourParameters = (/ 0.001, 0.012, 0.01/10. /)
		end if
		if varname.eq."rh"
			opts_rh@ContourParameters = (/ 10., 60., 5. /)
		end if
        contour_tc = wrf_contour(in[0],wks,tc_plane(0:zmax_pos,:),opts_tc)
        contour_rh = wrf_contour(in[0],wks,rh_plane(0:zmax_pos,:),opts_rh)
	end if
	if plotwhich .eq."IRR-CTR"then 
		gsn_define_colormap(wks,"precip4_diff_19lev")
		opts_rh@ContourParameters = (/ -2., 2., 2./10. /)
        contour_tc = wrf_contour(in[0],wks,tc_planeExp(0:zmax_pos,40:60)-tc_plane(0:zmax_pos,40:60),opts_tc)
        contour_rh = wrf_contour(in[0],wks,rh_planeExp(0:zmax_pos,40:60)-rh_plane(0:zmax_pos,40:60),opts_rh)
        contour_rh_contour = wrf_contour(in[0],wks,rh_plane(0:zmax_pos,40:60),opts_tc)
		opts_tc@ContourParameters=(/2./)
        contour_tc_contour = wrf_contour(in[0],wks,tc_plane(0:zmax_pos,40:60),opts_tc)
		opts_rh@ContourParameters = (/ -2., 2., 2./10. /)
;		opts_rh@cnLevelSelectionMode = "ExplicitLevels"
;		opts_rh@cnLevels             = (/ -2.,-1.5,-1.,-0.5,0.,0.1,0.2,0.3,0.4/)
		gsn_define_colormap(wks,"temp_19lev")
        contour_tc_shading = wrf_contour(in[0],wks,tc_planeExp(0:zmax_pos,40:60)-tc_plane(0:zmax_pos,40:60),opts_rh)
	end if
	average(it,:,:)=rh_plane
	averageExp(it,:,:)=rh_planeExp
	avgu(it,:,:)=ua_plane
	avguExp(it,:,:)=ua_planeExp
	avgw(it,:,:)=wa_plane
	avgwExp(it,:,:)=wa_planeExp
      ;---------------------------------------------------------------
  ; MAKE PLOTS         
        if (FirstTimeMap) then
          lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
          lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
          mpres = True
          pltres = True
          pltres@FramePlot = False
          optsM = res
          optsM@NoHeaderFooter = True
          optsM@cnFillOn = True
          optsM@lbTitleOn = False
          contour  = wrf_contour(in[0],wks,ter,optsM)
          plot = wrf_map_overlays(in[0],wks,(/contour/),pltres,mpres)
          lnres = True
          lnres@gsLineThicknessF = 3.0
          lnres@gsLineColor = "Red"
          do ii = 0,dimsX(0)-2
            gsn_polyline(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres)
          end do
          frame(wks)
          delete(lon_plane)
          delete(lat_plane)
          pltres@FramePlot = True
			print("FistTimeMap")
       end if

;       plot = wrf_overlays(in[0],wks,(/contour_rh,contour_tc,vector/),pltres)    ; plot x-section
       plot = wrf_overlays(in[0],wks,(/contour_tc_contour,contour_tc_shading,vector/),pltres)    ; plot x-section

  ; Delete options and fields, so we don't have carry over
	if it.ne.ntimes-1 then
        delete(opts_xy)
        delete(opts_tc)
        delete(opts_rh)
        delete(tc_plane)
        delete(rh_plane)
        delete(X_plane)
	end if
;    end do  ; make next cross section

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FirstTimeMap = False
  end do        ; END OF TIME LOOP

	wks = gsn_open_wks(type,"/home/L.r02229011/wrf_fig/averaged_cross_section")
	vector = wrf_vector(in[0],wks,dim_avg_n_Wrap(avguExp(15:21,0:zmax_pos,40:60),0)-dim_avg_n_Wrap(avgu(15:21,0:zmax_pos,40:60),0),dim_avg_n_Wrap(avgwExp(15:21,0:zmax_pos,40:60),0)-dim_avg_n_Wrap(avgw(15:21,0:zmax_pos,40:60),0),opts_uw)
	opts_tc@ContourParameters=(/2./);tc
;	opts_tc@ContourParameters=(/0.5/);q
	contour_tc_contour = wrf_contour(in[0],wks,dim_avg_n_Wrap(average(15:21,0:zmax_pos,40:60),0),opts_tc)
	opts_rh@ContourParameters = (/ -2., 2., 2./10. /)
	gsn_define_colormap(wks,"precip4_diff_19lev")
	gsn_define_colormap(wks,"temp_19lev")
	contour_tc_shading = wrf_contour(in[0],wks,dim_avg_n_Wrap(averageExp(15:21,0:zmax_pos,40:60),0)-dim_avg_n_Wrap(average(15:21,0:zmax_pos,40:60),0),opts_rh)
;   plot = wrf_overlays(in[0],wks,(/contour_tc_contour,contour_tc_shading,vector/),pltres)    ; plot x-section
   plot = wrf_overlays(in[0],wks,(/contour_tc_shading,vector/),pltres)    ; plot x-section



end

