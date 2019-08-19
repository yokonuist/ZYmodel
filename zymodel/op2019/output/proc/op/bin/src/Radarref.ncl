;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
  
  t2c = wrf_user_getvar(a,"mdbz",0)
  
  ; units and formats
  t2c@units = "dbz" ;https://renqlsysu.github.io/2018/09/21/ncl_font_code/

  wks = gsn_open_wks("png","mdbz")

;---Resources for filled contour plot
  res                   = True
  res@cnFillOn          = True  
  res@ContourParameters = 2.      ; Change the spacing
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  res@FieldTitle       = "Max Reflectivity"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  res@TimeLabel = times(0) ;defult false
;---- Fig logo
  res@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
  res@Footer = False  

;--- contour leves should be changed with seasons
  res@cnLevelSelectionMode = "ExplicitLevels"
  radar_levels  = (/10, 15, 20, 25, 30, 35, 40, \
                   45, 50, 55, 60, 65, 70 /)
  res@cnLevels = radar_levels
;--- clolors 2019.8.12

; colors = (/"mediumseagreen","midnightblue","navyblue", \
;            "mediumblue","mediumslateblue","royalblue","mediumpurple", \
;            "mediumpurple1","white","chartreuse4","chartreuse3", \
;            "greenyellow","yellowgreen","yellow2","orange2", \
;            "orangered","red" /)
;--- 自定义color array（不要和背景前景相同），名称见
;--- https://www.ncl.ucar.edu/Document/Graphics/named_colors.shtml
;  res@cnFillPalette        = colors

  ;https://www.ncl.ucar.edu/Applications/colormap.shtml
  ;res@cnFillColors = (/15,31,47,63,79,95,111,0,130,143,159,175,\
  ;                   191,207,223,230,239/) 
   res@cnFillPalette = "radar"

 ;-------- how to add maps ? seems difficult
  pltres = True
  mpres = True

  plot = wrf_contour(a,wks,t2c,res)
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
