;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
    
   u10 = wrf_user_getvar(a,"U10",0); sea level pressure
   v10 = wrf_user_getvar(a,"V10",0);
   ; http://bbs.06climate.com/forum.php?mod=viewthread&tid=46842
   wspd = (u10*u10 + v10*v10)^(0.5) ; wind speed
   wsdir = atan2(u10,v10)/0.01745329 +180 ; wind direction
  
   res   = True 
   wsres = res 
   ov    = res  
  ; units and formats
   ov@units = "m/s" ;https://renqlsysu.github.io/2018/09/21/ncl_font_code/
   wspd@units = "m/s"   

   wks = gsn_open_wks("png","10mWinds")

;---Resources for filled contour plot
  ;res                   = True
  wsres                   = True
  ov                      = True
  wsres@cnFillOn          = True 
  ov@NumVectors           = 47
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  wsres@FieldTitle       = "10m wind speed"
  ov@FieldTitle          = "10m wind bar"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  wsres@TimeLabel = times(0) ;defult false
  ov@TimeLabel = times(0)
;---- Fig logo
  wsres@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
  wsres@Footer = False  
  ov@Footer = False
;--- contour leves should be changed with seasons
  wsres@cnLevelSelectionMode = "ExplicitLevels"
  wsp10_levels  = (/3.4, 5.5, 8, 10.8, 13.9, 17.2, 20.8, 24.5, 28.5, 32.7, 41.5, 57/)
  wsres@cnLevels = wsp10_levels
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
  wsres@cnFillColors = (/0,130,143,159,175,191,207,223/) 


 ;-------- how to add maps ? seems difficult
  pltres = True
  mpres = True

  plot1 = wrf_contour(a,wks,wspd,wsres)
  plot2 = wrf_vector(a,wks,u10,v10,ov)
  full = wrf_map_overlays(a,wks,(/plot1, plot2/),pltres,mpres) ; full check
  
; Plot partial domain.
  lat2d = wrf_user_getvar(a,"XLAT",-1)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",-1)  ; longitude
  
  wsres@sfXArray = lon2d
  wsres@sfYArray = lat2d
  ov@sfXArray = lon2d
  ov@sfYArray = lat2d
 

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
  plot3 = wrf_map_overlays(a,wks,(/plot1,plot2/),pltres,mpres)
  draw(plot3)

end

exit
