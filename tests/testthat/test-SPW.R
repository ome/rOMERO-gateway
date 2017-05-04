setup <- read.csv("setup.csv", comment.char = "#", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)
plateID <- strtoi(setup[grep("plateid", setup$Key, ignore.case=T), ]$Value)
screenID <- strtoi(setup[grep("screenid", setup$Key, ignore.case=T), ]$Value)
plateSize <- strtoi(setup[grep("platesize", setup$Key, ignore.case=T), ]$Value)
wellSize <- strtoi(setup[grep("wellsize", setup$Key, ignore.case=T), ]$Value)

server <- OMEROServer(host=host, port=port, username=user, password=pass)
server <- connect(server)

test_that("Test Plate getWells",{
  plate <- loadObject(server, "PlateData", plateID)
  wells <- getWells(plate)
  expect_that(length(wells), equals(plateSize))
  
  clazz <- class(wells[[1]])[[1]]
  expect_that(clazz, equals('Well'))
})

test_that("Test Plate getImages",{
  plate <- loadObject(server, "PlateData", plateID)
  imgs <- getImages(plate)
  expect_that(dim(imgs), equals(c(plateSize, wellSize)))
  
  clazz <- class(imgs[[1, 1]])[[1]]
  expect_that(clazz, equals('Image'))
})

test_that("Test Plate getImages of field 1",{
  plate <- loadObject(server, "PlateData", plateID)
  imgs <- getImages(plate, fieldIndex = 1)
  expect_that(length(imgs), equals(plateSize))
  
  clazz <- class(imgs[[1]])[[1]]
  expect_that(clazz, equals('Image'))
})

test_that("Test Screen getPlates",{
  screen <- loadObject(server, "ScreenData", screenID)
  plates <- getPlates(screen)
  expect_that(length(plates), equals(1))
  
  clazz <- class(plates[[1]])[[1]]
  expect_that(clazz, equals('Plate'))
})

test_that("Test Screen getImages",{
  screen <- loadObject(server, "ScreenData", screenID)
  imgs <- getImages(screen)
  expect_that(length(imgs), equals(plateSize))
  
  clazz <- class(imgs[[1]])[[1]]
  expect_that(clazz, equals('Image'))
})

server <- disconnect(server)
