#' estrai_gridpop
#'
#' Estrae i valori di griglia per uno o piu Comuni ed uno specifico segmento di popolazione
#'
#' @param x   Vettore di codici ISTAT Comune
#' @param s   Segmento della popolazione (inserire lettera iniziale dei nomi in elenco \code{fb_pop.lst})
#' @param out Carattere che indica che tipo di oggetto ritornare; 
#'            uno fra: 'd' una tabella data.table, 's' oggetto spaziale sf, 'm' mappa leaflet
#' @param ... ulteriori argomenti da passare alla funzione \code{basemap} del pacchetto \code{masteRfun}
#'
#' @return Una tabella "data.table", un oggetto spaziale "sf", oppure una mappa interattiva "leaflet"
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#' 
#' @import data.table leaflet 
#' @importFrom sf 
#' @importFrom masteRfun read_fst_idx data_path basemap
#'
#' @export
#' 
estrai_gridpop <- function(x, s, out = 'm', ...){
    s <- paste0(fb_pop.lst[which(substr(names(fb_pop.lst), 1, 1) == s)])
    r <- rbindlist(lapply(x, \(z) read_fst_idx(file.path(data_path, 'gridpop', 'facebook', s), z)))
    switch(out,
        'd' = r,
        's' = sf::st_as_sf(r, coords = c('x_lon', 'y_lat'), crs = 4326),
        'm' = basemap(pnts = r) |> aggiungi_tessera()
    )
}