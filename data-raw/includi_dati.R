##################################################
# Copia dati e mappa leaflet in PACKAGE DATA DIR #
##################################################

masteRfun::load_pkgs(master = FALSE, 'data.table', 'leaflet')
devtools::load_all()

y <- basemap(menu = FALSE, tiles = tiles.lst[[2]], add_pb_menu = FALSE, extras = NULL) |>
        fitBounds(bbox.it[1, 1], bbox.it[2, 1], bbox.it[1, 2], bbox.it[2, 2]) |>
        registerPlugin(spinPlugin) |>
        registerPlugin(leafletspinPlugin) |>
        on_render_spin('
            if(document.getElementById("titolo_menu_mappa") === null)
                $(".leaflet-control-layers-overlays").prepend("<span id=titolo_menu_mappa>CENTROIDI</span>");
        ') |>
        clearShapes() |>
        fine_mappa_spin()

fn <- 'mps'
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'yc'
assign(fn, masteRgeo::comuni[, .SD, .SDcols = patterns('CMN|lat|lon|pop')][order(CMNd)])
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'yb'
assign(fn, readRDS(file.path(bnd_path, 'CMN', 's40', '0')))
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
