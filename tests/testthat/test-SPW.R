setup <- read.csv("setup.csv", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)
plateID <- strtoi(setup[grep("plateid", setup$Key, ignore.case=T), ]$Value)
plateSize <- strtoi(setup[grep("platesize", setup$Key, ignore.case=T), ]$Value)

server <- OMEROServer(host=host, port=port, username=user, password=pass)
server <- connect(server)

test_that("Test Plate getWells",{
  plate <- loadObject(server, "PlateData", plateID)
  wells <- getWells(plate)
  expect_that(length(wells), equals(plateSize))
})

server <- disconnect(server)
