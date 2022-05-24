#' fb_pop.lst
#' 
#' Lista dei segmenti di popolazione presenti nei microdati Facebook
#'
#' @export
#' 
fb_pop.lst <- c(
    'Totale' = 'general', 
    'Maschi' = 'men', 
    'Femmine' = 'women', 
    'Giovani 15-24 anni' = 'youth_15_24',
    'Anziani 60 anni ed oltre' = 'elderly_60_plus', 
    'Donne 15-49 anni' = 'women_of_reproductive_age_15_49', 
    'Bambini minori di 4 anni' = 'children_under_five'
)

#' cmn.lst
#' 
#' Lista completa unica dei Comuni Italiani 
#'
#' @export
#' 
cmn.lst <- masteRshiny::crea_cmn_lst()

#' tipi_centroidi
#' 
#' Elenco delle varie tipologie di centroidi presenti nella tabella comuni
#'
#' @export
#' 
tipi_centroidi <- data.table(
    sigla = c('', 'w', 'c', 's', 'm', 'p'),
    descrizione = c('Geometrico', 'Pesato', 'Localit\u00E0 Centrale', 'Municipio', 'Sezione Municipio', 'Polo di Inaccessibilit\u00E0'),
    icona = c('hexagon', 'scale-balanced', 'family', 'school', 'school', 'atom'),
    colore = c('#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF', '#000000'),  # colore icona
    fColore = c('cadetblue', 'darkpurple', 'orange', 'red', 'darkred', 'gray')     # colore marker
)

