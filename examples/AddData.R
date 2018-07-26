###
# Add dataframes, CSV files, plots, etc. to OMERO
###

library(romero.gateway)

# Load "Iris" example dataset
library(datasets)
data("iris")
data.frame(iris)

# Connect to server
server <- OMEROServer(host = "localhost", username = "xxx", password = "xxx")
server <- connect(server)

# Load the image (can be any other OME object, too) we want to attach the
# data to, in that case the image with ID=1
imageId <- 1
image <- loadObject(server, "ImageData", imageId)

# Attach the dataframe to the image.
# Stores the data as OMERO HDF5 table, see
# https://docs.openmicroscopy.org/omero/5.4.7/developers/Tables.html
attachDataframe(image, iris, "Iris Example dataset")

# Attach the data as CSV file
csvFile <- "/tmp/Iris_Example_dataset.csv"
write.csv(iris, file = csvFile)
fileannotation <- attachFile(image, csvFile)
# Have to call the underlying Java method to get the original file id:
# (We'll need this ID for the GetData.R example)
fid <- fileannotation@dataobject$getFileID()
print(paste("File ID of the Iris_Example_dataset.csv:", fid))

# Also add a summary of the dataset to the image
tmpfile <- "/tmp/Summary.txt"
sink(tmpfile)
summary(iris)
sink()
fileannotation <- attachFile(image, tmpfile)

# Add histogram to the image
tmpfile <- "/tmp/Histogram.png"
png(tmpfile)
hist(iris$Sepal.Width)
dev.off()
fileannotation <- attachFile(image, tmpfile)

# Disconnect again from the server
disconnect(server)

