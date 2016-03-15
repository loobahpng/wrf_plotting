;   Example script to plot skintemp from a single metgrid file
;   November 2008
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
  FILS=systemfunc("ls /work4/L.r02229011/WRF_3_5_1/WRFV3/run/control_1986_60hr/wrfout_d02*|head -n 20")
  numFILS=dimsizes(FILS)
  a = addfiles(FILS,"r")  ; Open a file
; We generate plots, but what kind do we prefer?
;  type = "x11"
 type = "png"
;type="png"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"fig/por_wlt")

soil_layer=3
    SMC = wrf_user_getvar(a,"SMOIS",-1)    ; x
    SMCREL = wrf_user_getvar(a,"SMCREL",-1)    ; y
time1=1
time2=1000
;mmm=new((/299,299/),"float") ; for d01
mmm=new((/210,210/),"float")  ; for d02
mmm=(SMCREL(time2,soil_layer,:,:)-SMCREL(time1,soil_layer,:,:))
                     MAXSMC=((SMC(time2,soil_layer,:,:)-SMC(time1,soil_layer,:,:))\
                            +SMC(time1,soil_layer,:,:)*SMCREL(time2,soil_layer,:,:)\
                            -SMC(time2,soil_layer,:,:)*SMCREL(time1,soil_layer,:,:))/\
                            where(mmm.ne.0,mmm,mmm@_FillValue)
                        WLT=(SMC(time1,soil_layer,:,:)*SMCREL(time2,soil_layer,:,:)\
                            -SMC(time2,soil_layer,:,:)*SMCREL(time1,soil_layer,:,:))/\
                            where(mmm.ne.0,mmm,mmm@_FillValue)
printVarSummary(MAXSMC)
xgrid=30
ygrid=3
print("("+xgrid+","+ygrid+")")
print("lat: "+a[0]->XLAT(0,xgrid,ygrid))
print("lon: "+a[0]->XLONG(0,xgrid,ygrid))
print("mmm: "+mmm(xgrid,ygrid))
print("SMCREL1: "+sprintf("%10.8f",SMCREL(time1,soil_layer,xgrid,ygrid)))
print("SMCREL2: "+sprintf("%10.8f",SMCREL(time2,soil_layer,xgrid,ygrid)))
print("SMC1: "+sprintf("%10.8f",SMC(time1,soil_layer,xgrid,ygrid)))
print("SMC2: "+sprintf("%10.8f",SMC(time2,soil_layer,xgrid,ygrid)))
print("MAXSMC: "+MAXSMC(xgrid,ygrid))
print("WLT: "+WLT(xgrid,ygrid))

  res = True                           ; Set up some basic plot resources
  res@MainTitle ="Porosity"
  res@Footer = False
  res@ContourParameters = (/ 0.6, 0.7, 0.005 /)
  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpGridLineColor = "Black"
  mpres@mpLimbLineColor = "Black"
  mpres@mpNationalLineColor = "Black"
  mpres@mpPerimLineColor = "Black"
  mpres@mpUSStateLineColor = "Black"
    opts = res
    opts@cnFillMode       = "RasterFill"
    opts@cnFillOn            = True
  times = wrf_user_getvar(a,"times",-1) 
  ntimes=dimsizes(times)
      opts@TimeLabel=times(0)
      opts@FieldTitle="Porosity (m3/m3)"
      contour = wrf_contour(a[0],wks,MAXSMC(:,:),opts)
 pltres@PanelPlot = True 
      plot = wrf_map_overlays(a[0],wks,(/contour/),pltres,mpres)
  pmres = True
  pmres@gsMarkerColor = "Black"
  pmres@gsMarkerIndex = 16
  pmres@gsMarkerSizeF = 0.01
  plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
draw(plot)
frame(wks)
  opts@MainTitle ="Wilting point"
      opts@FieldTitle="Wilting point (m3/m3)"
  opts@ContourParameters = (/ 0., 0.1, 0.005 /)
  contour = wrf_contour(a[0],wks,WLT(:,:),opts)
  plot = wrf_map_overlays(a[0],wks,(/contour/),pltres,mpres)
  plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
draw(plot)
frame(wks)
  opts@MainTitle ="mmm"
      opts@FieldTitle=""
  opts@ContourParameters = (/ 0., 1e-5, 5e-7 /)
  contour = wrf_contour(a[0],wks,mmm(:,:),opts)
  plot = wrf_map_overlays(a[0],wks,(/contour/),pltres,mpres)
  plotstn=gsn_add_polymarker(wks,plot,43.97,26.33,pmres)
draw(plot)
frame(wks)
;    end do

end

