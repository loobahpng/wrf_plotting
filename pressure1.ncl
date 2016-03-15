load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
fils=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_36hr_ts20s/wrfout_d01*|tail -n 32|head -n 30")
filsExp=systemfunc ("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/irr_1986_36hr_both/wrfout_d01*|tail -n 32|head -n 30")
plottype="hourly"
;plottype="daily"
plotwhich="CTR"
;plotwhich="IRR-CTR"
if (plottype.eq."hourly") then
	in = addfiles(fils,"r")  ; Open a file
	inExp = addfiles(filsExp,"r")  ; Open a file
	pressure_levels = (/ 850./)   ; pressure levels to plot
	do iFil=0,dimsizes(fils)-1,1
		type = "pdf"
		wks = gsn_open_wks(type,"fig/"+plotwhich+"_"+pressure_levels+"hpa_"+plottype+(iFil+1))
		res = True
		res@MainTitle                   = "REAL-TIME WRF"
		res@Footer = False
		pltres = True
		mpres = True
		mpres@mpGeophysicalLineColor      = "Black"
		mpres@mpNationalLineColor         = "Black"
		mpres@mpUSStateLineColor          = "Black"
		mpres@mpGridLineColor             = "Black"
		mpres@mpLimbLineColor             = "Black"
		mpres@mpPerimLineColor            = "Black"
		mpres@mpGeophysicalLineThicknessF = 2.0
		mpres@mpGridLineThicknessF        = 2.0
		mpres@mpLimbLineThicknessF        = 2.0
		mpres@mpNationalLineThicknessF    = 2.0
		mpres@mpUSStateLineThicknessF     = 2.0
		; What times and how many time steps are in the data set?
		times = wrf_user_getvar(in[iFil],"times",-1)  ; get all times in the file
		ntimes = dimsizes(times)         ; number of times in the file
		; The specific pressure levels that we want the data interpolated to.
		nlevels         = dimsizes(pressure_levels)     ; number of pressure levels
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		do it = 12,36            ; TIME LOOP
			print("Working on time: " + times(it) )
			res@TimeLabel = times(it)   ; Set Valid time to use on plots
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; First get the variables we will need        
			tc = wrf_user_getvar(in[iFil],"tc",it)        ; T in C
			tcExp = wrf_user_getvar(inExp[iFil],"tc",it)        ; T in C
			u  = wrf_user_getvar(in[iFil],"ua",it)        ; u averaged to mass points
			v  = wrf_user_getvar(in[iFil],"va",it)        ; v averaged to mass points
			w  = wrf_user_getvar(in[iFil],"wa",it)        ; v averaged to mass points
			uExp  = wrf_user_getvar(inExp[iFil],"ua",it)        ; u averaged to mass points
			vExp  = wrf_user_getvar(inExp[iFil],"va",it)        ; v averaged to mass points
			wExp  = wrf_user_getvar(inExp[iFil],"wa",it)        ; v averaged to mass points
			p  = wrf_user_getvar(in[iFil], "pressure",it) ; pressure is our vertical coordinate
			pExp  = wrf_user_getvar(inExp[iFil], "pressure",it) ; pressure is our vertical coordinate
			z  = wrf_user_getvar(in[iFil], "z",it)        ; grid point height
			zExp  = wrf_user_getvar(inExp[iFil], "z",it)        ; grid point height
			rh = wrf_user_getvar(in[iFil],"rh",it)        ; relative humidity
			rhExp = wrf_user_getvar(inExp[iFil],"rh",it)        ; relative humidity
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			do level = 0,nlevels-1                 ; LOOP OVER LEVELS
				pressure = pressure_levels(level)
				tc_plane = wrf_user_intrp3d(tc,p,"h",pressure,0.,False)
				tc_planeExp = wrf_user_intrp3d(tcExp,pExp,"h",pressure,0.,False)
				z_plane  = wrf_user_intrp3d( z,p,"h",pressure,0.,False)
				z_planeExp  = wrf_user_intrp3d( zExp,pExp,"h",pressure,0.,False)
				rh_plane = wrf_user_intrp3d(rh,p,"h",pressure,0.,False)
				rh_planeExp = wrf_user_intrp3d(rhExp,pExp,"h",pressure,0.,False)
				u_plane  = wrf_user_intrp3d( u,p,"h",pressure,0.,False)
				v_plane  = wrf_user_intrp3d( v,p,"h",pressure,0.,False)
				w_plane  = wrf_user_intrp3d( w,p,"h",pressure,0.,False)
				u_planeExp  = wrf_user_intrp3d( uExp,pExp,"h",pressure,0.,False)
				v_planeExp  = wrf_user_intrp3d( vExp,pExp,"h",pressure,0.,False)
				w_planeExp  = wrf_user_intrp3d( wExp,pExp,"h",pressure,0.,False)
				spd     = (u_plane*u_plane + v_plane*v_plane)^(0.5) ; m/sec
				spd@description = "Wind Speed"
				spd@units = "m/s"
				u_plane = u_plane*1.94386     ; kts
				v_plane = v_plane*1.94386     ; kts
				u_plane@units = "kts"
				v_plane@units = "kts"
				u_planeExp = u_planeExp*1.94386     ; kts
				v_planeExp = v_planeExp*1.94386     ; kts
				u_planeExp@units = "kts"
				v_planeExp@units = "kts"
				; Plotting options for T                
				opts = res                          
				opts@cnLineColor = "Red"
				opts@cnInfoLabelOrthogonalPosF = 0.07  ; offset second label information
				opts@gsnContourLineThicknessesScale = 2.0
				if plotwhich.eq."CTR" then
					opts@ContourParameters = (/ 5.0 /)
					contour_tc = wrf_contour(in[iFil],wks,tc_plane,opts)
				else if plotwhich.eq."IRR-CTR"then
					opts@ContourParameters = (/ 1. /)
					contour_tc = wrf_contour(in[iFil],wks,tc_planeExp-tc_plane,opts)
				end if
				end if
				delete(opts)
			  ; Plotting options for RH                
				opts = res                          
				opts@cnFillOn = True  
				opts@pmLabelBarOrthogonalPosF = -0.1
				opts@cnFillColors = (/"White","White","White", \
									  "White","Chartreuse","Green",\
									  "Green3","Green4", \
									  "ForestGreen","PaleGreen4"/)
				if plotwhich.eq."CTR"then
					opts@ContourParameters = (/ 10., 90., 10./)
					contour_rh = wrf_contour(in[iFil],wks,rh_plane,opts)
				else if plotwhich.eq."IRR-CTR"then
					opts@ContourParameters = (/ 5., 21., 2./)
					contour_rh = wrf_contour(in[iFil],wks,rh_planeExp-rh_plane,opts)
				end if
				end if
				delete(opts)
			  ; Plotting vertical velocity
				opts = res                          
				opts@cnFillOn=True
				if plotwhich.eq."CTR" then
