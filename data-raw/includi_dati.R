##################################################
# Copia dati e mappa leaflet in PACKAGE DATA DIR #
##################################################

masteRfun::load_pkgs(master = FALSE, 'data.table', 'leaflet')
devtools::load_all()

y <- basemap(menu = FALSE, tiles = tiles.lst[[2]], add_pb_menu = FALSE, extras = c('reset', 'full', 'scale')) |>
        fitBounds(bbox.it[1, 1], bbox.it[2, 1], bbox.it[1, 2], bbox.it[2, 2]) |>
        registerPlugin(masteRshiny::spinPlugin) |>
        registerPlugin(masteRshiny::leafletspinPlugin) |>
        htmlwidgets::onRender(masteRshiny::spin_event) |>
        htmlwidgets::onRender("
            function() {
                let h4 = document.createElement('h4');
                $('.leaflet-control-layers-overlays').prepend('CENTROIDI', h4);
            }"
        ) |> 
        clearShapes() |>
        addCircles( lng = mean(bbox.it[1,]), lat = mean(bbox.it[2,]), radius = 0, opacity = 0, layerId = 'spinnerMarker' )
fn <- 'mps'
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'yc'
## >>> CODICE DA CANCELLARE!!! <<<<< ##
yc <- masteRgeo::comuni[, .SD, .SDcols = patterns('CMN|lat|lon|pop')][order(CMNd)]
yc[, `:=`( wx_lon = x_lon, wy_lat = y_lat, mx_lon = x_lon, my_lat = y_lat, sx_lon = x_lon, sy_lat = y_lat)]
assign(fn, yc)
#######################################
# assign(fn, masteRgeo::comuni[, .SD, .SDcols = patterns('CMN|lat|lon|pop')][order(CMNd)])
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'yb'
assign(fn, readRDS(file.path(bnd_path, 'CMN', 's40', '0')))
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
