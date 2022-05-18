#################################################
# Creazione databases e tabelle in MySQL server #
#################################################

library(masteRfun)

dbn <- 'gridpop'
crea_db(dbn)

## TABELLA <fb_centroidi> -------------
x <- "
    `ref` CHAR(35) NOT NULL,
    `CMN` MEDIUMINT UNSIGNED,
    `x_lon` DECIMAL(10,8) NOT NULL,
    `y_lat` DECIMAL(10,8) NOT NULL,
    PRIMARY KEY (`ref`, `CMN`),
    KEY `ref` (`ref`),
    KEY `CMN` (`CMN`)
"
crea_tabella_db(dbn, 'fb_centroidi', x)

## TABELLA <fb_totale> -----------
x <- "
    `CMN` MEDIUMINT UNSIGNED,
    `pop` DECIMAL(7,3) NOT NULL,
    `x_lon` DECIMAL(10,8) NOT NULL,
    `y_lat` DECIMAL(10,8) NOT NULL,
    KEY `CMN` (`CMN`)
"
crea_tabella_db(dbn, 'fb_totale', x)

## TABELLA <fb_anziani> -----------
x <- "
    `CMN` MEDIUMINT UNSIGNED,
    `pop` DECIMAL(7,3) NOT NULL,
    `x_lon` DECIMAL(10,8) NOT NULL,
    `y_lat` DECIMAL(10,8) NOT NULL,
    KEY `CMN` (`CMN`)
"
crea_tabella_db(dbn, 'fb_anziani', x)

## TABELLA <fb_giovani> -----------
x <- "
    `CMN` MEDIUMINT UNSIGNED,
    `pop` DECIMAL(7,3) NOT NULL,
    `x_lon` DECIMAL(10,8) NOT NULL,
    `y_lat` DECIMAL(10,8) NOT NULL,
    KEY `CMN` (`CMN`)
"
crea_tabella_db(dbn, 'fb_giovani', x)


## FINE -------------------------------
rm(list = ls())
gc()
