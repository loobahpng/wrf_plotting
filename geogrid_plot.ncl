
;   Example script - plot terrain (using only basic NCL functions)
;   Note no map background info is available
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions

begin

  a = addfile("/work4/L.r02229011/WRF_3_5_1/WPS/geo_em.d01.nc","r")   ; Open a file


;  type = "x11"
; type = "pdf"
type="png"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"fig/plt_geo_1")       ; Create a plot workstation


  ter = a->HGT_M(0,:,:)                      ; Read the variable to memory
  res = True                               ; Create some plot resources
  res@cnFillOn = True                      ; Create a color fill plot
  res@gsnSpreadColors = True  
  res@ContourParameters = (/ 0., 2000., 100. /) 
  res@MainTitle = "GEOGRID FIELDS"
  res@InitTime = False
  res@Footer = False
  contour = wrf_contour(a,wks,ter,res)
  pltres = True                              ; Set plot options
  mpres = True                               ; Set map options
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpGridLineColor = "Black"
  mpres@mpLimbLineColor = "Black"
  mpres@mpNationalLineColor = "Black"
  mpres@mpPerimLineColor = "Black"
  mpres@mpUSStateLineColor = "Black"
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)  ; Plot the data over a map background

end

