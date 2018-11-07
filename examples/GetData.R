###
# Load dataframes from OMERO
###

library(romero.gateway)

server <- OMEROServer(host = "localhost", username = "xx", password = "xx")
server <- connect(server)

imageId <- 1
image <- loadObject(server, "ImageData", imageId)

# List which dataframes are attached to the image
dataframes <- availableDataframes(image)
print(dataframes)

# Get some more information about the first dataframe 
# (this will be the Iris example dataset from the AddData.R example
# if there was no other dataframe attached before)
dfID <- dataframes$ID[1]
describeDataframe(image, dfID)

# Load the first dataframe
df <- loadDataframe(image, dfID)
print(df)

# Load a partial dataframe, from row 1 to row 10, 
# only including the first (1) and last (5) column
partialDf <- loadDataframe(image, dfID, rowFrom =  1, rowTo = 10, columns = c(1,5))
print(partialDf)

# Load only the data for the 'versicolor' type
partialDf <- loadDataframe(image, dfID, condition = "Species=='versicolor'")
print(partialDf)

# Load the dataframe from a CSV file
# (This is the File ID of the CSV file from the AddData.R example; 
#  you can find it for example by hovering over the CSV file
#  attachment in OMERO.web)
fid <- 1
df <- loadCSV(server, fid)
print(df)

disconnect(server)
