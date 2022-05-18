#' @importFrom data.table data.table
NULL

#' fb_centroidi
#'
#' Centroidi pesati rispetto alla popolazione totale o ad un suo particolare segmento (vedi elenco \code{fb_pop.lst})
#' 
#' @format Una data.table con i campi seguenti:
#' \describe{
#'   \item{\code{ref}}{ segmento di popolazione }
#'   \item{\code{CMN}}{ Codice ISTAT del Comune }
#'   \item{\code{x_lon}}{ Longitudine del centroide pesato }
#'   \item{\code{y_lat}}{ Latitudine del centroide pesato }
#' }
#'
'fb_centroidi'
