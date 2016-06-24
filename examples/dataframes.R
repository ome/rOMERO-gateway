#
# Attach and load a dataframe to/from an OME object
#

# Load "Iris" example dataset
library(datasets)
data("iris")
data.frame(iris)

# Connect to server
server <- OMEROServer(host="localhost", username = "root", password = "omero")
server <- connect(server)

# Load the image (can be any other OME object, too) we want to attach the
# dataframe to, in that case the image with ID=1
image <- loadObject(server, "ImageData", 1)

# Attach the dataframe
attachDataframe(image, iris, "Iris Example dataset")

# List which dataframes are attached to the image
dataframes <- availableDataframes(image)
print(dataframes)

# Get some more information about the first dataframe 
# (this will be the Iris example dataset if there was 
# no other dataframe attached before)
describeDataframe(image, dataframes$ID[1])

# Load the first dataframe 
df <- loadDataframe(image, dataframes$ID[1])
print(df)

# Load a partial dataframe, from row 1 to row 10, 
# only including the first (1) and last (5) column
partialDf <- loadDataframe(image, dataframes$ID[1], 1, 10, c(1,5))
print(partialDf)

# Disconnect from the server again
disconnect(server)

