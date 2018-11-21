###
# Add and get ROIs to/from an image
###

library(romero.gateway)

# Connect to server
server <- OMEROServer(host = "localhost", username = "xx", password = "xx")
server <- connect(server)

# Load the image
imageId <- 1
image <- loadObject(server, "ImageData", imageId)

# Specify some ROIs as dataframe
rois <- data.frame(x = c(0), y = c(0), rx = c(0), ry = c(0), w = c(0), h = c(0), theta = c(0), text = c('remove'), stringsAsFactors = FALSE)
rois <- rbind(rois, c(10, 10, NA, NA, NA, NA, NA, "This is a point"))
rois <- rbind(rois, c(10, 10, 10, 20, NA, NA, NA, "This is an ellipse"))
rois <- rbind(rois, c(10, 10, NA, NA, 10, 20, NA, "This is a Rectangle"))
rois <- rbind(rois, c(10, 10, NA, NA, 10, 20, 0.5, "This is a rotated Rectangle"))
rois <- rois[-1,]
rownames(rois) <- c()

# Add the ROIs to the image
addROIs(image, coords = rois)

# Get the ROIs again
rois <- getROIs(image)

# Disconnect again from the server
disconnect(server)