;					opts@ContourParameters = (/ 5.0 /)
					contour_w = wrf_contour(in[iFil],wks,w_plane,opts)
				else if plotwhich.eq."IRR-CTR"then
;					opts@ContourParameters = (/ 1. /)
					contour_w = wrf_contour(in[iFil],wks,w_planeExp-w_plane,opts)
				end if
				end if
				delete(opts)
	
			  ; Plotting options for Wind Speed                
				opts = res                          
				opts@cnLineColor = "MediumSeaGreen"
				opts@ContourParameters = (/ 10. /)
				opts@cnInfoLabelOrthogonalPosF = 0.07  ; offset second label information
				opts@gsnContourLineThicknessesScale = 3.0
				contour_spd = wrf_contour(in[iFil],wks,spd,opts)
				delete(opts)
			  ; Plotting options for Wind Vectors                 
				opts = res          
				opts@FieldTitle = "Wind"   ; overwrite Field Title
				opts@NumVectors = 30;47       ; wind barb density
				opts@vcWindBarbColor="blue" 
				opts@vcRefAnnoOn=True
				opts@vcGlyphStyle="LineArrow"
				opts@vcLineArrowColor="blue" 
				if plotwhich.eq."CTR" then
					vector = wrf_vector(in[iFil],wks,u_plane,v_plane,opts)
				else if plotwhich.eq."IRR-CTR"then
					vector = wrf_vector(in[iFil],wks,u_planeExp-u_plane,v_planeExp-v_plane,opts)
				end if
				end if
				delete(opts)
			  ; Plotting options for Geopotential Heigh
				opts_z = res                          
				opts_z@cnLineColor = "Blue"
				opts_z@gsnContourLineThicknessesScale = 3.0
			  ; MAKE PLOTS                                       
				if ( pressure .eq. 925 ) then   ; plot temp, rh, height, wind barbs
					opts_z@ContourParameters = (/ 20.0 /)
					contour_height = wrf_contour(in[iFil],wks,z_plane,opts_z)
					;          plot = wrf_map_overlays(a,wks,(/contour_rh,contour_tc,contour_height, \
					;                                    vector/),pltres,mpres)
					plot = wrf_map_overlays(in[iFil],wks,(/contour_rh,vector/),pltres,mpres)
				end if
				if ( pressure .eq. 850 ) then   ; plot temp, rh, height, wind barbs
					opts_z@ContourParameters = (/ 20.0 /)
					contour_height = wrf_contour(in[iFil],wks,z_plane,opts_z)
					;          plot = wrf_map_overlays(a,wks,(/contour_rh,contour_tc,contour_height, \
					;                                    vector/),pltres,mpres)
					plot = wrf_map_overlays(in[iFil],wks,(/contour_w,vector/),pltres,mpres)
				end if

				if ( pressure .eq. 700 ) then   ; plot temp, height, wind barbs
					if plotwhich.eq."CTR"then
						opts_z@ContourParameters = (/ 30.0 /)
						contour_height = wrf_contour(in[iFil],wks, z_plane,opts_z)
					else if plotwhich.eq."IRR-CTR"then
						opts_z@ContourParameters = (/ 5.0 /)
						contour_height = wrf_contour(in[iFil],wks, z_planeExp-z_plane,opts_z)
					end if
					end if
					plot = wrf_map_overlays(in[iFil],wks,(/contour_tc,contour_height, \
											vector/),pltres,mpres)
				end if

				if ( pressure .eq. 500 ) then   ; plot temp, height, wind barbs
					if plotwhich.eq."CTR"then
						opts_z@ContourParameters = (/ 60.0 /)
						contour_height = wrf_contour(in[iFil],wks, z_plane,opts_z)
					else if plotwhich.eq."IRR-CTR"then
						opts_z@ContourParameters = (/ 5.0 /)
						contour_height = wrf_contour(in[iFil],wks, z_planeExp-z_plane,opts_z)
					end if
					end if
					plot = wrf_map_overlays(in[iFil],wks,(/contour_tc,contour_height, \
											vector/),pltres,mpres)
				end if

				if ( pressure .eq. 300 ) then   ; plot windspeed, height, wind barbs
				  opts_z@ContourParameters = (/ 60.0 /)
				  contour_height = wrf_contour(in[iFil],wks, z_plane,opts_z)
				  plot = wrf_map_overlays(in[iFil],wks,(/contour_spd,contour_height, \
											vector/),pltres,mpres)
				end if
				delete(opts_z)
			end do      ; END OF LEVEL LOOP
		end do  ;it
	end do ;iFil
end if	; plottype.eq."hourly"
end

