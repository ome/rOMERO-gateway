###
# Handle Image data
###

library(romero.gateway)

server <- OMEROServer(host = "localhost", username = "xxx", password = "xxx")
server <- connect(server)

imageId <- 1
image <- loadObject(server, "ImageData", imageId)

# Get a thumbnail of the image
thumb <- getThumbnail(image)
plot(0:1,0:1,type="n",ann=FALSE,axes=FALSE)
rasterImage(thumb,0,0,1,1)

# Get the raw pixel values and create a histogram
pixels <- getPixelValues(image)
hist(pixels)

disconnect(server)
