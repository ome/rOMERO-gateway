###
# Add a dataframe which is accessible to the OMERO.web client.
#
# This example uses the attachDataframe method again (like the AddData.R example),
# but this time an 'Image' column with the image Ids is added and the dataframe 
# gets attached to a dataset with the particular namespace 
# 'openmicroscopy.org/omero/bulk_annotations'. This way the entries in the dataframe
# will be picked up by the OMERO.web client and shown on the 'Tables' tab of the 
# images.
###

library(romero.gateway)

# Connect to server
server <- OMEROServer(host = "localhost", username = "xx", password = "xx", port = as.integer(4064))server <- connect(server)
server <- connect(server)

# Load a dataset
datasetId <- 1
dataset <- loadObject(server, "DatasetData", datasetId)

# Create a dataframe with one row per image, like:
# Image, SomeValue, AnotherValue
# 1, 'Some value', 'Another Value'
# ...
imgIds <- c()
values1 <- c()
values2 <- c()
for (img in getImages(dataset)) {
  imgIds <- c(imgIds, getOMEROID(img))
  values1 <- c(values1, paste("Some value for image",img@dataobject$getName()))
  values2 <- c(values2, paste("Another value for image",img@dataobject$getName()))
}

# Attach it as dataframe with namespace 'openmicroscopy.org/omero/bulk_annotations'
# to make it available to OMERO.web
df <- data.frame(Image = imgIds, SomeValue = values1, AnotherValue = values2)
attachDataframe(dataset, df, "Example data", ns = "openmicroscopy.org/omero/bulk_annotations")

# Go to OMERO.web client, select an image and you should see its values
# in the 'Tables' tab.