########################################
# ricava codici sezioni
########################################

masteRfun::load_pkgs(master = FALSE, 'data.table', 'fst', 'sf')
fpath <- file.path(data_path, 'gridpop', 'facebook')
fns <- setdiff(gsub('.idx$', '', list.files(fpath, 'idx$')), 'centroidi')
yb <- masteRconfini::SZN |> st_transform(crs.it.ed)
yz <- masteRgeo::sezioni[, .(SZN, CMN)]

fn <- "general"
# for(fn in fns){
    y <- read_fst(file.path(fpath, fn), as.data.table = TRUE)
    y[, id := 1:.N]
    yt <- rbindlist(lapply(
                sort(unique(y$CMN)),
                \(x){
                    message('Processo ', x)
                    ybz <-  yb |> subset(SZN %in% yz[CMN == x, SZN])
                    y[CMN == x, .(id, x_lon, y_lat)] |> 
                        st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326) |> 
                        st_transform(crs.it.ed) |> 
                        st_join(yb, join = st_within) |> 
                        st_drop_geometry()
                }
    ))
    y <- yt[y, on = 'id'][, id := NULL]
    setorderv(y, c('CMN', 'SZN'))
    write_fst_idx(y, 'CMN', fn, fpath)
# }