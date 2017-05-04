setup <- read.csv("setup.csv", comment.char = "#", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)

imageID <- strtoi(setup[grep("imageid", setup$Key, ignore.case=T), ]$Value)
nAnnos <- strtoi(setup[grep("numberofannotations", setup$Key, ignore.case=T), ]$Value)

screenID <- strtoi(setup[grep("screenid", setup$Key, ignore.case=T), ]$Value)
mapannotation <- as.character(setup[grep("mapannotation", setup$Key, ignore.case=T), ]$Value)
  
server <- NULL

test_that("Test OMEROServer connect",{
  s <- OMEROServer(host=host, port=port, username=user, password=pass)
  s <- connect(s)
  server <<- s
  expect_that(s@user$getId(), is_a("numeric"))
})

test_that("Test OMEROServer loadObject",{
  image <- loadObject(server, "ImageData", imageID)
  expect_that(image@dataobject$getId(), equals(imageID))
  
  clazz <- class(image)[[1]]
  expect_that(clazz, equals('Image'))
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
