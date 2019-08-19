;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
  
  rain = wrf_user_getvar(a,"RAINNC",0)
;  rainc  = wrf_user_getvar(a,"RAINC",0)
;  rain   = rainnc + rainc
  wrf_smooth_2d(rain,2)
; units and formats
  rain@units = "mm" ;https://renqlsysu.github.io/2018/09/21/ncl_font_code/

  wks = gsn_open_wks("png","pcp1f")

;---Resources for filled contour plot
  res                   = True
  res@cnFillOn          = True  
  res@ContourParameters = 2.      ; Change the spacing
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  res@FieldTitle    = "tmp1-hour Total Precipitation:tmp2 TO tmp3" ; use sed to replace
  ;res@FontHeightF   = 0.015    ; this increases the 
  ;print(times(-1))
  ;print(times(0))
  ;print("h1"+"times(-1)"+"TO"+"h2"+"times(0)")
  ;res@SubFieldTitle = "'times(-1)'"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  res@TimeLabel = times(0) ;defult false
;---- Fig logo
  res@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
  res@Footer = False  

;--- contour leves should be changed with seasons
  res@cnLevelSelectionMode = "ExplicitLevels"
  rain_levels  = (/.1, 10., 25., 50., 100., 200., 250./) 
  res@cnLevels = rain_levels
;--- clolors 2019.8.12

; colors = (/"mediumseagreen","midnightblue","navyblue", \
;            "mediumblue","mediumslateblue","royalblue","mediumpurple", \
;            "mediumpurple1","white","chartreuse4","chartreuse3", \
;            "greenyellow","yellowgreen","yellow2","orange2", \
;            "orangered","red" /)
;--- 自定义color array（不要和背景前景相同），名称见
;--- https://www.ncl.ucar.edu/Document/Graphics/named_colors.shtml
 colors         = (/(/255,255,255/),(/0,0,0/),(/255,255,255/),(/166,242,143/), \
                  (/61,186,61/),(/97,184,255/),(/0,0,225/),(/250,0,250/), \
                  (/128,0,64/)/)/255.0

  gsn_define_colormap(wks,colors)
  res@cnFillPalette        = "WhBlGrYeRe" ;colors

 ;-------- how to add maps ? seems difficult
  pltres = True
  mpres = True
 ;----------------
 ; pltres@CommonTitle = True   ; Replace description (units) title with our own title
 ; pltres@PlotTitle   = "'PlotTitle' string appears here"

  plot = wrf_contour(a,wks,rain,res)
  full = wrf_map_overlays(a,wks,(/plot/),pltres,mpres) ; full check
  
; Plot partial domain.
  lat2d = wrf_user_getvar(a,"XLAT",-1)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",-1)  ; longitude
  
  res@sfXArray = lon2d
  res@sfYArray = lat2d

 ;---Set special resource to indicate we are using XLAT/XLONG coordinates.
  pltres@LatLonOverlay = True

;---Zoom in on map, which we can do because we're using lat/lon coordinates.
  mpres@mpLeftCornerLatF  =  29.5
  mpres@mpRightCornerLatF =  38.5
  mpres@mpLeftCornerLonF  = 108.5
  mpres@mpRightCornerLonF = 118.5

  mpres@mpDataSetName         = "Earth..4"
  mpres@mpDataBaseVersion     = "MediumRes" ; or "Ncarg4_1"
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpGridLineColor        = "Black"
  mpres@mpLimbLineColor        = "Black"
  mpres@mpPerimLineColor       = "Black"
  mpres@mpUSStateLineThicknessF     = 2
  mpres@mpNationalLineThicknessF    = 2
  mpres@mpUSStateLineColor="Black"
  mpres@mpOutlineSpecifiers="China:states"

  delete(full) ; delete op files or will get more figures

;---Overlay plot on map and draw.
  ov = wrf_map_overlays(a,wks,(/plot/),pltres,mpres)


end

exit
