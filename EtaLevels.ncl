
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986/wrfout_d01_1986-02-01_12:00:00","r")


; We generate plots, but what kind do we prefer?
  type = "x11"
 type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_EtaLevels")


; Set some Basic Plot options
  res = True
  res@MainTitle = "REAL-TIME WRF"

  pltres = True
  mpres = True
  mpres0 = True
  mpres0@mpGeophysicalLineColor = "Black"
  mpres0@mpNationalLineColor    = "Black"
  mpres0@mpUSStateLineColor     = "Black"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0,ntimes-1,20             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    th  = wrf_user_getvar(a,"theta",it)   ; theta
    qv  = wrf_user_getvar(a,"QVAPOR",it)  ; Qv
      qv = qv*1000.
      qv@units = "g/kg"

    u   = wrf_user_getvar(a,"ua",it)      ; u averaged to mass points
    v   = wrf_user_getvar(a,"va",it)      ; v averaged to mass points
      spd = (u*u + v*v)^(0.5)             ; speed in m/sec
      spd@description = "Wind Speed"
      spd@units = "m/s"
      u = u*1.94386                       ; winds now in kts
      v = v*1.94386                       ; winds now in kts
      u@units = "kts"
      v@units = "kts"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    dimsv = dimsizes(th)          ; Get levels
    do level =0,dimsv(0)-1,5      ; LOOP OVER LEVELS

       display_level = level + 1
       res@PlotLevelID = "Eta Level  " + display_level


     ; Theta
       opts = res
       opts@cnLineColor         = "Red"
       opts@ContourParameters   = (/ 5.0 /)
       opts@gsnContourLineThicknessesScale = 2.0
       contour = wrf_contour(a,wks,th(level,:,:),opts)
       plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres0)
       delete(opts)
   
     ; Qv
       opts = res
       opts@cnLineColor         = "Blue"
       opts@cnFillOn            = True
       contour = wrf_contour(a,wks,qv(level,:,:),opts)
       plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
       delete(opts)
   
     ; Wind Vectors and Speed
       opts = res
       opts@ContourParameters = (/ 15., 60., 5. /)
       opts@cnFillOn          = True
       contour = wrf_contour(a,wks,spd(level,:,:),opts)
       delete(opts)
   
       opts = res
       opts@FieldTitle        = "Wind"       ; Overwrite Field Title
       opts@NumVectors        = 47           ; wind barb density
       vector =  wrf_vector(a,wks,u(level,:,:),v(level,:,:),opts)
       delete(opts)

       plot = wrf_map_overlays(a,wks,(/contour, vector/),pltres,mpres)

    end do      ; END OF LEVEL LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP
   
end

