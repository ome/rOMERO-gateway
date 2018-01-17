setup <- read.csv("setup.csv", comment.char = "#", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)

imageID <- strtoi(setup[grep("imageid", setup$Key, ignore.case=T), ]$Value)
nAnnos <- strtoi(setup[grep("numberofannotations", setup$Key, ignore.case=T), ]$Value)

screenID <- strtoi(setup[grep("screenid", setup$Key, ignore.case=T), ]$Value)
plateID <- strtoi(setup[grep("plateid", setup$Key, ignore.case=T), ]$Value)
projectID <- strtoi(setup[grep("projectid", setup$Key, ignore.case=T), ]$Value)
datasetID <- strtoi(setup[grep("datasetid", setup$Key, ignore.case=T), ]$Value)

mapannotation <- as.character(setup[grep("mapannotation", setup$Key, ignore.case=T), ]$Value)
  
server <- NULL

test_that("Test OMEROServer connect",{
  s <- OMEROServer(host=host, port=port, username=user, password=pass)
  s <- connect(s)
  server <<- s
  expect_that(s@user$getId(), is_a("numeric"))
})

test_that("Test OMEROServer loadObject Image",{
  image <- loadObject(server, "ImageData", imageID)
  expect_that(image@dataobject$getId(), equals(imageID))
  
  clazz <- class(image)[[1]]
  expect_that(clazz, equals('Image'))
})

test_that("Test OMEROServer loadObject Screen",{
  screen <- loadObject(server, "ScreenData", screenID)
  expect_that(screen@dataobject$getId(), equals(screenID))
  
  clazz <- class(screen)[[1]]
  expect_that(clazz, equals('Screen'))
})

test_that("Test OMEROServer loadObject Plate",{
  plate <- loadObject(server, "PlateData", plateID)
  expect_that(plate@dataobject$getId(), equals(plateID))
  
  clazz <- class(plate)[[1]]
  expect_that(clazz, equals('Plate'))
})

test_that("Test OMEROServer loadObject Project",{
  proj <- loadObject(server, "ProjectData", projectID)
  expect_that(proj@dataobject$getId(), equals(projectID))
  
  clazz <- class(proj)[[1]]
  expect_that(clazz, equals('Project'))
})

test_that("Test OMEROServer loadObject Dataset",{
  ds <- loadObject(server, "DatasetData", datasetID)
  expect_that(ds@dataobject$getId(), equals(datasetID))
  
  clazz <- class(ds)[[1]]
  expect_that(clazz, equals('Dataset'))
})

test_that("Test OMEROServer getAnnotations",{
  annos <- getAnnotations(server, type = 'ImageData', id = imageID)
  expect_that(nrow(annos), equals(nAnnos))
})

test_that("Test OMEROServer searchFor",{
  result <- searchFor(server, type = Screen, query = mapannotation)
  expect_that(length(result), equals(1))
  obj <- result[[1]]
  clazz <- class(obj)[[1]]
  id <- getOMEROID(obj)
  expect_that(clazz, equals('Screen'))
  expect_that(id, equals(screenID))
})

test_that("Test OMEROServer disconnect",{
  disconnect(server)
  expect_that(server@gateway$isConnected(), equals(FALSE))
})
