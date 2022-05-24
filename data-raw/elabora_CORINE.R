# CORINE Land Cover https://land.copernicus.eu/pan-european/corine-land-cover
# On Ubuntu, the zip files are too big to be handled by standard unzip. Install and use 7z instead: 

masterpkgr::load_pkgs('sf')
dpath <- file.path(ext_path, 'eu', 'corine_land_cover')

# il link dura solo 24h! prima di eseguire eil seguito, occorre accedere al sito e richiedere il download del file, poi inserire il nuovo link qui sotto
url <- 'https://land.copernicus.eu/land-files/4ecde146e6ca8dd7a42f68a9f5370153d9731a95.zip'
getOption('timeout')
options(timeout = 1200)
tmp <- tempfile()

message('Scarico il file...')
download.file(url, destfile = tmp)
fname <- unzip(tmp, list = TRUE)$Name

message('Estraggo il primo file...')
system(paste0('7z e -o', dpath, ' ', tmp))

message('Estraggo il secondo file...')
system(paste0('7z e -spf -aoa -r -o', dpath, ' ', file.path(dpath, fname)))

message('Leggo il GeoDatabase...')
dbn <- file.path(dpath, gsub('\\..*$', '', fname), 'DATA', 'U2018_CLC2018_V2020_20u1.gdb')
lyn <- rgdal::ogrListLayers(dbn)
y <- st_read(dsn = dbn, layer = lyn[1])
# the layer contains unsapported geometry types
as.data.frame(table(st_geometry_type(y)))
# We need to cast all the above to MULTIPOLYGON to avoid the unsupported geometry type
y <- st_cast(y, 'MULTIPOLYGON')
# Now, all features are of type MULTIPOLYGON, and it may also be necessary to make a topological correction:
y <- st_make_valid(y)

# download and create the italian boundary to crop the layer
itpath <- file.path(ext_path, 'it', 'istat', 'confini')
download.file('https://www.istat.it/storage/cartografia/confini_amministrativi/non_generalizzati/Limiti01012021.zip', destfile = tmp)
unzip(tmp, exdir = itpath, junkpaths = TRUE)
bnd.it <- st_read(file.path(itpath, list.files(itpath, pattern = '^P.*shp$')))
# bnd.it <- st_union(bnd.it)
bnd.it <- st_transform(bnd.it, st_crs(y))
y <- st_crop(y, st_bbox(bnd.it))
y <- st_transform(y, 4326)
unlink(tmp)
