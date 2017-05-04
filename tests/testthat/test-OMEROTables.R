setup <- read.csv("setup.csv", comment.char = "#", header = TRUE)

host <- as.character(setup[grep("omero.host", setup$Key, ignore.case=T), ]$Value)
port <- strtoi(setup[grep("omero.port", setup$Key, ignore.case=T), ]$Value)
user <- as.character(setup[grep("omero.user", setup$Key, ignore.case=T), ]$Value)
pass <- as.character(setup[grep("omero.pass", setup$Key, ignore.case=T), ]$Value)
imageID <- strtoi(setup[grep("imageid", setup$Key, ignore.case=T), ]$Value)

server <- OMEROServer(host=host, port=port, username=user, password=pass)
server <- connect(server)
image <- loadObject(server, "ImageData", imageID)
available <- NULL

# Load "Iris" example dataset
library(datasets)
data("iris")
data.frame(iris)

test_that("Test OMERO attachDataframe",{
  image <- attachDataframe(image, iris, name='Iris dataset')
  expect_that(image@dataobject$getId(), equals(imageID))
})

test_that("Test OMERO availableDataframes",{
  image <- loadObject(server, "ImageData", imageID)
  available <<- availableDataframes(image)
  expect_that(nrow(available), equals(1))
})

test_that("Test OMERO loadDataframe",{
  df <- loadDataframe(image, available$ID[1])
  expect_that(nrow(df), equals(nrow(iris)))
})

test_that("Test OMERO loadDataframe with condition",{
  df <- loadDataframe(image, available$ID[1], condition = "(Species=='versicolor')")
  iris2 <- iris[ which(iris$Species=='versicolor'), ]
  expect_that(nrow(df), equals(nrow(iris2)))
})

test_that("Test OMERO describeDataframe",{
  info <- describeDataframe(image, available$ID[1])
  expect_that(nrow(info), equals(5))
})

test_that("Test OMERO deleteFile",{
  deleteFile(image, available$AnnotationID[1])
  available <- availableDataframes(image)
  expect_that(nrow(available), equals(0))
})

disconnect(server)
