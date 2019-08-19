;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
    
   slp = wrf_user_getvar(a,"slp",0); sea level pressure
   wrf_smooth_2d(slp,10) ;smoooth

   p        =  wrf_user_getvar(a,"pressure",0)  
   wspd_wdir = wrf_user_getvar(a,"wspd_wdir",0) ;m/s
   wspd     = wspd_wdir(0,:,:,:) ; (1,:,:,:) is wdir  
   
   opt      =  True
   wspd_850 = wrf_user_interp_level(wspd, p, 850, opt)
   
  ; units and formats
  slp@units = "hPa" ;https://renqlsysu.github.io/2018/09/21/ncl_font_code/
  wspd@units = "m/s"   

  wks = gsn_open_wks("png","slp")

;---Resources for filled contour plot
  ;res                   = True
  wsres                   = True
  slpres                  = True

  wsres@cnFillOn          = True 
  
  slpres@cnLineColor      = "MediumSeaGreen"
  slpres@ContourParameters = (/2.0/)
  slpres@cnInfoLabelOrthogonalPosF = 0.07
  slpres@gsnContourLineThicknessesScale = 3.0
 
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  wsres@FieldTitle       = "850hPa wind speed"
  slpres@FieldTitle      = "Sea Level Pressure"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  wsres@TimeLabel = times(0) ;defult false
  slpres@TimeLabel = times(0)
;---- Fig logo
  wsres@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
  wsres@Footer = False  
  slpres@Footer = False
;--- contour leves should be changed with seasons
  wsres@cnLevelSelectionMode = "ExplicitLevels"
  wsp85_levels  = (/10, 15, 20, 25, 30, 35, 40/)
  wsres@cnLevels = wsp85_levels
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

  plot1 = wrf_contour(a,wks,wspd_850,wsres)
  plot2 = wrf_contour(a,wks,slp,slpres)
  full = wrf_map_overlays(a,wks,(/plot1, plot2/),pltres,mpres) ; full check
  
; Plot partial domain.
  lat2d = wrf_user_getvar(a,"XLAT",-1)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",-1)  ; longitude
  
  wsres@sfXArray = lon2d
  wsres@sfYArray = lat2d
  slpres@sfXArray = lon2d
  slpres@sfYArray = lat2d
 

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
  ov = wrf_map_overlays(a,wks,(/plot1,plot2/),pltres,mpres)


end

exit
