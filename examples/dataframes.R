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

# Load the first dataframe (this will be the Iris example dataset
# if there was no other dataframe attached before)
df <- loadDataframe(image, dataframes$ID[1])
print(df)

# Disconnect from the server again
disconnect(server)

