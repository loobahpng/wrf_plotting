
;   Example script to plot skintemp from a single metgrid file
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

varname="LU_INDEX"

;  FILS=systemfunc("ls /work4/L.r02229011/WRF_3_5_1/WPS/met_em.d01.1987* |head -1")
;  FILS=systemfunc("ls /work4/L.r02229011/WRF_3_4_1/noAVX/WRFV3/run/wrfinput_d02")
  FILS=systemfunc("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/wrfinput_d01")
  numFILS=dimsizes(FILS)
  a = addfiles(FILS,"r")  ; Open a file


; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
type="png"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"fig/LU_index")


  res = True                           ; Set up some basic plot resources
  res@MainTitle = "METGRID FILES"
  res@Footer = False
;  res@ContourParameters = (/ 1000., 1028., 2. /)

  pltres = True
  mpres = True

  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpGridLineColor = "Black"
  mpres@mpLimbLineColor = "Black"
  mpres@mpNationalLineColor = "Black"
  mpres@mpPerimLineColor = "Black"
  mpres@mpUSStateLineColor = "Black"
    Var = wrf_user_getvar(a,varname,-1)    ; Get skintemp from file
printVarSummary(Var)
   Var1D=ndtooned(Var)
   iIrr=ind(Var1D.eq.6.or.Var1D.eq.8);.or.Var1D.eq.3.or.Var1D.eq.4.or.Var1D.eq.5)
   Var1D(iIrr)=999.
   Var1D@_FillValue=999.
   Var=onedtond(Var1D,dimsizes(Var))
   delete(Var1D)
   delete(iIrr)
    opts = res
    opts@cnFillOn            = True

 gsn_define_colormap(wks,"StepSeq25")
       opts@cnFillMode       = "RasterFill"
       opts@cnExplicitLabelBarLabelsOn = True
       opts@ContourParameters = (/ 2,24,1 /)
       opts@lbLabelStrings = (/ "Urban and Built-Up Land", "Dryland Cropland and Pasture", \
                                "Irrigated Cropland and Pasture", "Mixed Dryland/Irrigated Cropland", \
                                "Cropland/Grassland Mosaic", "Cropland/Woodland Mosaic", "Grassland", \
                                "Shrubland", "Mixed Shrubland/Grassland", "Savanna", \
                                "Deciduous Broadleaf Forest", "Deciduous Needleleaf Forest", \
                                "Evergreen Broadleaf Forest", "Evergreen Needleleaf Forest", \
                                "Mixed Forest", "Water Bodies", "Herbaceous Wetland", "Wooded Wetland", \
                                "Barren or Sparsely Vegetated", "Herbaceous Tundra", "Wooded Tundra", \
                                "Mixed Tundra", "Bare Ground Tundra", "Snow or Ice" /)
       opts@lbLabelAngleF = 270.0
       opts@lbLabelAlignment = "BoxCenters"
       opts@lbTitleOn = False
       opts@lbLabelFontHeightF = 0.01
       opts@lbLabelJust = "CenterLeft"
       opts@pmLabelBarOrthogonalPosF = 0.01

;    opts@cnFillMode = "RasterFill"
;    opts@ContourParameters = (/ 1,16,1 /)
  do ifil = 0,numFILS-1
    contour = wrf_contour(a[ifil],wks,Var(ifil,:,:),opts)
    plot = wrf_map_overlays(a[ifil],wks,(/contour/),pltres,mpres)
  end do
   
end

