
;   Example script plots all data in a geo_em file
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("/work4/L.r02229011/WRF_3_5_1/WPS/geo_em.d01.nc","r")   ; Open a file
;  a = addfile("/work4/L.r02229011/WRF_3_5_1/WRFV3/run/wrfinput_d01","r")   ; Open a file


  type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"fig/plt_wrfinput")       ; Create a plot workstation


  res = True                               ; Set some Basic Plot options
  res@MainTitle = "GEOGRID FIELDS"
  res@InitTime = False                     ; Do not plot time or footers
  res@Footer = False

  pltres = True                            ; Set plot options

  mpres = True                             ; Set map options
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"


  vNames = getfilevarnames (a) ; Get names of all variables on file
  nNames = dimsizes (vNames)   ; Number of variables on the file
      
      
  do n=0,nNames-1              ; Loop through each variable

     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
     v = a->$vNames(n)$        ; Read the variable to memory

     opts = res                ; Set plot options to be used by all variables
     opts@cnFillOn = True
     opts@cnFillMode       = "AreaFill"

                                             ; Set special plot options depending on the variable
     if ( vNames(n) .eq. "SLOPECAT")
       opts@cnFillMode       = "RasterFill"
       opts@ContourParameters = (/ 1,7,1 /)
     end if
     if ( vNames(n) .eq. "SOILTEMP")
       opts@ContourParameters = (/ 280.,295.,0.25 /)
     end if
     if ( vNames(n) .eq. "LU_INDEX")
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
     end if
     if ( vNames(n) .eq. "LANDMASK")
       colors = (/"white", "black", "White", "DeepSkyBlue", "ForestGreen"/)
       gsn_define_colormap(wks, colors)
       opts@cnFillMode       = "RasterFill"
       opts@lbLabelBarOn = False
       opts@ContourParameters = (/ 0,1,1 /)
       opts@cnFillColors         = (/"White","DeepSkyBlue", "ForestGreen"/)
     end if
         
     dimv = dimsizes(v)        ; dimension size of the variable
     rank = dimsizes(dimv)     ; rank [ie: number of dimensions]

     dNames = getfilevardims(a,vNames(n))
     ndnames = dimsizes(dNames)
     if (.not.(vNames(n).eq."LU_INDEX"))
     delete (v)
     delete (dimv)
     delete (rank)
     delete (opts)
     delete (dNames)
       continue
     end if
     if ( dNames(ndnames-1) .eq. "west_east" .and. dNames(ndnames-2) .eq. "south_north" ) then  ; only plot unstaggered variables
       if ( rank .eq. 3 ) then
         print (vNames(n))       ; print variable name
         opts@FieldTitle = vNames(n) +" : "+ v@description   ; overwrite field name
         contour = wrf_contour(a,wks,v(0,:,:),opts)
         plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
       end if
       if ( rank .eq. 4 ) then
         print (vNames(n))       ; print variable name
         do lev = 0,dimv(1)-1,1  ; If 4D array - plot only a couple of levels
           nlev = lev + 1
           opts@FieldTitle = vNames(n) +" : "+ v@description +" (lev = "+ nlev +")"   ; overwrite field name
           contour = wrf_contour(a,wks,v(0,lev,:,:),opts)
           plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
         end do
       end if

     end if
           
     delete (v)
     delete (dimv)
     delete (rank)
     delete (opts)
     delete (dNames)

  end do


   
end

