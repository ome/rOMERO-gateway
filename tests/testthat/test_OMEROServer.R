setup <- read.csv("setup.csv", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)

imageID <- strtoi(setup[grep("imageid", setup$Key, ignore.case=T), ]$Value)
nAnnos <- strtoi(setup[grep("numberofannotations", setup$Key, ignore.case=T), ]$Value)

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
})

test_that("Test OMEROServer getAnnotations",{
  annos <- getAnnotations(server, type = 'ImageData', id = imageID)
  expect_that(nrow(annos), equals(nAnnos))
})

test_that("Test OMEROServer disconnect",{
  disconnect(server)
  expect_that(server@gateway$isConnected(), equals(FALSE))
})
