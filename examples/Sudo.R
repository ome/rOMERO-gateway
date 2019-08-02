###
# Same as the AddData.R example, but this time add the data
# for (ie. impersonating) another user.
###

library(romero.gateway)

# Load "Iris" example dataset
library(datasets)
data("iris")
data.frame(iris)

# Connect to server
server <- OMEROServer(host = "localhost", username = "xx", password = "xx", port = as.integer(4064))
server <- connect(server)

# 'Impersonate' another user (so that he will be the owner
# of the attached data)
server <- sudo(server, 'john', 'lab-1') 

# Load an image (the 'impersonated' user must have read/write access)
imageId <- 1
image <- loadObject(server, "ImageData", imageId)

# Attach the dataframe to the image.
invisible(attachDataframe(image, iris, "Iris Example dataset"))

# To carry on again as the original logged in user,
# disable the 'sudo' context again:
server <- sudo(server, NA)

# ...

# Disconnect
disconnect(server)

