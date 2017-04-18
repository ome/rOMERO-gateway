setup <- read.csv("setup.csv", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)

imageID <- strtoi(setup[grep("imageid", setup$Key, ignore.case=T), ]$Value)
datasetID <- strtoi(setup[grep("datasetid", setup$Key, ignore.case=T), ]$Value)
projectID <- strtoi(setup[grep("projectid", setup$Key, ignore.case=T), ]$Value)
nAnnos <- strtoi(setup[grep("numberofannotations", setup$Key, ignore.case=T), ]$Value)
fAnnoName <- as.character(setup[grep("fileannotationname", setup$Key, ignore.case=T), ]$Value)

server <- OMEROServer(host=host, port=port, username=user, password=pass)
server <- connect(server)

image <- loadObject(server, "ImageData", imageID)

test_that("Test OMEROServer getOMEROID",{
  id <- getOMEROID(image)
  expect_that(id, equals(imageID))
})

test_that("Test OMEROServer getOMEROType",{
  typ <- getOMEROType(image)
  expect_that(typ, equals('ImageData'))
})

test_that("Test OMEROServer getAnnotations",{
  annos <- getAnnotations(image)
  expect_that(nrow(annos), equals(nAnnos))
})

test_that("Test OMEROServer getAnnotations specific",{
  annos <- getAnnotations(image, typeFilter = 'FileAnnotationData', nameFilter = fAnnoName)
  expect_that(nrow(annos), equals(1))
})
