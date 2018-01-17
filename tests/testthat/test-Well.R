setup <- read.csv("setup.csv", comment.char = "#", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)

wellID <- strtoi(setup[grep("wellid", setup$Key, ignore.case=T), ]$Value)

server <- OMEROServer(host=host, port=port, username=user, password=pass)
server <- connect(server)

test_that("Test Well getImages",{
  well <- loadObject(server, "WellData", wellID)
  imgs <- getImages(well)
  expect_that(length(imgs), equals(4))
  
  clazz <- class(imgs[[1]])[[1]]
  expect_that(clazz, equals('Image'))
})
