load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

varname="SWVL4_GDS0_DBLY"
;  FILS=systemfunc("ls /work4/L.r02229011/WRF_3_5_1/WPS/met_em.d01.1987* |head -1")
  FILS=systemfunc("ls /dadm1/reanalysis/ECMWF/ITM/0.75/6hr/SFC/ana/swvil4/ERA_Interim_SFC_1987_swvil4_6hr.grib")
  numFILS=dimsizes(FILS)
  a = addfiles(FILS,"r")  ; Open a file
; We generate plots, but what kind do we prefer?
;  type = "x11"
 type = "pdf"
type="png"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"fig/swvil4")
  res = True                           ; Set up some basic plot resources
;  res@ContourParameters = (/ 1000., 1028., 2. /)
;    SMOIS = wrf_user_getvar(a,varname,-1)    ; Get skintemp from file
  Var=a[0]->$varname$
printVarSummary(Var)
    res@cnFillOn            = True
    res@cnLinesOn=False
    res@gsnMaximize     = True
    res@mpMinLatF       = 0
    res@mpMaxLatF       = 50
    res@mpMinLonF       = 20
    res@mpMaxLonF       = 70
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = (/ .1, .2, .3, .4, .5, .6, .7,.8, .9/)
    res@cnFillMode = "RasterFill"
;    opts@ContourParameters = (/ 1,16,1 /)
      plot = gsn_csm_contour_map(wks,Var(236,:,:),res)
;      contour = wrf_contour(a[ifil],wks,SMOIS(ifil,:,:),opts)
;      plot = wrf_map_overlays(a[ifil],wks,(/contour/),pltres,mpres)
   
end

