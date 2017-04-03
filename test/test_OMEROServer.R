testdata <- read.csv("testdata.csv", header = TRUE)

imageID <- testdata[grep("imageid", testdata$Key, ignore.case=T), ]$Value

server <- NULL

test_that("Test OMEROServer connect",{
  s <- OMEROServer(credentialsFile = "login_credentials.txt")
  s <- connect(s)
  server <<- s
  expect_that(s@user$getId(), is_a("numeric"))
})

test_that("Test OMEROServer loadObject",{
  image <- loadObject(server, "ImageData", imageID)
  expect_that(image@dataobject$getId(), equals(imageID))
})

test_that("Test OMEROServer disconnect",{
  disconnect(server)
  expect_that(server@gateway$isConnected(), equals(FALSE))
})
