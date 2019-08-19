;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
   ; ----- method 1
   ; vis as fog can be as this-http://forum.wrfforum.com/viewtopic.php?t=3631 
   ;Fogsi= 2*abs(Tsfc-T850+2*(Tsfc-Tdsfc)+2*Wind850
   ;vis= -1.33+0.45*Fogsi   
   ;-------------- but the results seems not very Good. 2019.8.14
   ; 2m Temperature  
   ;t2 = wrf_user_getvar(a,"T2",0)
   ; 2m Dew point
   ;dp2 = wrf_user_getvar(a,"td2",0) ; C 
   ;td2 = dp2 + 273.16 ; C to K
   ; Temperature
   ;tk = wrf_user_getvar(a,"tk",0)
   ; 850hpa windspd and Temperature
   ;p        =  wrf_user_getvar(a,"pressure",0)  
   ;wspd_wdir = wrf_user_getvar(a,"wspd_wdir",0) ;m/s
   ;wspd     = wspd_wdir(0,:,:,:) ; (1,:,:,:) is wdir  
   ;wspd_850 = wrf_user_interp_level(wspd, p, 850, True)
   ;tk85     = wrf_user_interp_level(tk, p, 850, True) 
  
   ; vis as fog can be as this-http://forum.wrfforum.com/viewtopic.php?t=3631 
   ;Fogsi= 2*abs(Tsfc-T850+2*(Tsfc-Tdsfc)+2*Wind850
   ;vis= -1.33+0.45*Fogsi  
   ;fogsi = 2*abs(t2-tk85)+2*(t2-td2)+2*wspd_850
   ;vis   = -1.33 + 0.45*fogsi
    
   ;----- metho2 CVIS method
   ; as reference to  https://www.researchgate.net/publication/277004271_Predictability_Experiments_of_Fog_and_Visibility_in_Local_Airports_over_Korea_using_the_WRF_Model
   
   ; Acoording to a former research , we use the FSL method 
   ; or more detailed as http://jmm.ijournal.cn/ch/reader/view_abstract.aspx?file_no=20180204&flag=1
   ;   Thus vis = 6000*(t-td)/(RH^1.75) ,miles , vis*1.609344 km
   ; We choose the FSL Method

   ; 2m Temperature  
   t2 = wrf_user_getvar(a,"T2",0)
   ; 2m Dew point
   dp2 = wrf_user_getvar(a,"td2",0) ; C 
   td2 = dp2 + 273.16 ; C to K
   ; RH
   rh2 = wrf_user_getvar(a,"rh2",0)
   temp = rh2^(1.75)
   vis = 1000*(6000*1.609344*(t2-td2)/temp) ; m
   

  
   wrf_smooth_2d(vis,10)   
 
  ; units and formats
  vis@units = "m"   

  wks = gsn_open_wks("png","vis")

;---Resources for filled contour plot
  ;res                   = True
  wsres                   = True
  wsres@cnFillOn          = True 
  
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  wsres@FieldTitle       = "FSL Visibilaty as Fog"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  wsres@TimeLabel = times(0) ;defult false
;---- Fig logo
  wsres@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
  wsres@Footer = False  
;--- contour leves should be changed with seasons
  wsres@cnLevelSelectionMode = "ExplicitLevels"
  vis_levels  = (/10, 50, 100, 500, 1000, 2000, 5000, 10000/)
  wsres@cnLevels = vis_levels
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
  wsres@cnFillColors = (/235,213,197,181,165,133,110,127,0/) 
  ; wsres@cnFillPalette = "MPL_gist_gray"

 ;-------- how to add maps ? seems difficult
  pltres = True
  mpres = True

  plot1 = wrf_contour(a,wks,vis,wsres)
  full = wrf_map_overlays(a,wks,(/plot1/),pltres,mpres) ; full check
  
; Plot partial domain.
  lat2d = wrf_user_getvar(a,"XLAT",-1)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",-1)  ; longitude
  
  wsres@sfXArray = lon2d
  wsres@sfYArray = lat2d

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
  ov = wrf_map_overlays(a,wks,(/plot1/),pltres,mpres)


end

exit
