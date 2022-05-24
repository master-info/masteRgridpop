# estrare valori UFFICIALI comuni dei corrispondenti segmenti popolazione
# calcolare Centroidi
# Titolo Mappa?
# Stampa Mappa. tmap? ggplot2?

masteRfun::load_pkgs(master = FALSE, 'masteRgridpop', 'masteRshiny', 'data.table', 'leaflet', 'leaflet.extras', 'sf', 'shiny', 'shinyjs', 'shinyWidgets')
apath <- file.path(data_path, 'gridpop', 'facebook')

ui <- fluidPage(

    useShinyjs(),
    faPlugin,
    tags$head(
        tags$title('Popolazione a microgriglie. @2022 MaSTeR Information'),
        tags$style("@import url('https://geo-master.eu/assets/icone/font-awesome/all.css;')"),
        tags$style(HTML("
            #out_map { height: calc(100vh - 80px) !important; }
            #rdo_tpe { pointer-events: none; font-style: italic; }
            .well { 
                padding: 10px;
                height: 90vh; 
                overflow-y: auto; 
                border: 10px;
                background-color: #EAF0F4; 
            }
            .col-sm-3 { padding-right: 0; }
        "))
    ),
    # includeCSS('./styles.css'),
    
    titlePanel('Popolazione a microgriglie'),

    fluidRow(
        column(3,
            wellPanel(
                pickerInput('cbo_tpp', 'POPOLAZIONE:', fb_pop.lst),
                virtualSelectInput(
                    'cbo_cmn', 'COMUNE:', cmn.lst, character(0), search = TRUE, 
                    placeholder = 'Selezionare un Comune', 
                    searchPlaceholderText = 'Cerca...', 
                    noSearchResultsText = 'Nessun Comune trovato!'
                ),
                h5(id = 'txt_num', ''),
                br(),
                awesomeRadio('rdo_tpe', 'VISUALIZZA COME:', c('Punti', 'Voronoi')),
                prettySwitch('swt_lbl', 'Aggiungi Etichette', TRUE, 'success', fill = TRUE),
                br(),
                selectInput('cbo_tls', 'TESSERA MAPPA:', tiles.lst, tiles.lst[[2]]),
                masterPalette('col_pop', 'SCHEMA COLORE:', 'Rossi'),
                prettySwitch('swt_rvc', 'INVERTI COLORI', FALSE, 'success', fill = TRUE),
                conditionalPanel("input.rdo_tpe == 'Punti'",
                    sliderInput('sld_pop', 'SPESSORE PUNTI:', 4, 12, 6, 1)
                ),
                masterColore('col_com', 'COLORE LINEA COMUNE:', 'black'), 
                sliderInput('sld_com', 'SPESSORE BORDO COMUNE:', 2, 20, 6, 1),
            )
        ),
        column(9, leafletOutput('out_map', width = '100%'))
    )
    
)

server <- function(input, output) {

    # INIZIAZIONE MAPPA
    output$out_map <- renderLeaflet({ mps})

    # DETERMINO DATASETS
    dts <- reactive({
            req(input$cbo_tpp)
            req(input$cbo_cmn %in% yc$CMN)
            
            ycx <- yc[CMN == input$cbo_cmn]
            ybx <- yb |> subset(CMN == input$cbo_cmn) |> st_cast('MULTILINESTRING') |> merge(ycx)
            fbx <- read_fst_idx(file.path(apath, input$cbo_tpp), input$cbo_cmn)
            dn <- gsub(' .*', '', names(fb_pop.lst)[which(fb_pop.lst == input$cbo_tpp)])
            bbx <- as.numeric(sf::st_bbox(ybx))
            
            html('txt_num', paste('Estratti', formatCit(nrow(fbx)), 'punti'))
            list('ycx' = ycx, 'ybx' = ybx, 'fbx' = fbx, 'dn' = dn, 'bbx' = bbx)
    })
    
    # AGGIORNAMENTO MAPPA SCELTA TIPO POPOLAZIONE o COMUNE
    observeEvent(
        {
            input$cbo_tpp 
            input$cbo_cmn
        }, 
        {
            req(dts)
            pal <- colorNumeric(liste[grepl('palette', lista) & nome == input$col_pop, elemento], dts()$fbx$pop, reverse = input$swt_rvc)
            
            y <- leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearShapes() |> clearControls() |> 
                    fitBounds(dts()$bbx[1], dts()$bbx[2], dts()$bbx[3], dts()$bbx[4]) |> 
                    addPolylines(
                        data = dts()$ybx,
                        group = 'comune',
                        color = input$col_com, 
                        weight = input$sld_com,
                        opacity = 1,
                        fillOpacity = 0, 
                        label = paste0('Popolazione ', dts()$dn, ' ', dts()$ycx$CMNd, ': ', formatCit(round(sum(dts()$fbx$pop)))),
                        highlightOptions = hlt.options
                    ) |>
                    addCircles(
                        data = dts()$fbx, lng = ~x_lon, lat = ~y_lat, 
                        group = 'gridpop',
                        radius = input$sld_pop,
                        stroke = FALSE, 
                        fillColor = ~pal(pop), fillOpacity = 1, 
                        label = if(input$swt_lbl) { ~formatCit(pop, 2) } else { NULL }
                    )
            grps <- NULL
            for(idx in 1:nrow(tipi_centroidi)){
                tx <- tipi_centroidi[idx]
                grp <- paste0(
                        '<span style="color: ', tx$fColore,'">
                            &nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp',
                        '</span>', tx$descrizione
                )
                grps <- c(grps, grp)
                y <- y |> 
                        addAwesomeMarkers(
                            data = dts()$ycx, lng = ~get(paste0(tx$sigla, 'x_lon')), lat = ~get(paste0(tx$sigla, 'y_lat')),
                            group = grp,
                            icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColore, iconColor = tx$colore),
                            label = tx$descrizione
                        )
            }
        
            y |> 
                addLegend(
                    position = 'bottomright',
                    layerId = 'legenda',
                    pal = pal, values = dts()$fbx$pop, 
                    opacity = 1, 
                    title = dts()$dn
                )  |> 
                addLayersControl( overlayGroups = grps, options = layersControlOptions(collapsed = FALSE) ) |>  
                # TITOLO? 
                # addControl() |> 
                addCircles( lng = mean(bbox.it[1,]), lat = mean(bbox.it[2,]), radius = 0, opacity = 0, layerId = 'spinnerMarker' )

        }
    )
    
    # AGGIORNAMENTO TESSERE MAPPA
    observe({
        leafletProxy('out_map') |> clearTiles() |> aggiungi_tessera(input$cbo_tls)
    })
    
    # AGGIORNAMENTO MAPPA STILI PUNTI/VORONOI
    observeEvent(
        {
            input$rdo_tpe 
            input$swt_lbl 
            input$col_pop 
            input$swt_rvc 
            input$sld_pop
        },
        {
            req(dts())
            pal <- colorNumeric(liste[grepl('palette', lista) & nome == input$col_pop, elemento], dts()$fbx$pop, reverse = input$swt_rvc)
            y <- leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearGroup('gridpop') |> removeControl('legenda') |> clearMarkers() |> 
                    addCircles(
                        data = dts()$fbx, lng = ~x_lon, lat = ~y_lat,
                        group = 'gridpop',
                        radius = input$sld_pop,
                        stroke = FALSE,
                        fillColor = ~pal(pop), fillOpacity = 1,
                        label = if(input$swt_lbl) { ~formatCit(pop, 2) } else { NULL }
                    )
            grps <- NULL
            for(idx in 1:nrow(tipi_centroidi)){
                tx <- tipi_centroidi[idx]
                grp <- paste0(
                        '<span style="color: ', tx$fColore,'">
                            &nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp',
                        '</span>', tx$descrizione
                )
                grps <- c(grps, grp)
                y <- y |>
                        addAwesomeMarkers(
                            data = dts()$ycx, lng = ~get(paste0(tx$sigla, 'x_lon')), lat = ~get(paste0(tx$sigla, 'y_lat')),
                            group = grp,
                            icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColore, iconColor = tx$colore),
                            label = tx$descrizione
                        )
            }
            y |>
                addLegend(
                    position = 'bottomright',
                    layerId = 'legenda',
                    pal = pal, values = dts()$fbx$pop,
                    opacity = 1,
                    title = dts()$dn
                ) |> 
                addCircles( lng = mean(bbox.it[1,]), lat = mean(bbox.it[2,]), radius = 0, opacity = 0, layerId = 'spinnerMarker' )
        }
        
    )

    # AGGIORNAMENTO MAPPA STILI POLIGONO COMUNE
    observeEvent(
        {
            input$col_com
            input$sld_com
        },
        {
            req(dts())
            leafletProxy('out_map') |>
                removeShape(layerId = 'spinnerMarker') |>
                clearGroup('comune') |> 
                addPolylines(
                    data = dts()$ybx,
                    group = 'comune',
                    color = input$col_com, 
                    weight = input$sld_com,
                    opacity = 1,
                    fillOpacity = 0, 
                    label = paste0('Popolazione ', dts()$dn, ' ', dts()$ycx$CMNd, ': ', formatCit(round(sum(dts()$fbx$pop)))),
                    highlightOptions = hlt.options
                ) |> 
                addCircles( lng = mean(bbox.it[1,]), lat = mean(bbox.it[2,]), radius = 0, opacity = 0, layerId = 'spinnerMarker' )
        }
        
    )

}

shinyApp(ui = ui, server = server)
