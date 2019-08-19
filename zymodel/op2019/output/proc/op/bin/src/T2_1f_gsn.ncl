;----------------------------------------------------------------------
; refer to http://www.ncl.ucar.edu/Applications/Scripts/wrf_nogsn_4.ncl
;---------------------------------------------------------------------
begin
;---Open WRF output file of only one time step
  filename = "f2"
  a        = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)  ; get times in the file
;---Read temperature at first time step
  
  t2k = wrf_user_getvar(a,"T2",0)
  t2c = t2k - 273.16
  ; units and formats
  t2c@units = "~S~o~N~C" ;https://renqlsysu.github.io/2018/09/21/ncl_font_code/

  wks = gsn_open_wks("png","T2C")

;---Resources for filled contour plot
  res                   = True
  res@cnFillOn          = True  
  res@ContourParameters = 2.      ; Change the spacing
;--- Field titles http://www.ncl.ucar.edu/Applications/Images/wrf_title_6_lg.png
  res@FieldTitle       = "2m Temperature above the ground"
;---- show validtime http://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/NCL/Examples/BASIC_SFC/wrf_Surface1.ncl
  res@TimeLabel = times(0) ;defult false
;---- Fig logo
  res@MainTitle = "ZhongYuan-Model (test) Forecast"
;---- Turn off footer bars 
;  res@Footer = False  

;--- contour leves should be changed with seasons
  res@cnLevelSelectionMode = "ExplicitLevels"
  T2mC_levels  = (/12, 14, 16, 18, 20, 22, 24, \
                   26, 28, 30, 32, 34, 36, 38, 40, 42 /)
  res@cnLevels = T2mC_levels
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
  res@cnFillColors = (/15,31,47,63,79,95,111,0,130,143,159,175,\
                     191,207,223,230,239/) 

  
  ;---Set map resources based on projection on WRF output file
  res = wrf_map_resources(a,res) 
  res@tfDoNDCOverlay      =True 
  plot = gsn_csm_contour_map(wks,t2c,res)


  ;---Attach the shapefile polylines using files read off gadm.org/country.

  county_shp_name    = "~/DONGJL/WIND_OUT/shp/zz_center5.shp"
  city_shp_name    = "~/DONGJL/WIND_OUT/shp/henan_city.shp"
  province_shp_name    = "~/DONGJL/WIND_OUT/shp/bou2_4l.shp"
  lnres                  = True
  lnres@gsLineColor      = "gray25"
  lnres@gsLineThicknessF = 0.5

  county_id = gsn_add_shapefile_polylines(wks,plot,county_shp_name,lnres)

  lnres@gsLineColor      = "black"
  lnres@gsLineThicknessF = 1
  city_id = gsn_add_shapefile_polylines(wks,plot,city_shp_name,lnres)

  lnres@gsLineThicknessF = 2
  province_id = gsn_add_shapefile_polylines(wks,plot,province_shp_name,lnres)

  draw(plot)       ; This will draw the map and the shapefile outlines.
  frame(wks)


end

exit
