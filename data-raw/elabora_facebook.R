# https://data.humdata.org/dataset/italy-high-resolution-population-density-maps-demographic-estimates
masteRfun::load_pkgs(master = FALSE, 'data.table', 'sf')
in_path <- file.path(ext_path, 'facebook')
out_path <- file.path(data_path, 'gridpop', 'facebook')

# for(fn in list.files(in_path, 'zip', full.names = TRUE)) unzip(fn, exdir = in_path)

coords <- data.table(ref = character(0), CMN = integer(0), x_lon = numeric(0), y_lat = numeric(0))
yc <- sort(masteRgeo::comuni$CMN)
for(fn in list.files(in_path, 'csv$', full.names = TRUE)){
    tn <- gsub('.*ita_(.*)_2020.*', '\\1', fn)
    y <- fread(fn, col.names = c('x_lon', 'y_lat', 'pop'))
    y <- rbindlist(lapply(
                yc,
                \(x){
                    message('Processing ', x)
                    yc <- masteRconfini::CMN |> subset(CMN == x) 
                    ycx <- yc |> suppressWarnings(st_buffer(units::set_units(0, degree))) |> st_bbox()
                    yx <- suppressMessages(y[x_lon %between% c(ycx[1], ycx[3]) & y_lat %between% c(ycx[2], ycx[4])] |> 
                            st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326) |> 
                            st_join(yc) |> subset(!is.na(CMN)) |> subset(pop > 0, pop))
                    yx <- data.table(x, yx |> st_drop_geometry(), yx |> st_coordinates()) |> setnames(c('CMN', 'pop', 'x_lon', 'y_lat'))
                    coords <<- rbindlist(list( coords, data.table( ref = tn, CMN = x, x_lon = weighted.mean(yx$X, yx$pop), y_lat = weighted.mean(yx$Y, yx$pop) ) ))
                    yx
                }
    ))
    write_fst_idx(y, 'CMN', tn, out_path)
}
write_fst_idx(coords, c('ref', 'CMN'), 'centroidi', out_path)

fn <- 'fb_centroidi'
assign(fn, coords)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
dbm_do('gridpop', 'w', fn, coords)
fwrite(coords, './data-raw/csv/fb_centroidi.csv')

dbm_do('gridpop', 'w', 'fb_totale', fst::read_fst(file.path(out_path, 'general')))
dbm_do('gridpop', 'w', 'fb_anziani', fst::read_fst(file.path(out_path, 'elderly_60_plus')))
dbm_do('gridpop', 'w', 'fb_giovani', fst::read_fst(file.path(out_path, 'youth_15_24')))


